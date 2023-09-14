/*
 * TcpSvrTask.h
 *
 *  Created on: 7 kwi 2021
 *      Author: Grzegorz
 */

#ifndef MAIN_TCPSVRTASK_H_
#define MAIN_TCPSVRTASK_H_

#include "TaskClass.h"
#include "freertos/FreeRTOS.h"
#include "freertos/event_groups.h"
#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include <Base64Tool.h>
#include <KObj.h>
#include <SvrTargetStream.h>


class TcpCmmTask: public TaskClass, public SvrTargetStream {
private:
	enum {
		BUF_SIZE = 2304, //
		BUF_BIN_SIZE = 1536, //
		//TM_NO_CMM = 2 * 1000, // czas do roz³aczenia sesji z powodu braku aktywnoœci
		TM_NO_CMM = 120 * 1000, // czas do roz³aczenia sesji z powodu braku aktywnoœci
		TM_KEEP_ALIVE = 1000, // czas co który musi byæ coœ wys³ane
		TM_DATA_MAX_IN_BUF = 500, // maksymalny czas w buforze
		TM_DATA_JOIN = 100, // 250[ms] - czas sklejania danych
	};

	enum {
		STX = 0x02, ETX = 0x03,
	};
	int mMyNr;
	int mSock;
	char rx_buffer[BUF_SIZE];
	char tx_buffer[BUF_SIZE];
	uint8_t bin_rx_buf[BUF_BIN_SIZE];
	uint8_t bin_tx_buf[BUF_BIN_SIZE];
	struct {
		int sumaRec;
		int errTyp1Cnt;
		int errTyp2Cnt;
		int phase;
	} mStatistic;
	struct {
		bool working;
		int workTick;
	} mState;

	struct {
		struct {
			SemaphoreHandle_t snd_mux;
			int lockID;
			int lockTask;
		} smf;
		int binPtr;
		bool sndNow;
		uint32_t addTick;
		uint32_t firstTick;
		uint32_t sendTick;
	} txState;

	Base64Tool *base64Tool;
	void zeroState();
	struct sockaddr_in m_svr_addr;
	bool proceesMsg(int len);
	bool lock(int id);
	void unlock();
	void sendBinBuf_();
	void sendBinBuf();
	void sendBuf_(const void *dt, int len);
	bool isAnyToSend();
protected:
	virtual void ThreadFunc();
protected:
	void showKObj(KObj *kObj);
	//tu powo³ane
	virtual void proceesObj(KObj *kObj);
public:
	TcpCmmTask(int nr);
	bool isWorking() {
		return mState.working;
	}
	void startCmm(int sock, struct sockaddr_in *svr_addr);
	void showState();
public: //SvrTargetStream
	virtual void addToSend2(uint8_t devNr, uint8_t code, const void *dt1, int dt1_sz, const void *dt2, int dt2_sz);
	virtual void addToSend(uint8_t devNr, uint8_t code, const void *dt, int dt_sz);
	virtual void sendNow();
	virtual int getIdx();
	virtual const char* getStrmName();

};

typedef struct {
	int errTyp1Cnt;
	int errTyp2Cnt;
} GlobSvrState;


class TcpSvrTask: public TaskClass {
public:
	enum {
		CMM_CNT = 3, //
	};
private:
	enum {
		PORT = 9111, //
	};
	TcpCmmTask *mCmmTab[CMM_CNT];
	int findUnoccupatedCmm();
	static TcpSvrTask *me;
	GlobSvrState globSvrState;
protected:
	virtual void ThreadFunc();
public:
	TcpSvrTask();
	void start();
	void addToSendNow(uint8_t devNr, uint8_t code, const void *dt, int dt_sz);
	void addToSend(uint8_t devNr, uint8_t code, const void *dt, int dt_sz);
	void addToSend(uint8_t devNr, uint8_t code, const char *txt);
	bool menu(char ch);
	static GlobSvrState* getGlobState() {
		return &(me->globSvrState);
	}

};

#endif /* MAIN_TCPSVRTASK_H_ */
