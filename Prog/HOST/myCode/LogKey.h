/*
 * LogKey.h
 *
 *  Created on: Mar 15, 2021
 *      Author: Grzegorz
 */

#ifndef LOGKEY_H_
#define LOGKEY_H_

#include <uart.h>
#include "cmsis_os.h"
#include "IOStream.h"
#include "KeyLogDef.h"

typedef struct {
	TKeyLogInfoRec info;
	TKeyLogItem tab[KEYLOG_MAX_PACK_NR];
} KeyLogData;

typedef enum {
	kyUNKNOWN = 0, //
	kyACTIV = 1, //
	kyNOACTIV = 2, //
	kyERROR = 3, //
} KeyActiv;

class LogKey: public TUart {
	enum {
		nryWSPOM = 0, //wspomaganie wyjazdu
		nryKIER_KOL, // możliwość ustawienia kierunku obrotu kół
		nry4x4, // automatyka wykrywania napędu 4x4
		nryEXT_DEV, // obsługa urzadzeń zewnętrznych
		nryWEIGHT, // obsługa wagi na urządzeniu rolkowym
	};

private:
	enum {
		KEY_TIME_REPL = 1000, //
	};
	bool mDataRdOK;
	KeyLogData data;

	struct {
		int ptr;
		uint8_t recByte;
		uint32_t tick;
		TKeyLogPacket pkt;
		volatile bool pktRdy;
	} rxRec;

	struct {
		uint32_t sndTick;
		bool sending;
		TKeyLogPacket pkt;
	} txRec;

	osThreadId mThreadId;

	KeyActiv activTab[KEYLOG_MAX_PACK_NR];
	struct {
		TKeyLogQueryIn KeyLogQueryIn;
		int keyNr;
		volatile bool workFlag;
	} mGlob;

	void clearData();
	void clearRxRec();
	void sendPkt(TKeyLogPacket *pkt);

	void readKeyInfo();
	void readItemDt(int recNr);
	void execNewPkt();

	void showKeyData(OutStream *strm);
	bool isKeyDataRdy();
	void restartActivTab();
	void getKeyActivHd(int kyNr);

protected:
	virtual void TxCpltCallback();
	virtual void RxCpltCallback();

public:
	LogKey(uint8_t PortNr);
	HAL_StatusTypeDef Init();
	static const char* getKeyActivStr(KeyActiv kyActiv);

	void tick();
	void shell(OutStream *strm, const char *cmd);
	KeyActiv getGetActiv(int nr);
	const char* keyActivAsStr(KeyActiv act);
	void readAll();
	bool isDataRed() {
		return mDataRdOK;
	}
	KeyLogData* getData() {
		return &data;
	}
};

#endif /* LOGKEY_H_ */
