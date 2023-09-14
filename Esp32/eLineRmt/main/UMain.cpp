/*
 * UMain.cpp
 *
 *  Created on: 1 kwi 2021
 *      Author: Grzegorz
 */
#include <string.h>
#include <sys/param.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/timers.h"
#include "freertos/event_groups.h"

#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "esp_netif.h"

#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include <lwip/netdb.h>

#include "driver/gpio.h"
#include "esp_event.h"

#include <MyConfig.h>
#include <Shell.h>
#include <UMain.h>
#include <I2C.h>
#include <ssd1306.h>
#include "Max11612.h"
#include "UdpScanTask.h"
#include "TcpSvrTask.h"
#include "SensorProcessObj.h"

#include "MyBT.h"

static const char *TAG = "eLineRmt";

DevState devState;
EventGroupHandle_t main_ev_group;

MyConfig *myConfig;
Shell *shell;
MainTask *mainTask;

SSD1306Dev *lcd;
Max11612 *max11612;
UdpScanTask *udpScanTask;
TcpSvrTask *tcpSvrTask;

extern "C" OutStream* getOutStream() {
	return shell;
}

#define GPIO_LED1 GPIO_NUM_22
#define GPIO_V12 GPIO_NUM_5
#define GPIO_STER_OUT GPIO_NUM_18
#define GPIO_KPOWER GPIO_NUM_17
#define GPIO_LAD_STAT GPIO_NUM_19
#define GPIO_POWER_OUT GPIO_NUM_16
#define GPIO_PIN  GPIO_NUM_4

bool Hdw::mV12;
bool Hdw::mKpower;
bool Hdw::mSterOut;

void Hdw::initGPIO() {
	gpio_pad_select_gpio(GPIO_LED1);
	gpio_set_direction(GPIO_LED1, GPIO_MODE_OUTPUT);
	gpio_pad_select_gpio(GPIO_V12);
	gpio_set_direction(GPIO_V12, GPIO_MODE_OUTPUT);
	gpio_pad_select_gpio(GPIO_STER_OUT);
	gpio_set_direction(GPIO_STER_OUT, GPIO_MODE_OUTPUT);
	gpio_pad_select_gpio(GPIO_POWER_OUT);
	gpio_set_direction(GPIO_POWER_OUT, GPIO_MODE_OUTPUT);
	gpio_pad_select_gpio(GPIO_KPOWER);
	gpio_set_direction(GPIO_KPOWER, GPIO_MODE_INPUT);
	gpio_pad_select_gpio(GPIO_LAD_STAT);
	gpio_set_direction(GPIO_LAD_STAT, GPIO_MODE_INPUT);

	gpio_pad_select_gpio(GPIO_PIN);
	gpio_set_direction(GPIO_PIN, GPIO_MODE_OUTPUT);

}

void Hdw::setKPower(bool q) {
	mKpower = q;
	gpio_set_level(GPIO_POWER_OUT, q);

}
bool Hdw::chgKPower() {
	setKPower(!mKpower);
	return mKpower;
}
void Hdw::setSterOut(bool q) {
	mSterOut = q;
	gpio_set_level(GPIO_STER_OUT, q);

}
bool Hdw::chgSterOut() {
	setSterOut(!mSterOut);
	return mSterOut;
}

void Hdw::setPin(bool q) {
	gpio_set_level(GPIO_PIN, q);
}

void Hdw::setV12(bool q) {
	mV12 = q;
	gpio_set_level(GPIO_V12, q);

}
bool Hdw::chgV12() {
	setV12(!mV12);
	return mV12;
}

bool Hdw::getLadStatus() {
	return gpio_get_level(GPIO_LAD_STAT);
}

// zwraca tru gdy naciœniêty klawisz
bool Hdw::getKeyPwr() {
	return (gpio_get_level(GPIO_KPOWER) == 0);
}

//------------------------------------------------------------------------------------
// timer1
//------------------------------------------------------------------------------------
typedef struct {
	TimerPhase mPhase;
	int phaseCnt;
	int filtrUpCnt;
	int filtrDnCnt;
	int mShortUp;
	int mShortDn;
} TimerState;

class Timer {
private:
	enum {

	};
	static TimerHandle_t timer1;
	static TimerState state;
	static int runKeyCnt;

	static void initPhase(TimerPhase ph);
	static void vTimerCallback(TimerHandle_t pxTimer);
public:
	static void start();
	static TimerPhase getPhase() {
		return state.mPhase;
	}
};

TimerHandle_t Timer::timer1;
TimerState Timer::state;
int Timer::runKeyCnt;

void Timer::start() {
	memset(&state, 0, sizeof(state));
	initPhase(tmphSTART);
	timer1 = xTimerCreate("KeyTimer", 20 / portTICK_PERIOD_MS, pdTRUE, 0, vTimerCallback);
	xTimerStart(timer1, 0);
}

void Timer::initPhase(TimerPhase ph) {
	memset(&state, 0, sizeof(state));
	state.mPhase = ph;
	mainTask->setTimerPhaseEvent();
}

//uruchamiany co 20[ms]
void Timer::vTimerCallback(TimerHandle_t pxTimer) {

	Hdw::setPin(1);
	max11612->makeMeas();
	Hdw::setPin(0);
	mainTask->setEventSendMeas();

	if (++runKeyCnt < 3)
		return;

	// tylko co 60[ms] uruchamina obs³uga klawisza
	runKeyCnt = 0;

	bool key = Hdw::getKeyPwr();
	bool led = 0;

	state.phaseCnt++;
	if (key) {
		state.filtrUpCnt++;
		state.filtrDnCnt = 0;
	} else {
		state.filtrUpCnt = 0;
		state.filtrDnCnt++;
	}

	switch (state.mPhase) {
	case tmphSTART:
		led = true;
		if (state.phaseCnt > 20) {
			TimerPhase ph = (state.filtrDnCnt >= 3) ? tmphWORK : tmphRELEASE_KEY;
			initPhase(ph);
		}
		break;
	case tmphRELEASE_KEY:
		led = true;
		if (state.filtrDnCnt > 10)
			initPhase(tmphWORK);
		break;
	case tmphWORK:
		if (state.filtrUpCnt == 2) {
			state.mShortUp++;
		}

		if (state.filtrDnCnt >= 6) {
			switch (state.mShortUp) {
			case 1:
				mainTask->setEventKey();
				break;
			case 2:
				mainTask->setEventDblKey();
				break;
			case 3:
				mainTask->setEventTriKey();
				break;
			}
			state.mShortUp = 0;
		}

		if (state.filtrUpCnt == 30) { //1.5[s]
			if (state.mShortUp >= 2) {
				mainTask->setEventSpecKey();
				state.mShortUp = 0;
			} else
				initPhase(tmphEND);
		}

		if (state.filtrUpCnt > 10) {
			led = true;
		} else {
			led = (((state.phaseCnt / 5) & 0x0001) != 0);
		}

		break;
	case tmphEND:
		// odczekanie na puszczenie klawisza przed wy³¹czeniem
		// napis KONIEC
		led = false;
		if (state.filtrDnCnt >= 10)
			initPhase(tmphPOWER_OFF);
		break;
	case tmphPOWER_OFF:
		led = false;
		break;
	}

	gpio_set_level(GPIO_LED1, !led);

}

//------------------------------------------------------------------------------------
// main_task
//------------------------------------------------------------------------------------

MainTask::MainTask() :
		TaskClass::TaskClass("MainTask", 4096) {
	memset(&tmRec, 0, sizeof(tmRec));
	memset(&scr, 0, sizeof(scr));

	event_group = xEventGroupCreate();

	scr.nr = scrMain;
	scr.tmPhase = tmphSTART;
	autoOffTick = 0;

	mTest1Val = 0;
	mTest2Val = 0;
	lcd_mux = xSemaphoreCreateMutex();
	rebootBT.tick = 0;
	restartUDP.tick = 0;
}

bool MainTask::lock() {
	return xSemaphoreTake(lcd_mux, portMAX_DELAY);
}

void MainTask::unlock() {
	xSemaphoreGive(lcd_mux);
}

void MainTask::setEventKey() {
	xEventGroupSetBits(event_group, KEY_BIT);
}

void MainTask::setEventDblKey() {
	xEventGroupSetBits(event_group, DBLKEY_BIT);
}

void MainTask::setEventTriKey() {
	xEventGroupSetBits(event_group, TRIKEY_BIT);
}

void MainTask::setEventSpecKey() {
	xEventGroupSetBits(event_group, SPECKEY_BIT);

}

void MainTask::setTimerPhaseEvent() {
	xEventGroupSetBits(event_group, TIMER_BIT);
}

void MainTask::setEventSendMeas() {
	if (SensorProcessObj::isSendingMeas()) {
		xEventGroupSetBits(event_group, MEAS_BIT);
	}
}

void MainTask::_drawWorkScr() {
	if (scr.freezeTime > 0) {
		if (esp_log_timestamp() - scr.freezeTick > scr.freezeTime) {
			scr.freezeTime = 0;
		}
	}
	if (scr.freezeTime > 0) {
		return;
	}

	lcd->clear();
	lcd->setFont(SSD1306Dev::fn11x18);
	switch (scr.nr) {
	case scrMain:
		lcd->prn("MAIN\n");
		break;
	case scrBAT:
		lcd->prn("BAT\n");
		break;
	case scr12V:
		lcd->setFont(SSD1306Dev::fn7x10);
		lcd->prn("12V->123.45\n");
		break;
	case scrIP: {
		if (!devState.wifiConnected) {
			lcd->prn("IP");
		} else {
			lcd->setFont(SSD1306Dev::fn6x8);
			char buf[20];
			lcd->prn("IP  :%s\n", ipToStr(buf, devState.wifinetInfo.ip));
			lcd->incY(3);
			lcd->prn("MASK:%s\n", ipToStr(buf, devState.wifinetInfo.netmask));
			lcd->incY(3);
			lcd->prn("GW  :%s\n", ipToStr(buf, devState.wifinetInfo.gw));
		}
	}
		break;
	case scrTest1:
		lcd->prn("TEST1=%u\n", mTest1Val);
		break;
	case scrTest2:
		lcd->prn("TEST2=%u\n", mTest2Val);
		break;
	default:
		lcd->setFont(SSD1306Dev::fn7x10);
		lcd->prn("SCR=%u", scr.nr);
		break;
	}
	lcd->updateScr();
}

void MainTask::drawWorkScr() {
	if (scr.tmPhase == tmphWORK) {
		if (lock()) {
			_drawWorkScr();
			unlock();
		}
	}
}

void MainTask::ShowMsgBig(const char *txt) {
	if (lock()) {
		{
			lcd->clear();
			lcd->setFont(SSD1306Dev::fn16x26);
			lcd->prn(txt);
			lcd->updateScr();
			scr.freezeTick = esp_log_timestamp();
			scr.freezeTime = 800;
		}
		unlock();
	}
}

void MainTask::doOffMySelf() {
	lcd->clear();
	lcd->updateScr();
	Hdw::setKPower(false);  // w³¹czenie podtrzymania zasilania
}

void MainTask::doOffMySelfbyBT(int delay) {
	rebootBT.delay = delay;
	rebootBT.tick = esp_log_timestamp();
}
void MainTask::restartMeByUDP(int delay) {
	restartUDP.delay = delay;
	restartUDP.tick = esp_log_timestamp();
}

void MainTask::execNewKey(TickType_t bits) {
	scr.tmPhase = Timer::getPhase();
	if (bits & TIMER_BIT) {
		xEventGroupClearBits(event_group, TIMER_BIT);
		switch (scr.tmPhase) {
		case tmphSTART:
			lcd->welcomeScr();
			break;
		case tmphRELEASE_KEY:
			lcd->releaseKeyScr();
			break;
		case tmphWORK:
			drawWorkScr();
			break;
		case tmphEND:
			lcd->endScr();
			break;
		case tmphPOWER_OFF:
			doOffMySelf();
			break;
		}
	}

	if (scr.tmPhase == tmphWORK) {
		if (bits & KEY_BIT) {
			xEventGroupClearBits(event_group, KEY_BIT);
			tmRec.keyCnt++;

			scr.nr = (ScrNr) (scr.nr + 1);
			ScrNr last = (!scr.serviceMode) ? scr_LAST_NORM : scr_LAST_SERV;
			if (scr.nr == last)
				scr.nr = (ScrNr) 0;
			scr.keyTick = esp_log_timestamp();
		}
		if (bits & DBLKEY_BIT) {
			xEventGroupClearBits(event_group, DBLKEY_BIT);
			switch (scr.nr) {
			case scrTest1:
				mTest1Val = (mTest1Val + 1) % 10;
				break;
			case scrTest2:
				mTest2Val = (mTest2Val + 1) % 10;
				break;
			default:
				break;
			}
			scr.keyTick = esp_log_timestamp();
		}
		if (bits & TRIKEY_BIT) {
			xEventGroupClearBits(event_group, TRIKEY_BIT);
			scr.nr = (ScrNr) 0;
		}
		if (bits & SPECKEY_BIT) {
			xEventGroupClearBits(event_group, SPECKEY_BIT);
			tmRec.keySpecCnt++;
			scr.serviceMode = !scr.serviceMode;
			if (!scr.serviceMode) {
				ShowMsgBig("NORMAL");
			} else {
				ShowMsgBig("SERVICE");
				scr.serviceTick = esp_log_timestamp();
			}
		}
	}
}

void MainTask::ThreadFunc() {

	//printf("MainTask\n");
	ESP_LOGE(TAG, "___MainTask___");

	while (1) {
		EventBits_t bits = xEventGroupWaitBits(event_group, ALL_BITS, pdFALSE, pdFALSE, 250 / portTICK_PERIOD_MS);
		int tt = esp_log_timestamp();

		if (bits & KEY_BITS) {
			execNewKey(bits & KEY_BITS);
			autoOffTick = tt;
		}
		drawWorkScr();
		if (bits & MEAS_BIT) {
			xEventGroupClearBits(event_group, MEAS_BIT);
			SensorProcessObj::tick();
		}

		if (scr.keyTick) {
			if (tt - scr.keyTick > TM_RETURN_MAIN) {
				scr.keyTick = 0;
				scr.nr = scrMain;
			}
		}
		if (scr.serviceTick) {
			if (tt - scr.serviceTick > TM_SERVICE_LOGOUT) {
				scr.serviceTick = 0;
				scr.serviceMode = false;
				ShowMsgBig("NORMAL");
				printf("ServiceAutoLogout\n");
			}
		}
		if (tt - autoOffTick > TM_AUTO_OFF) {
			doOffMySelf();
		}
		if (restartUDP.tick != 0) {
			if (tt - restartUDP.tick > restartUDP.delay) {
				esp_restart();
			}
		}
		if (rebootBT.tick != 0) {
			if (tt - rebootBT.tick > rebootBT.delay) {
				doOffMySelf();
			}
		}
	}
}

void MainTask::keepAlive() {
	autoOffTick = esp_log_timestamp();
}

extern "C" void refreshKeepAlive() {
	mainTask->keepAlive();
}

extern "C" void showLcdBigMsg(const char *msg) {
	mainTask->ShowMsgBig(msg);
}

extern "C" void offMySelfbyBT(int delay) {
	mainTask->doOffMySelfbyBT(delay);
}

extern "C" void restartMe(int delay) {
	mainTask->restartMeByUDP(delay);
}

//----------------------------------------------------------------------------------------
// Wifi station
//----------------------------------------------------------------------------------------
#define EXAMPLE_ESP_WIFI_SSID      CONFIG_ESP_WIFI_SSID
#define EXAMPLE_ESP_WIFI_PASS      CONFIG_ESP_WIFI_PASSWORD
#define EXAMPLE_ESP_MAXIMUM_RETRY  5
#define WIFI_CONNECTED_BIT (1<<0)
#define WIFI_FAIL_BIT      (1<<1)

static EventGroupHandle_t s_wifi_event_group;
static int s_retry_num = 0;

static void event_handler(void *arg, esp_event_base_t event_base, int32_t event_id, void *event_data) {
	if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START) {
		esp_wifi_connect();
	} else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED) {
		if (s_retry_num < EXAMPLE_ESP_MAXIMUM_RETRY) {
			esp_wifi_connect();
			s_retry_num++;
			ESP_LOGI(TAG, "retry to connect to the AP");
		} else {
			xEventGroupSetBits(s_wifi_event_group, WIFI_FAIL_BIT);
		}
		ESP_LOGI(TAG, "connect to the AP fail");
	} else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
		ip_event_got_ip_t *event = (ip_event_got_ip_t*) event_data;
		ESP_LOGI(TAG, "got ip:" IPSTR, IP2STR(&event->ip_info.ip));
		s_retry_num = 0;
		devState.wifiConnected = true;
		devState.wifinetInfo = event->ip_info;
		xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
		xEventGroupSetBits(main_ev_group, MN_BIT_NET_RDY);
	}
}

extern "C" void wifi_init_sta(void) {
	s_wifi_event_group = xEventGroupCreate();

	esp_netif_create_default_wifi_sta();

	wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT()

	ESP_ERROR_CHECK(esp_wifi_init(&cfg));

	esp_event_handler_instance_t instance_any_id;
	esp_event_handler_instance_t instance_got_ip;
	ESP_ERROR_CHECK(esp_event_handler_instance_register(WIFI_EVENT, ESP_EVENT_ANY_ID, &event_handler, NULL, &instance_any_id));
	ESP_ERROR_CHECK(esp_event_handler_instance_register(IP_EVENT, IP_EVENT_STA_GOT_IP, &event_handler, NULL, &instance_got_ip));

	devState.wifiConnected = false;

	if (strlen(myConfig->cfg.WifiSSID) > 0) {
		wifi_config_t wifi_config;
		memset(&wifi_config, 0, sizeof(wifi_config));
		strncpy((char*) wifi_config.sta.ssid, myConfig->cfg.WifiSSID, sizeof(wifi_config.sta.ssid));
		strncpy((char*) wifi_config.sta.password, myConfig->cfg.WifiPassword, sizeof(wifi_config.sta.password));
		wifi_config.sta.threshold.authmode = (wifi_auth_mode_t) myConfig->cfg.WifiAuthMode; //WIFI_AUTH_WEP //WIFI_AUTH_WPA2_PSK; //WIFI_AUTH_WPA_PSK;
		wifi_config.sta.pmf_cfg.capable = true;
		wifi_config.sta.pmf_cfg.required = false;

		ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
		ESP_ERROR_CHECK(esp_wifi_set_config(ESP_IF_WIFI_STA, &wifi_config));
		ESP_ERROR_CHECK(esp_wifi_start());

		ESP_LOGI(TAG, "wifi_init_sta finished.");

		/* Waiting until either the connection is established (WIFI_CONNECTED_BIT) or connection failed for the maximum
		 * number of re-tries (WIFI_FAIL_BIT). The bits are set by event_handler() (see above) */
		EventBits_t bits = xEventGroupWaitBits(s_wifi_event_group, WIFI_CONNECTED_BIT | WIFI_FAIL_BIT, pdFALSE, pdFALSE, portMAX_DELAY);

		if (bits & WIFI_CONNECTED_BIT) {
			ESP_LOGI(TAG, "connected to ap SSID:%s password:%s", myConfig->cfg.WifiSSID, myConfig->cfg.WifiPassword);
		} else if (bits & WIFI_FAIL_BIT) {
			ESP_LOGI(TAG, "Failed to connect to SSID:%s, password:%s", myConfig->cfg.WifiSSID, myConfig->cfg.WifiPassword);
		} else {
			ESP_LOGE(TAG, "UNEXPECTED EVENT");
		}
		/* The event will not be processed after unregister */
		ESP_ERROR_CHECK(esp_event_handler_instance_unregister(IP_EVENT, IP_EVENT_STA_GOT_IP, instance_got_ip));
		ESP_ERROR_CHECK(esp_event_handler_instance_unregister(WIFI_EVENT, ESP_EVENT_ANY_ID, instance_any_id));
		vEventGroupDelete(s_wifi_event_group);
	}
}

//----------------------------------------------------------------------------------------
// Main
//----------------------------------------------------------------------------------------

extern "C" void afterNewCfg() {
	ESP_LOGI(TAG, "AfterNewCfg");
	max11612->afterNewcfg();
}

extern "C" void uMain() {
	ESP_LOGE(TAG, "___START__");
	Hdw::initGPIO();

	main_ev_group = xEventGroupCreate();

	Hdw::setKPower(true);  // w³¹czenie podtrzymania zasilania

	myConfig = new MyConfig();
	myConfig->init();

	I2C::Init();

	lcd = new SSD1306Dev(0x3C);
	lcd->Init();
	lcd->welcomeScr();

	max11612 = new Max11612(0x34);
	max11612->Init();

	mainTask = new MainTask();
	mainTask->start();

	Timer::start(); //musi byc po MainTask

	udpScanTask = new UdpScanTask();
	udpScanTask->start();

	shell = new Shell();
	shell->start();

	tcpSvrTask = new TcpSvrTask();
	tcpSvrTask->start();

	ESP_ERROR_CHECK(esp_event_loop_create_default());
	ESP_ERROR_CHECK(esp_netif_init());

	wifi_init_sta();

	xEventGroupSetBits(main_ev_group, MN_BIT_NET_STARTED);

	MyBT::init();
}
