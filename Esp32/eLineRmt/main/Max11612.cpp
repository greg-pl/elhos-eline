/*
 * Max11612.cpp
 *
 *  Created on: 3 kwi 2021
 *      Author: Grzegorz
 */

#include "string.h"
#include "esp_log.h"

#include "Max11612.h"
#include "I2C.h"
#include "MyConfig.h"

extern MyConfig *myConfig;

static const char *TAG = "MAX11612";

Max11612::Max11612(uint8_t adr) {
	mDevAdr = adr;
	mDevExist = false;
	mError = false;
	mMeasCnt = 0;
	mTryCnt=0;

}

void Max11612::LiczWsp(WspLin *wsp, const TKalibrDt *kalibr) {
	float x0 = kalibr->P0.valMeas;
	float y0 = kalibr->P0.valFiz;
	float x1 = kalibr->P1.valMeas;
	float y1 = kalibr->P1.valFiz;

	wsp->a = (y1 - y0) / (x1 - x0);
	wsp->b = (y0 * x1 - y1 * x0) / (x1 - x0);
}

void Max11612::afterNewcfg() {
	LiczWsp(&wsp[0], &myConfig->cfg.kalibrInp);
	LiczWsp(&wsp[1], &myConfig->cfg.kalibrVBat);
	LiczWsp(&wsp[2], &myConfig->cfg.kalibrV12);
	LiczWsp(&wsp[3], &myConfig->cfg.kalibrI12);
	ESP_LOGI(TAG, "Wsp a=%.3f b=%.3f", wsp[2].a, wsp[2].b);
}

bool Max11612::Init() {
	memset(&measRec, 0, sizeof(measRec));
	mDevExist = checkDevExist(mDevAdr);
	if (!mDevExist)
		mDevExist = checkDevExist(mDevAdr);
	if (!mDevExist) {
		ESP_LOGE(TAG, "Init,devNoExist ");
		return false;

	}
	bool q = writeReg2(mDevAdr, 0x07, 0x82);
	mError = !q;

	afterNewcfg();

	return q;
}

void Max11612::makeMeas() {
	uint8_t buf[8];
	bool q = readReg(mDevAdr, buf, sizeof(buf));
	if (q) {
		for (int i = 0; i < 4; i++) {
			measRec.tab[measRec.mTabPtr].chn[i] = ((buf[2 * i + 0] << 8) | buf[2 * i + 1]) & 0x0FFF;
		}
		if (++measRec.mTabPtr >= MEAS_CNT) {
			measRec.mTabPtr = 0;
			measRec.tickZero = esp_log_timestamp();
		}

		mMeasCnt++;
	}
	mTryCnt++;

}

void Max11612::decMeasPtr(int *pv) {
	int a = *pv;
	if (a == 0)
		a = MEAS_CNT;
	a--;
	*pv = a;
}

void Max11612::getMeasEx(MeasRecEx *rec) {

	int tab[AN_CNT];
	for (int i = 0; i < AN_CNT; i++) {
		tab[i] = 0;
	}

	int ptr = measRec.mTabPtr;
	for (int i = 0; i < 32; i++) {
		decMeasPtr(&ptr);
		for (int k = 0; k < AN_CNT; k++) {
			tab[k] += measRec.tab[ptr].chn[k];
		}
	}

	for (int i = 0; i < AN_CNT; i++) {
		int v = tab[i] / 32;
		rec->tab[i].proc = 100.0 * v / 4096;
		rec->tab[i].fiz = rec->tab[i].proc * wsp[i].a + wsp[i].b;
	}
}

void Max11612::getMeasExp(MeasExp *m) {
	int tab[AN_CNT];

	for (int i = 0; i < AN_CNT; i++) {
		tab[i] = 0;
	}

	int ptr;
	uint32_t tm;
	do {
		ptr = measRec.mTabPtr;
		tm = measRec.mTabPtr;
	} while (ptr != measRec.mTabPtr);
	tm += (ptr * MEAS_PERIOD);
	tm -= ((MEAS_EXP_CNT - 1) * MEAS_PERIOD); //

	if (ptr<0)
	ptr += tm -= (MEAS_PERIOD * ptr);

	for (int i = 0; i < MEAS_EXP_CNT; i++) {
		decMeasPtr(&ptr);
		for (int k = 0; k < AN_CNT; k++) {
			tab[k] += measRec.tab[ptr].chn[k];
		}
		uint16_t w = measRec.tab[ptr].chn[0];
		float pr = 100.0 * w / 4096;
		m->inp[i] = pr * wsp[0].a + wsp[0].b;
	}

	for (int i = 0; i < AN_CNT; i++) {
		int v = tab[i] / MEAS_EXP_CNT;
		m->tabProc[i] = 100.0 * v / 4096;
		m->tabFiz[i] = m->tabProc[i] * wsp[i].a + wsp[i].b;
	}
	m->time = tm;
}

bool Max11612::menu(char ch) {
	switch (ch) {
	case 'I':
		Init();
		break;
	case 's':
		printf("DevAdr: 0x%02X\n", mDevAdr);
		printf("chipOk: %u\n", mDevExist);
		printf("Error: %u\n", mError);
		break;
	case 'm': {
		printf("TryCnt=%d\n", mTryCnt);
		printf("MeasCnt=%d\n", mMeasCnt);
		printf("MeasPtr=%d\n", measRec.mTabPtr);
		MeasRecEx rec;
		getMeasEx(&rec);
		printf("Input  : %.1f[%%]  %.3f\n", rec.tab[0].proc, rec.tab[0].fiz);
		printf("napBat : %.1f[%%]  %.3f[V]\n", rec.tab[1].proc, rec.tab[1].fiz);
		printf("nap12V : %.1f[%%]  %.3f[V]\n", rec.tab[2].proc, rec.tab[2].fiz);
		printf("prad12V: %.1f[%%]  %.3f[A]\n", rec.tab[3].proc, rec.tab[3].fiz);

	}
		break;

	case 27:
		return true;
	default:
		printf("____MAX11612 menu____\n"
				"I - init\n"
				"s - show status\n"
				"m - make measure\n"

				"1,2,3 - Lcd test1\n");
	}
	return false;
}
