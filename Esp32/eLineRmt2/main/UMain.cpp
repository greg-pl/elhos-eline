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

MyConfig *myConfig;
Shell *shell;
I2C *i2c;

#define GPIO_LED1 GPIO_NUM_22
#define GPIO_V12 GPIO_NUM_5
#define GPIO_STER_OUT GPIO_NUM_18
#define GPIO_KPOWER GPIO_NUM_17
#define GPIO_LAD_STAT GPIO_NUM_19
#define GPIO_POWER_OUT GPIO_NUM_16

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

bool Hdw::getKeyPwr() {
	return gpio_get_level(GPIO_KPOWER);
}

TimerHandle_t timer1;

bool led = 0;
int cnt = 0;

void vTimerCallback(TimerHandle_t pxTimer) {
	led = !led;
	gpio_set_level(GPIO_LED1, led);
}

static void main_task(void *pvParameters) {


	int cntOFF = 0;
	while (1) {
		vTaskDelay(50 / portTICK_PERIOD_MS);
		if (!Hdw::getKeyPwr()) {
			if (++cntOFF >= 5)
				break;

		} else
			cntOFF = 0;
	}

	xTimerStop(timer1, 0);
	printf("POWER_OFF\n");
	//czekanie na puszczenie klawisza
	while (1) {
		if (!Hdw::getKeyPwr()) {
			Hdw::setKPower(0);
		}
		vTaskDelay(50 / portTICK_PERIOD_MS);
	}

}

//----------------------------------------------------------------------------------------
// Wifi station
//----------------------------------------------------------------------------------------
#define EXAMPLE_ESP_WIFI_SSID      CONFIG_ESP_WIFI_SSID
#define EXAMPLE_ESP_WIFI_PASS      CONFIG_ESP_WIFI_PASSWORD
#define EXAMPLE_ESP_MAXIMUM_RETRY  5
#define WIFI_CONNECTED_BIT (1<<0)
#define WIFI_FAIL_BIT      (1<<1)

static const char *TAG = "eLineRmt";
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
		xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
	}
}

void wifi_init_sta(void) {
	s_wifi_event_group = xEventGroupCreate();

	ESP_ERROR_CHECK(esp_netif_init());

	ESP_ERROR_CHECK(esp_event_loop_create_default());
	esp_netif_create_default_wifi_sta();

	wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT()

	ESP_ERROR_CHECK(esp_wifi_init(&cfg));

	esp_event_handler_instance_t instance_any_id;
	esp_event_handler_instance_t instance_got_ip;
	ESP_ERROR_CHECK(esp_event_handler_instance_register(WIFI_EVENT, ESP_EVENT_ANY_ID, &event_handler, NULL, &instance_any_id));
	ESP_ERROR_CHECK(esp_event_handler_instance_register(IP_EVENT, IP_EVENT_STA_GOT_IP, &event_handler, NULL, &instance_got_ip));

	wifi_config_t wifi_config;
	strncpy((char*) wifi_config.sta.ssid, myConfig->data.WifiSSID, sizeof(wifi_config.sta.ssid));
	strncpy((char*) wifi_config.sta.password, myConfig->data.WifiPassword, sizeof(wifi_config.sta.password));
	wifi_config.sta.threshold.authmode = WIFI_AUTH_WPA_PSK; // WIFI_AUTH_WPA2_PSK;
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
		ESP_LOGI(TAG, "connected to ap SSID:%s password:%s", myConfig->data.WifiSSID, myConfig->data.WifiPassword);
	} else if (bits & WIFI_FAIL_BIT) {
		ESP_LOGI(TAG, "Failed to connect to SSID:%s, password:%s", myConfig->data.WifiSSID, myConfig->data.WifiPassword);
	} else {
		ESP_LOGE(TAG, "UNEXPECTED EVENT");
	}

	/* The event will not be processed after unregister */
	ESP_ERROR_CHECK(esp_event_handler_instance_unregister(IP_EVENT, IP_EVENT_STA_GOT_IP, instance_got_ip));
	ESP_ERROR_CHECK(esp_event_handler_instance_unregister(WIFI_EVENT, ESP_EVENT_ANY_ID, instance_any_id));
	vEventGroupDelete(s_wifi_event_group);
}

extern "C" void uMain() {
	ESP_LOGE(TAG, "___START__");
	Hdw::initGPIO();
	Hdw::setKPower(true);  // w³¹czenie podtrzymania zasilania

	myConfig = new MyConfig();
	myConfig->init();

	i2c = new I2C();
	i2c->Init();

	shell = new Shell();
	shell->start();

	timer1 = xTimerCreate("Timer", 250 / portTICK_PERIOD_MS, pdTRUE, 0, vTimerCallback);
	xTimerStart(timer1, 50);

	wifi_init_sta();
	xTaskCreate(main_task, "main_task", 4096, NULL, 5, NULL);


}
