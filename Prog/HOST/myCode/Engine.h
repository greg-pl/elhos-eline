/*
 * Engine.h
 *
 *  Created on: 20 kwi 2021
 *      Author: Grzegorz
 */

#ifndef ENGINE_H_
#define ENGINE_H_

#include "stdint.h"
#include "SvrTargetStream.h"
#include "ModbusMaster.h"
#include "KObj.h"




enum {
	awPILOT = 1,    // awaryjne wyłaczenie po przytrzymaniu pilota
	awROLKI,      // awaryjne wyłaczenie po zjechaniu z rolek
	awPCOUT,      // awaryjne wyłaczenie po braku komunikacji z PC
	awROLKI_INFO, // awaryjne wyłaczenie po zaniku informacji z rolek
	awMODBUS_NOWORK, // awaryjne wyłaczenie zasilania falowników po braku odpowiedzi na Modbusie
};

typedef enum {
	ssK = 0, //
	ssKK, //
	ssKKK, //
	ssD, //
	ssDD, //
	ssL, //
	ssDDD, //
	ssDKKK,
	ssLL, //
	ssQ, //
	ssDKK, //
	ssQQQQ, //
} SndSign;

class FiltrInp {
private:
	enum {
		TM_FILTR = 200,
	};
	bool state;
	bool mem;
	bool chg;
	uint32_t mChgTick;
public:
	FiltrInp();
	void inp(bool q);
	bool getState() {
		return state;
	}
	bool isChg();
};

class Engine : public MdbClient {
private:
	struct {
		bool transm;
		bool run;
		int cmdInRun;
	} mFalow[2];

public:
	struct {
		uint8_t PkState;
		FiltrInp *filtrInp1;
		FiltrInp *filtrInp2;
	} state;
	bool mMotocyklMode;

	virtual void OnModbusDone(MdbReqItem *item);


	Engine();
	void tick();
	void setPk(int pknr, bool q);
	uint8_t getPKs();
	void makeBuzzer(int snd);
	void SterFalownik(SvrTargetStream *trg, uint8_t FalownDevID, uint8_t FalownCmd);
	bool IsBelkiUp();
	void AwariaOff(int awarCode);
};

#endif /* ENGINE_H_ */
