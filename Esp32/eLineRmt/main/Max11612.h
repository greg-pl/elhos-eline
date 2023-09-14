/*
 * Max11612.h
 *
 *  Created on: 3 kwi 2021
 *      Author: Grzegorz
 */

#ifndef MAIN_MAX11612_H_
#define MAIN_MAX11612_H_

#include "I2C.h"
#include "MyConfig.h"

enum {
	AN_CNT = 4, //
	MEAS_CNT = 64, //
	MEAS_EXP_CNT = 5, //zak³adam wysy³anie co 100[ms], pomiary robione co 20[ms]
};

typedef struct {
	struct {
		float proc;
		float fiz;
	} tab[AN_CNT];
} MeasRecEx;

typedef struct {
	float a;
	float b;
} WspLin;

typedef struct {
	struct {
		uint16_t chn[AN_CNT];
	} tab[MEAS_CNT];
	volatile int mTabPtr;
	volatile uint32_t tickZero;
} MeasRec;

typedef struct {
	uint32_t time;
	float tabProc[AN_CNT];
	float tabFiz[AN_CNT];
	float inp[MEAS_EXP_CNT];
} MeasExp;

class Max11612: public I2CDev {
public:
private:
	enum {
		MEAS_PERIOD = 20,  //20 [ms]
	};
	WspLin wsp[AN_CNT];
	uint8_t mDevAdr;
	bool mDevExist;
	bool mError;
	int mMeasCnt;
	int mTryCnt;

	MeasRec measRec;

	static void decMeasPtr(int *pv);
	static void LiczWsp(WspLin *wsp, const TKalibrDt *kalibr);

public:
	Max11612(uint8_t adr);
	bool Init();
	void getMeasEx(MeasRecEx *rec);
	void getMeasExp(MeasExp *m);
	void makeMeas();
	void afterNewcfg();

	bool menu(char ch);
};

#endif /* MAIN_MAX11612_H_ */
