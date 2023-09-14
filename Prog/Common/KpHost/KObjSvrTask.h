/*
 * KObjSvrTask.h
 *
 *  Created on: 15 lis 2021
 *      Author: Grzegorz
 */

#ifndef KOBJSVRTASK_H_
#define KOBJSVRTASK_H_

#include <TcpSvrTask.h>

class KObjCmmTask: public TcpCmmTask, public SvrTargetStream {
private:
	enum {
		STX = 0x02, ETX = 0x03,
	};
	enum {
		BUF_SIZE = 2304, //
		BUF_BIN_SIZE = 1536, //
	};

	Base64Tool *base64Tool;
	uint8_t bin_rx_buf[BUF_BIN_SIZE];
	uint8_t bin_tx_buf[BUF_BIN_SIZE];
	struct {
		struct {
			SemaphoreHandle_t snd_mux;
			int lockID;
			int lockTask;
		} smf;

		int binPtr;
		bool sndNow;
		uint32_t firstTick;
		uint32_t addTick;
		uint32_t sendTick;

	} txBin;

	struct {
		int sumaRec;
		int errTyp1Cnt;
		int errTyp2Cnt;
		int phase;
	} mStatistic;

	void sendBinBuf();
	bool lockBin(int id);
	void unlockBin();

	void sendBuf_(const void *dt, int len);
	bool isAnyToSend();



protected: //TcpCmmTask
	virtual void SendKeepAlive();
	virtual void beforeSleep();
	virtual void afterWakeUp();
	virtual void onDisConnecting();
	virtual void onLoopProc();
	virtual int onDataRecive(char *buf, int len);
	virtual void showWorkState(OutStream *strm);
protected:
	void showKObj(KObj *kObj);
	//tu powołane
	virtual void proceesObj(KObj *kObj);
public:
	KObjCmmTask(int nr);
	static TcpCmmTask* createMe(int nr);
	void showState(OutStream *strm);
public: //SvrTargetStream
	virtual void addToSend2(uint8_t devNr, uint8_t code, const void *dt1, int dt1_sz, const void *dt2, int dt2_sz);
	virtual void addToSend(uint8_t devNr, uint8_t code, const void *dt, int dt_sz);
	virtual void sendNow();
	virtual const char *getStrmName();
	virtual int getIdx();

};


class KObjSvrTask: public TcpSvrTask {
public:
	KObjSvrTask();
	void addToSendNow(uint8_t devNr, uint8_t code, const void *dt, int dt_sz);
	void addToSend(uint8_t devNr, uint8_t code, const void *dt, int dt_sz);
	void addToSend(uint8_t devNr, uint8_t code, const char *txt);
	static void UpdateLed();
};

#endif /* KOBJSVRTASK_H_ */
