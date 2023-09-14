/*
 * UMain.cpp
 *
 *  Created on: Mar 22, 2021
 *      Author: Grzegorz
 */

#include "string.h"
#include "cmsis_os.h"
#include "lwip.h"
#include "dns.h"

#include "UMain.h"
#include "UdpConfigTask.h"

#include "utils.h"
#include "TaskClass.h"
#include "BaseDev.h"

#include "I2cDev.h"
#include "ssd1306.h"
#include "hdw.h"

#include "ShellInterpreter.h"
#include "ShellTask.h"
#include "Config.h"
#include "TcpSvrTask.h"
#include "KpProcessObj.h"

#include "UMain.h"
#include <Engine.h>

ShellTask *shellTask;
Config *config;
ShellInterpreter *shellInterpreter;
UdpConfigTask *udpConfigTask;
FramI2c *framMem;
TcpSvrTask *svrTask;

//-------------------------------------------------------------------------------------------------------------------------
// LABEL
//-------------------------------------------------------------------------------------------------------------------------
#define SEC_LABEL   __attribute__ ((section (".label")))
SEC_LABEL char DevLabel[] = "TTT             "
		"                "
		"                "
		"                "
		"****************"
		"*   eLINE-KP   *"
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
// DefaultTask
//-------------------------------------------------------------------------------------------------------------------------

class DefaultTask: public TaskClass, public SignaledClass {
private:
	enum {
		SIGNAL_TICK = 0x01, //
	};
	void doNetStatusChg();
	typedef struct {
		int loopCnt;
		int loopPhase;
	} State;
	State state;

protected:
	virtual void ThreadFunc();
public:
	DefaultTask();
	virtual void setSignal();
	void showStatus(OutStream *strm);
};

DefaultTask::DefaultTask() :
		TaskClass::TaskClass("MAIN", osPriorityNormal, 1024) {
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

	DigInput::init();
	AnInput::init();

	/* init code for LWIP */
	MX_LWIP_Init();

	setStatusNetIf(&NetIfStatusCallBack);

	udpConfigTask = new UdpConfigTask();
	udpConfigTask->start();

	svrTask = new TcpSvrTask();
	svrTask->start();

	KpProcessObj::init();

	xEventGroupSetBits(sysEvents, EVENT_CREATE_DEVICES);

	DevTab::init();

	uint32_t ledTT = HAL_GetTick();
	bool led = false;
	mNetIfStatusChg = 1;
	state.loopCnt = 0;
	state.loopPhase =0;

	while (1) {
		state.loopCnt++;
		state.loopPhase = 0x10001;
		osSignalWait(SIGNAL_TICK, 50);
		state.loopPhase = 0x10002;

		if (HAL_GetTick() - ledTT > 250) {
			ledTT = HAL_GetTick();
			led = !led;
			Hdw::led1(led);
		}
		state.loopPhase = 0x10002;

		if (rebootRec.flag) {
			if (HAL_GetTick() - rebootRec.tick > rebootRec.time) {
				NVIC_SystemReset();
			}
		}

		state.loopPhase = 0x10003;

		if (recReconfigNet.flag) {
			if (HAL_GetTick() - recReconfigNet.tick > recReconfigNet.time) {
				reconfigNet();
				recReconfigNet.flag = 0;
			}
		}
		state.loopPhase = 0x10004;


		if (mNetIfStatusChg) {
			mNetIfStatusChg = 0;
			doNetStatusChg();
		}
		state.loopPhase = 0x10005;

		I2c1Bus::tick();
		state.loopPhase = 0x10006;
		DigInput::tick();
		state.loopPhase = 0x10007;
		AnInput::tick();
		state.loopPhase = 0x10008;
		Engine::tick();
		state.loopPhase = 0x10009;
		DevTab::tick();
		state.loopPhase = 0x1000A;

		KpProcessObj::tick();
		state.loopPhase = 0x1000b;

	}
}

void DefaultTask::showStatus(OutStream *strm) {
	strm->oMsg("Defaulttask");
	strm->oMsg("LoopCnt         :%u", state.loopCnt);
	strm->oMsg("LoopPhase	    :0x%06X", state.loopPhase);

}

//-------------------------------------------------------------------------------------------------------------------------
// UMain
//-------------------------------------------------------------------------------------------------------------------------
extern "C" void callResCubeMX();

extern __IO uint32_t uwTick;

void HAL_IncTick(void) {
	uwTick += uwTickFreq;
	GlobTime::incUSek();
}

extern "C" void doAftetNewCfg() {
	DigInput::doAfterNewCfg();
	DevTab::doAfterNewCfg();

}

extern "C" void Tim2CallBack(void) {
	static bool div2 = false;
	DigInput::StartMeasure();
	div2 = !div2;
	if (div2) {
		AnInput::StartMeasure();
	}
}

extern TIM_HandleTypeDef htim2;

DefaultTask *defaultTask;

void showDefaultTaskStatus(OutStream *strm) {
	defaultTask->showStatus(strm);
}

extern "C" void setPin(int pinNr, bool val) {
	Hdw::setJMP(pinNr, val);
}

extern "C" void uMainCont() {

	callResCubeMX();

	initNIR();
	Hdw::setJMPAsOut();

	nir.itmp1 = 0x1001;
	nir.itmp3 = 0x1003;

	Hdw::phyReset(0);
	GlobTime::init();

	if (!loadSoftVer(&mSoftVer, &DevLabel[16])) {
		mSoftVer.ver = 1;
		mSoftVer.rev = 1;
	}
	HAL_TIM_Base_Start_IT(&htim2);

	sysEvents = xEventGroupCreate();

	shellInterpreter = new ShellInterpreter();

	shellTask = new ShellTask(TUart::myUART3);
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

