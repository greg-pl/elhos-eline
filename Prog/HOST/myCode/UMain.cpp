/*
 * UMain.cpp
 *
 *  Created on: Mar 8, 2021
 *      Author: Grzegorz
 */

#include "string.h"
#include "cmsis_os.h"
#include "lwip.h"
#include "dns.h"

#include "utils.h"
#include "BaseDev.h"

#include "TaskClass.h"
#include "IOStream.h"
#include "ssd1306.h"
#include "UdpConfigTask.h"

#include "UMain.h"
#include "hdw.h"
#include "Config.h"
#include "I2cDev.h"
#include "Pilot.h"

#include "ModbusMaster.h"
#include "LogKey.h"
#include "ShellInterpreter.h"
#include "ShellTask.h"
#include "I2cFrontExp.h"
#include "KObjSvrTask.h"
#include "Telnet.h"

#include <HostProcessObj.h>
#include <Engine.h>

ShellTask *shellTask;
Config *config;
UdpConfigTask *udpConfigTask;
I2cFront *frontPanel; // expander I2C na płycie czołowej
FramI2c *framMem;
TModbusMaster *modbusMaster;
LogKey *logKey;
ShellInterpreter *shellInterpreter;
KObjSvrTask *svrTask;
TelnetSvrTask *telnetTask;
Engine *engine;


//-------------------------------------------------------------------------------------------------------------------------
// LABEL
//-------------------------------------------------------------------------------------------------------------------------
#define SEC_LABEL   __attribute__ ((section (".label")))
SEC_LABEL char DevLabel[] = "TTT             "
		"                "
		"                "
		"                "
		"****************"
		"*  eLINE-HOST  *"
		"*              *"
		"****************";

//-------------------------------------------------------------------------------------------------------------------------
// Mostki między objektami
//-------------------------------------------------------------------------------------------------------------------------

OutStream* getOutStream() {
	return shellTask;
}

extern "C" CfgTcpInterf* getCfgTcpInterf() {
	return config;
}

extern "C" BaseShellInterpreter* getShellInterpreter() {
	return shellInterpreter;
}

extern "C" void showLcdBigMsg(const char *txt) {

}



extern "C" void updatePanelLedPC(bool q){
	frontPanel->setLedUpdate(I2cFront::ledPC, q);
}


extern RNG_HandleTypeDef hrng;
extern "C" uint16_t getRandom16(void) {
	uint32_t val;
	HAL_RNG_GenerateRandomNumber(&hrng, &val);
	return val & 0xffff;
}

extern "C" uint16_t getPackDate() {
	TDATE tm;
	GlobTime::getTm(&tm);
	return TimeTools::PackDate(&tm);
}

extern "C" uint32_t getPackTime() {
	TDATE tm;
	GlobTime::getTm(&tm);
	return TimeTools::PackTime(&tm);
}

extern "C" void sendPcMsg(uint8_t devNr, uint8_t code, const void *dt, int dt_sz) {
	svrTask->addToSend(devNr, code, dt, dt_sz);
}

extern "C" void sendPcMsgNow(uint8_t devNr, uint8_t code, const void *dt, int dt_sz) {
	svrTask->addToSendNow(devNr, code, dt, dt_sz);
}

//-------------------------------------------------------------------------------------------------------------------------
// LCD
//-------------------------------------------------------------------------------------------------------------------------
enum {
	kyBase1 = 1, //
	kyBase2 = 11, //
	kyEvClick = 0, //
	kyEvDblClick = 1, //
	kyEvTriClick = 2, //
	kyEvLongClick = 4, //

	kyNoKey = 0, //
	ky1Click = kyBase1 + kyEvClick, //
	ky1DblClick = kyBase1 + kyEvDblClick, //
	ky1TriClick = kyBase1 + kyEvTriClick, //
	ky1LongClick = kyBase1 + kyEvLongClick, //
	ky2Click = kyBase2 + kyEvClick, //
	ky2DblClick = kyBase2 + kyEvDblClick, //
	ky2TriClick = kyBase2 + kyEvTriClick, //
	ky2LongClick = kyBase2 + kyEvLongClick, //
};

class KeyFiltr {
private:
	uint8_t mEvBase;
	bool mState;
	uint32_t mUpTick;
	uint32_t mDnTick;
	int mShortPlsCnt;
	bool mWasLongClick;
	enum {
		MIN_PULSE_TM = 20, //
		PULSE_LONG_CLICK = 500, //
		TM_MAX_SHORT_BREAK = 150, //
	};

public:
	KeyFiltr(uint8_t evBase);
	void inp(bool q);
	uint8_t getEv();
};

KeyFiltr::KeyFiltr(uint8_t evBase) {
	mEvBase = evBase;
	mState = false;
	mWasLongClick = 0;
	mShortPlsCnt = 0;
}
void KeyFiltr::inp(bool q) {
	if (q != mState) {
		if (q) {
			mUpTick = HAL_GetTick();
		} else {
			uint32_t tm = HAL_GetTick() - mUpTick;
			if (tm > MIN_PULSE_TM) {
				if (tm < PULSE_LONG_CLICK) {
					mShortPlsCnt++;
				}
			}
			mDnTick = HAL_GetTick();
		}
		mState = q;
	}
}

uint8_t KeyFiltr::getEv() {
	uint32_t tt = HAL_GetTick();
	uint8_t ev = kyNoKey;
	if (!mState) {
		if (tt - mDnTick > TM_MAX_SHORT_BREAK) {
			if (mShortPlsCnt > 0) {
				switch (mShortPlsCnt) {
				case 1:
					ev = mEvBase + kyEvClick;
					break;
				case 2:
					ev = mEvBase + kyEvDblClick;
					break;
				case 3:
					ev = mEvBase + kyEvTriClick;
					break;
				}
				mShortPlsCnt = 0;
			}
			mWasLongClick = false;
		}
	} else {
		if (tt - mUpTick > PULSE_LONG_CLICK) {
			if (!mWasLongClick) {
				mWasLongClick = true;
				mShortPlsCnt = 0;
				ev = mEvBase + kyEvLongClick;
			}
		}
	}
	return ev;
}

//-------------------------------------------------
class Lcd {
private:
	enum {
		scrWelcome = 0, //
		scrState, //
		scrMeasure, //
		scrIP, //
		scr__MAX
	};

	struct {
		int cfgScrNr;
		int cfgSwitchTime;

		int scrNr;
		uint32_t redrawTick; // czas ostatniego odrysowania
		uint32_t scrStartTick; // czas włączenia danego okienka
		int cnt;
	} lcdState;
	KeyFiltr *ky1;
	KeyFiltr *ky2;
	SSD1306Dev *screen; // LCD na płycie czołowej

	void showMeasureScr();
	void showStateScr();
	void showIpScr();
	uint8_t getKey();
	void draw();
	void execKey(uint8_t key);
public:
	Lcd();
	void init();
	void tick();
	void setLcdScrNr(int nr);
	void setLcdTime(int time);

};
Lcd::Lcd() {
	ky1 = new KeyFiltr(kyBase1);
	ky2 = new KeyFiltr(kyBase2);
}

uint8_t Lcd::getKey() {
	uint8_t ev = ky1->getEv();
	if (ev == kyNoKey)
		ev = ky2->getEv();
	return ev;
}

void Lcd::init() {

	screen = new SSD1306Dev(0x78);
	I2c1Bus::addDev(screen);

	memset(&lcdState, 0, sizeof(lcdState));
	lcdState.cfgSwitchTime = config->data.R.B.lcdSwitchTime;
	lcdState.cfgScrNr = config->data.R.B.lcdScrNr;
	lcdState.scrNr = lcdState.cfgScrNr;
	if (lcdState.scrNr < scrWelcome || lcdState.scrNr >= scr__MAX)
		lcdState.scrNr = scrWelcome;
}

void Lcd::showIpScr() {
	NetState netState;
	char txt[40];

	getNetIfState(&netState);

	screen->prn("%u.LinkUp=%s\n", lcdState.scrNr, YN(netState.LinkUp));
	screen->prn("Dhcp=%s Rdy%s\n", OnOff(netState.DhcpOn), YN(netState.DhcpRdy));

	if (netState.ipValid) {
		ipaddr_ntoa_r(&netState.CurrIP, txt, sizeof(txt));
		screen->prn("IP:%s\n", txt);
		ipaddr_ntoa_r(&netState.CurrMask, txt, sizeof(txt));
		screen->prn("MS:%s\n", txt);
		ipaddr_ntoa_r(&netState.CurrGate, txt, sizeof(txt));
		screen->prn("GW:%s\n", txt);
	}
	const ip_addr_t *pdns1 = dns_getserver(0);
	ipaddr_ntoa_r(pdns1, txt, sizeof(txt));
	screen->prn("D1:%s\n", txt);

	const ip_addr_t *pdns2 = dns_getserver(1);
	ipaddr_ntoa_r(pdns2, txt, sizeof(txt));
	screen->prn("D2:%s\n", txt);
}


void Lcd::showStateScr() {
	screen->prn("%u.STATE\n", lcdState.scrNr);

	TDATE tm;
	char buf[TimeTools::DT_TM_SIZE];
	GlobTime::getTm(&tm);
	TimeTools::DtTmStrK(buf,&tm);
	screen->prn(buf);
}

void Lcd::showMeasureScr() {
	screen->prn("%u.MEASURE\n", lcdState.scrNr);
}

void Lcd::draw() {
	screen->clear();
	screen->setFont(SSD1306Dev::fn7x10);

	switch (lcdState.scrNr) {
	case scrWelcome:
		screen->setFont(SSD1306Dev::fn16x26);
		screen->wrStr(" eLINE\n");
		screen->setFont(SSD1306Dev::fn7x10);
		screen->wrStr("\nver.1.0");
		screen->prn("\nN=%u", lcdState.cnt++);
		break;
	case scrState:
		showStateScr();
		break;
	case scrMeasure:
		showMeasureScr();
		break;
	case scrIP:
		showIpScr();
		break;

	};
	screen->updateScr();
}

void Lcd::execKey(uint8_t key) {

}

void Lcd::tick() {
	bool flDraw = false;
	uint32_t tt = HAL_GetTick();

	if (lcdState.cfgSwitchTime > 0) {
		if (tt - lcdState.scrStartTick > (uint32_t) (1000 * lcdState.cfgSwitchTime)) {
			lcdState.scrStartTick = tt;
			if (++lcdState.scrNr == scr__MAX) {
				lcdState.scrNr = scrWelcome;
			}
		}
	}

	if (Hdw::rdPanelIrq()) {
		uint8_t key = frontPanel->readKeys();
		bool q1 = ((key & 0x01) == 0);
		bool q2 = ((key & 0x02) == 0);
		ky1->inp(q1);
		ky2->inp(q2);
		//getOutStream()->oMsgX(colCYAN, "ky1=%u ky2=%u", q1, q2);
	}

	uint8_t key = getKey();
	if (key != kyNoKey) {
		//getOutStream()->oMsgX(colYELLOW, "key=%u", key);
		switch (key) {
		case ky1Click:
			if (++lcdState.scrNr == scr__MAX)
				lcdState.scrNr = 0;
			flDraw = true;
			break;
		case ky2Click:
			if (lcdState.scrNr == 0)
				lcdState.scrNr = scr__MAX;
			lcdState.scrNr--;
			flDraw = true;
			break;
		default:
			execKey(key);
			break;
		}

	}
	if (tt - lcdState.redrawTick > 1000) {
		lcdState.redrawTick = tt;
		flDraw = true;
	}
	if (flDraw) {
		draw();
	}
}

void Lcd::setLcdScrNr(int nr) {
	if (nr >= scrWelcome && nr <= scr__MAX) {
		lcdState.cfgScrNr = nr;
		lcdState.scrNr = nr;
		lcdState.cfgSwitchTime = 0;
	}
}

void Lcd::setLcdTime(int time) {
	if (time >= 0) {
		lcdState.cfgSwitchTime = time;
	}
}


//-------------------------------------------------------------------------------------------------------------------------
// DefaultTask
//-------------------------------------------------------------------------------------------------------------------------

class DefaultTask: public TaskClass, public SignaledClass {
private:
	enum {
		SIGNAL_TICK = 0x01, //
	};

	Lcd *lcd;

	void doNetStatusChg();
protected:
	virtual void ThreadFunc();
public:
	DefaultTask();
	virtual void setSignal();
	void setLcdScrNr(int nr);
	void setLcdTime(int time);
};

DefaultTask::DefaultTask() :
		TaskClass::TaskClass("MAIN", osPriorityNormal, 1024) {
	lcd = new Lcd();
}

void DefaultTask::setLcdScrNr(int nr) {
	lcd->setLcdScrNr(nr);
}

struct {
	volatile bool flag;
	uint32_t tick;
	uint32_t time;
} rebootRec = {
		0 };

struct {
	uint8_t flag;
	uint32_t tick;
	uint32_t time;
} recReconfigNet = {
		0 };

void DefaultTask::setSignal() {
	osSignalSet(getThreadId(), SIGNAL_TICK);
}

void setStatusNetIf(netif_status_callback_fn status_callback);

volatile uint8_t mNetIfStatusChg;

void NetIfStatusCallBack(struct netif *netif) {
	mNetIfStatusChg = 1;
}

void ethernetif_notify_conn_changed(struct netif *netif) {
	mNetIfStatusChg = 1;
}

void DefaultTask::doNetStatusChg() {
	NetState netState;
	getNetIfState(&netState);

	shellTask->oMsgX(colYELLOW, "Net interface status changed, link=%u", netState.LinkUp);

	if (netState.DhcpOn) {
		if (!netState.DhcpRdy) {
			if (netState.LinkUp) {
				setDynamicIP();
			} else {
				clrNetIfAddr();
			}
		}
	}

	if (netState.LinkUp) {
		xEventGroupSetBits(sysEvents, EVENT_NETIF_OK);
	}
}

void DefaultTask::ThreadFunc() {

	__HAL_RCC_BKPSRAM_CLK_ENABLE();

	xEventGroupWaitBits(sysEvents, EVENT_TERM_RDY, false, false, 1000000);

	I2c1Bus::BusInit();

	framMem = new FramI2c(0xA2);
	I2c1Bus::addDev(framMem);

	config = new Config();
	config->Init(shellTask);

	frontPanel = new I2cFront(0x40);
	I2c1Bus::addDev(frontPanel);

	/* init code for LWIP */
	MX_LWIP_Init();

	setStatusNetIf(&NetIfStatusCallBack);

	modbusMaster = new TModbusMaster(TUart::myUART3);
	modbusMaster->Init(9600);

	udpConfigTask = new UdpConfigTask();
	udpConfigTask->start();

	engine = new Engine();

	svrTask = new KObjSvrTask();
	svrTask->start();

	telnetTask = new TelnetSvrTask();
	telnetTask->start();

	logKey = new LogKey(TUart::myUART6);
	logKey->Init();

	lcd->init();
	Pilot::Init();
	HostProcessObj::init();

	xEventGroupSetBits(sysEvents, EVENT_CREATE_DEVICES);

	uint32_t ledTT = HAL_GetTick();
	bool led = false;
	mNetIfStatusChg = 1;
	while (1) {
		osSignalWait(SIGNAL_TICK, 50);

		if (rebootRec.flag) {
			if (HAL_GetTick() - rebootRec.tick > rebootRec.time) {
				NVIC_SystemReset();
			}
		}
		if (recReconfigNet.flag) {
			if (HAL_GetTick() - recReconfigNet.tick > recReconfigNet.time) {
				reconfigNet();
				recReconfigNet.flag = 0;
			}
		}

		if (HAL_GetTick() - ledTT > 250) {
			ledTT = HAL_GetTick();
			led = !led;
			Hdw::led1(led);
		}
		if (mNetIfStatusChg) {
			mNetIfStatusChg = 0;
			doNetStatusChg();
		}
		I2c1Bus::tick();
		lcd->tick();
		engine->tick();


		//pilot radiowy
		Pilot::tick();
		modbusMaster->tick();
		logKey->tick();
		HostProcessObj::tick();

	}
}

//-------------------------------------------------------------------------------------------------------------------------
// UMain
//-------------------------------------------------------------------------------------------------------------------------
extern "C" void callResCubeMX();

extern __IO uint32_t uwTick;

void HAL_IncTick(void)
{
  uwTick += uwTickFreq;
  GlobTime::incUSek();
}


DefaultTask *defaultTask;

void setLcdScrNr(int nr) {
	defaultTask->setLcdScrNr(nr);
}
void setLcdTime(int time) {
	defaultTask->setLcdTime(time);
}

extern "C" void uMainCont() {

	callResCubeMX();

	initNIR();

	nir.itmp1 = 0x1001;
	nir.itmp2 = 0x1002;
	nir.itmp3 = 0x1003;

	Hdw::phyReset(0);
	GlobTime::init();

	if (!loadSoftVer(&mSoftVer, &DevLabel[16])) {
		mSoftVer.ver = 1;
		mSoftVer.rev = 1;
	}

	sysEvents = xEventGroupCreate();

	shellInterpreter = new ShellInterpreter();

	shellTask = new ShellTask(TUart::myUART4);
	shellTask->start();

	defaultTask = new DefaultTask();
	defaultTask->start();

	osKernelStart();

//tu nie powinno dojść
	while (1) {

	}

}

void reboot(int tm) {
	rebootRec.tick = HAL_GetTick();
	rebootRec.time = tm;
	rebootRec.flag = true;
}

void delayReconfigNet(int time) {
	recReconfigNet.time = time;
	recReconfigNet.tick = HAL_GetTick();
	recReconfigNet.flag = 1;
}

