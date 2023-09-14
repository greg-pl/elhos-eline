/*
 * UMain.h
 *
 *  Created on: 2 kwi 2021
 *      Author: Grzegorz
 */

#include "TaskClass.h"
#include "freertos/FreeRTOS.h"
#include "freertos/event_groups.h"

#ifndef MAIN_UMAIN_H_
#define MAIN_UMAIN_H_

class Hdw {
	static bool mV12;
	static bool mKpower;
	static bool mSterOut;

public:
	static void initGPIO();
	static void setKPower(bool q);
	static bool chgKPower();
	static void setSterOut(bool q);
	static bool chgSterOut();
	static void setV12(bool q);
	static bool chgV12();
	static bool getLadStatus();
	static bool getKeyPwr();
	static void setPin(bool q);
};

typedef struct {
	bool wifiConnected;
	esp_netif_ip_info_t wifinetInfo;

} DevState;

extern DevState devState;
enum {
	MN_BIT_NET_STARTED = (1 << 0), //
	MN_BIT_NET_RDY = (1 << 1), //
};

extern EventGroupHandle_t main_ev_group;

typedef enum {
	tmphSTART = 0, tmphRELEASE_KEY, tmphWORK, tmphEND, tmphPOWER_OFF
} TimerPhase;

class MainTask: public TaskClass {
private:
	enum {
		TIMER_BIT = (1 << 0), //
		KEY_BIT = (1 << 1),
		DBLKEY_BIT = (1 << 2),
		TRIKEY_BIT = (1 << 3),
		SPECKEY_BIT = (1 << 4),
		KEY_BITS = TIMER_BIT | KEY_BIT | DBLKEY_BIT | TRIKEY_BIT | SPECKEY_BIT,
		MEAS_BIT = (1 << 5),
		ALL_BITS = KEY_BITS | MEAS_BIT,
	};
	struct {
		int keyCnt;
		int keyDblCnt;
		int keyTriCnt;
		int keySpecCnt;
	} tmRec;

	enum {
		K = 1000, //
		TM_RETURN_MAIN = 30 * K, //30[s]
		TM_SERVICE_LOGOUT = 180 * K, //3[min]
		TM_AUTO_OFF = 600 * K, //10[min]
	};
	typedef enum {
		scrMain, //
		scrBAT, //
		scr12V, //
		scrIP, //
		scrTest1, //
		scrTest2, //
		scr_LAST_SERV, //
		scr_LAST_NORM = scrTest1,
	} ScrNr;

	struct {
		ScrNr nr;
		bool serviceMode;
		TimerPhase tmPhase;
		int freezeTick;
		int freezeTime;
		int keyTick;
		int serviceTick;
	} scr;

	SemaphoreHandle_t lcd_mux;

	int autoOffTick;
	int mTest1Val;
	int mTest2Val;
	struct {
		int delay;
		int tick;
	} rebootBT, restartUDP;

	EventGroupHandle_t event_group;
	void _drawWorkScr();
	void drawWorkScr();
	void execNewKey(TickType_t bits);
	bool lock();
	void unlock();

protected:
	virtual void ThreadFunc();
public:
	void setEventSendMeas();
	void setTimerPhaseEvent();
	void setEventKey();
	void setEventDblKey();
	void setEventTriKey();
	void setEventSpecKey();
public:
	MainTask();
	void doOffMySelf();
	void doOffMySelfbyBT(int delay);
	void restartMeByUDP(int delay);
	void keepAlive();
	void ShowMsgBig(const char *txt);
};

extern "C" void refreshKeepAlive();
extern "C" void showLcdBigMsg(const char *msg);
extern "C" void restartMe(int delay);


#endif /* MAIN_UMAIN_H_ */
