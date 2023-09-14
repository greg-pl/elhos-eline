#ifndef __MODBUS_MASTER__
#define __MODBUS_MASTER__

#include "uart.h"
#include "cmsis_os.h"
#include "IOStream.h"
#include "SvrTargetStream.h"

typedef enum {
	reqSYS=0,//
	reqCONSOLA, //
} ReqSrc;

#define MAX_VAL_CNT  5

class MdbClient;


typedef struct{
	MdbClient *client;
	SvrTargetStream *trg;
	OutStream *strm;
	uint32_t Delay;
	uint16_t Id;
	uint16_t userCmd;
}RmtParams;

typedef struct {
	ReqSrc reqSrc;
	RmtParams rmtParams;

	int mdbFun;
	uint8_t devNr;
	uint16_t regAdr;
	uint16_t regCnt;
	uint16_t val[MAX_VAL_CNT];

	uint16_t *RdVal;
	int Result;
	uint8_t repeatCnt;
} MdbReqItem;


class MdbClient {
public:
	virtual void OnModbusDone(MdbReqItem *Item)=0;
};

class ReqFifo {
private:
	enum {
		BUF_DEEP = 20, //
	};
	MdbReqItem buf[BUF_DEEP];
	int mHead;
	int mTail;
public:
	ReqFifo();
	void clear();
	MdbReqItem* getCurrWr();
	MdbReqItem* getCurrRd();
	void pop();
	void push();
};


class TModbusMaster: public TUart {
private:
	enum MdbState {
		msRDY = 0, //
		msTRANSM, //
		msDELAY, //
		msACKFUN,
		msEND, //
	};


	enum {
		INP_BUF_SIZE = 0x100, //
		SND_BUF_MAX =0x80,
		MAX_WAIT_TIME = 500, //
		TM_CHAR_DELAY = 5, //
		MAX_REP_CNT = 5, //
	};


	struct {
		uint8_t rxChar;
		int ptr;
		uint8_t buf[INP_BUF_SIZE + 1];
		uint32_t tick;
		bool FCharRecFlag;
	} rxRec;

	struct {
		bool FTransmiting;
		int FEndTransmitCnt;
		uint8_t snfBuf[SND_BUF_MAX ];
	} sndRec;


	ReqFifo *reqFifo;

	//new
	osThreadId mThreadId;
	int mDbgLevel;

	struct {
		MdbState state;
		uint32_t entryTick;
	} stateInfo;

	void writeframe(int cnt);
	int ProcessReplay();

	void SetState(MdbState aNew);
	bool ChkStateTime(uint32_t Tm);
	bool ExecFun(MdbReqItem *item);

	void clearRxRec();
	void setTxEn(bool txON);
	void SetWord(uint8_t *p, uint16_t w);
	uint16_t GetWord(const uint8_t *p);
	void fillReqForConsola(MdbReqItem *item,OutStream *strm);

protected:
	virtual void TxCpltCallback();
	virtual void RxCpltCallback();
public:
	TModbusMaster(uint8_t PortNr);
	HAL_StatusTypeDef Init(int BaudRate);

	void PushBufWrReg(RmtParams *params, uint8_t DevId, uint16_t Adr, uint16_t Val);
	void PushBufRdReg(RmtParams *params, uint8_t DevId, uint16_t Adr, uint16_t *Val);
	void tick();
	void shell(OutStream *strm, const char *cmd);

};

#endif

