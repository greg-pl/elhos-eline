/*
 * TcpSvrTask.h
 *
 *  Created on: 7 kwi 2021
 *      Author: Grzegorz
 */

#ifndef MAIN_TCPSVRTASK_H_
#define MAIN_TCPSVRTASK_H_

#include "UMain.h"

#include "TaskClass.h"
#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include <Base64Tool.h>
#include <KObj.h>
#include <SvrTargetStream.h>

typedef struct {
	uint32_t tmToAutoClose;  //TM_NO_CMM = 120 * 1000, // czas do rozłaczenia sesji z powodu braku aktywności
	uint32_t tmKeepAlive; // czas co który musi być coś wysłane
	uint32_t tmMaxTimeInBuf; // maksymalny czas w buforze
	uint32_t tmDataJoin; //TM_DATA_JOIN = 100, // 250[ms] - czas sklejania danych
} TCmmDef;

typedef struct {
	bool connected;
	TDATE ConnectTime;
	ip4_addr_t klientIp;
	int reqCnt; //licznik zapytań
} CmmClientInfo;

class TcpCmmTask: public TaskClass {
	friend class TcpSvrTask;
private:
	int mMyNr;
	int mSock;

	TCmmDef mDef;

	struct {
		bool working;
		int workTick;
		TDATE connectTime;
		int reqCnt;
	} mState;

	struct {
		struct {
			SemaphoreHandle_t snd_mux;
			int lockID;
			int lockTask;
		} smf;

		char *buf;
		int size;
		int len;
		uint32_t sendTick;
		uint32_t firstTick;
		uint32_t addTick;

	} txRec;

	struct {
		char *buf;
		int size;
		int len;
	} rxRec;

	void zeroState();
	struct sockaddr_in m_svr_addr;
	bool sendBuf_(const void *dt, int len);
	bool sendBuf();
	void showState(OutStream *strm);

protected:
	struct {
		int phase;
	} mStatistic;

	bool lock(int id);
	void unlock();
	char* getSndBuf();

	virtual void SendKeepAlive() {
	}
	virtual void beforeSleep() {
	}
	virtual void afterWakeUp() {
	}
	virtual void onDisConnecting() {
	}
	virtual void onLoopProc() {
	}
	virtual void showWorkState(OutStream *strm) {
	}

	//funkcja zwraca ilość pobranych danych z bufora odczytu
	virtual int onDataRecive(char *buf, int len) {
		return len;
	}
protected:
	virtual void ThreadFunc();
public:
	TcpCmmTask(int nr, int stackSize, int rxBufSize, int txBufSize);
	virtual ~TcpCmmTask();
	bool isWorking() {
		return mState.working;
	}
	int getMyNr();

	void startCmm(int sock, struct sockaddr_in *svr_addr);
	void setDef(const TCmmDef *aDef);
	bool sendFromOwnBuf_(int len);
	void addToSend(const void *ptr, int len);
	void terminate();

};

//-------------------------------------------------------------------
typedef TcpCmmTask* (*FunGetClientTask)(int idx);

typedef struct {
	uint16_t mPort;
	int svrCnt;
	const char *svrTaskName;
	const char *cmmTaskName;
	FunGetClientTask getClientTask;
	TCmmDef cmmDef;
} TcpSvrDev;

typedef struct {
	int errTyp1Cnt;
	int errTyp2Cnt;
} GlobSvrState;

class TcpSvrTask: public TaskClass {
private:
	struct {
		uint16_t listenPort;
		int svrCnt;
	} mDef;

	TcpCmmTask **mCmmTab;
	int findUnoccupatedCmm();
	GlobSvrState globSvrState;
	void UpdateLedIn();

protected:
	static TcpSvrTask *me;
	TcpCmmTask* getCmmTask(int idx);

protected:
	virtual void ThreadFunc();
public:
	TcpSvrTask(const TcpSvrDev *def);
	void start();
	void shell(OutStream *strm, const char *cmd);
	bool isAnyWorking();
};

#endif /* MAIN_TCPSVRTASK_H_ */
