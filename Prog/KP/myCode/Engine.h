/*
 * Engine.h
 *
 *  Created on: 25 kwi 2021
 *      Author: Grzegorz
 */

#ifndef ENGINE_H_
#define ENGINE_H_

#include "stdint.h"
#include "hdw.h"
#include "IOStream.h"
#include "KObj.h"
#include "SvrTargetStream.h"
#include <config.h>

class DigInput {
private:
	enum {
		ADC_SAMPL_CNT = 4, //
		ADC_RANGE = 4096,
	};

	typedef struct {
		short int tab[Hdw::DIN_CNT];
	} AdcSampl;

	typedef struct {
		bool state;
		bool asAc;
		uint16_t lewL; //wartość w kwantach
		uint16_t lewH; //wartość w kwantach
		uint16_t avr; //wartość w kwantach
		//filtr
		bool filtrOn;
		int filtr_cnt;
		int filtr_cfg_up;
		int filtr_cfg_dn;
		int filtr_state;
	} DinChannel;

	typedef struct {
		AdcSampl buffer[ADC_SAMPL_CNT];
		DinChannel dinCh[Hdw::DIN_CNT];
		uint32_t startTick;
		uint32_t workTick;
		volatile bool rdy;
		volatile int smplCnt;
		volatile bool dinChg; //zmiana na liniach ;
	} DinAdcData;

	static DinAdcData dinDt;
public:
	static void init();
	static void tick();

	static void doAfterNewCfg();
	static void StartMeasure();
	static void ADC_Complete(ADC_HandleTypeDef *hadc);

	static bool getDinState(uint8_t nr) {
		return dinDt.dinCh[nr].state;
	}
	static bool getDinFiltrState(uint8_t nr) {
		return dinDt.dinCh[nr].filtr_state;
	}

	static bool getDinChg();

	static bool getDinAsAc(uint8_t nr) {
		return dinDt.dinCh[nr].asAc;
	}
	//wartość w procentach
	static float getDinAvr(uint8_t nr) {
		return 100.0 * dinDt.dinCh[nr].avr / ADC_RANGE;
	}
	static int getSampleNr() {
		return dinDt.smplCnt;
	}
	static void showState(OutStream *strm);
	static void onfiltr(uint8_t ch, int filtr_tm);
	static void onfiltr(uint8_t ch, int filtr_tm_up, int filtr_tm_dn);

	static float getSpeed(Side side);

};
//--------------------------------------------------------------------------------
class AnInput {
private:

	typedef struct {
		volatile int startCnt;
		volatile int doneCnt;
		volatile int bufferNr;
		volatile int samplNr;

		volatile bool rdy;
		volatile uint8_t rdySetNr;
		volatile uint8_t setNr;

		int wrPtr;
		union {
			uint8_t RxData[68];
			uint32_t RxDataX[17];
		};

		struct {
			uint16_t avr;
			uint16_t currMeas; //aktualna wartość próbki
			float avrR;
			float proc; //wartość w procentach zakresu
			uint16_t minV;
			uint16_t maxV;
			uint16_t ch_buf[2][CHANNEL_DATA_LEN];
		} chn[Hdw::AN_CNT];
	} SpiRec;
	static SpiRec spiRec;
	static uint8_t SwSet(uint8_t nr);

public:
	static void init();
	static void tick();
	static void SPI_Complete(SPI_HandleTypeDef *hspi);
	static void StartMeasure();
	static void showState(OutStream *strm);

	//pobranie aktualne, uśrednionej za 100[ms] wartości procentowej
	static float getValProc(uint8_t nr);

	//pobranie adresu bufora na 100 próbek
	static const uint16_t* getChBuffer(uint8_t nr);

	//pobranie numeru bufora
	static int getBufferNr() {
		return spiRec.bufferNr;
	}

	//pobranie aktualnego numeru sampla
	static int getSampleNr() {
		return spiRec.samplNr - 1;
	}
	static uint16_t getSample(int chNr) {
		return spiRec.chn[chNr].currMeas;
	}
	//wartość średnia z poprzedniego bufora
	static uint16_t getAvr(int chNr) {
		return spiRec.chn[chNr].avr;
	}
	static int getStartCnt() {
		return spiRec.startCnt;
	}
	static int getDoneCnt() {
		return spiRec.doneCnt;
	}

	static bool getSampleByNr(int chNr, int sampleNr, uint16_t *val);

};

//--------------------------------------------------------------------------------
class BaseDev {
private:
	bool mRun;
	uint8_t mRunMode;
	uint32_t mRunTick;
	char mServName[20];

protected:
	enum {
		RUN_REPEAT_TM = 5000,
	};
	bool isMeasRun();
	const char* srvName() {
		return mServName;
	}
	void setServName(const char *nm);
	bool runMode() {
		return mRunMode;
	}

protected:
	bool mCfgOk;
	uint8_t mSrvDevNr; //zgodnie z 'Group.dsd'
	KpService mKpService;

	void SendActive(bool activ);
	virtual void execKalibr(SvrTargetStream *trg, uint8_t kalibNr, float valFiz);
	void doSetRun(SvrTargetStream *trg, bool aRun, uint8_t mode);
	virtual void doStart(SvrTargetStream *trg, uint8_t mode);
	virtual void doStop(SvrTargetStream *trg);

	static void LiczWsp(WspLin *wsp, const TKalibrDt *kalibr);
	static void convertWspToHd(WspLin *wspHd,WspLin *src);
	static float LiczVal(WspLin *wsp, float x);
	void clearRunflag() {
		mRun = false;
	}
public:
	BaseDev();
	virtual ~BaseDev() {
	}


	virtual void init();
	virtual bool onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len);
	virtual void tick();
	KpService getKpService() {
		return mKpService;
	}
};

//--------------------------------------------------------------------------------
class BreakDev: public BaseDev {
private:
	Side mSide;

	struct {
		uint8_t PressBitNr;
		uint8_t RollBitNr;
		uint8_t AnInutNr;
		float RollDiameter;
		int RollImpCnt;

		WspLin wsp_open;
		WspLin wsp_close;
		WspLin wsp;
	} mCfg;

	bool mPressMem;
	int mSampleNr;
	int mBufferNr;
	bool mPL_state;
	KRollDataRec mRecData; //rekord do wysyłania danych

	static void LiczWspZero(WspLin *wsp, const TKalibrDtDblZero *kalibr, bool md);
	void setPL(bool q);

protected:
	virtual void doStart(SvrTargetStream *trg, uint8_t mode);
	virtual void execKalibr(SvrTargetStream *trg, uint8_t kalibNr, float valFiz);
public:
	BreakDev(Side side);
	virtual ~BreakDev() {
	}
	;

	virtual void init();
	virtual bool onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len);
	virtual void tick();
};

class SuspensionDev: public BaseDev {
private:
	Side mSide;
	typedef struct {
		bool Ok;
		bool Last;
		float secEndVal; // koniec zakresu od strony przetwornika (procenty)
		WspLin wsp;
	} Sector;
	typedef struct {
		uint8_t anInputNr;
		uint16_t DeactivTime;  //czas w milisekundach odmierzany prz przejściu ze stanu aktywnego do nieaktywnego
		uint16_t DeadZone;  // rozmiar strefy martwej, wykorzystywany do wykrycia najazdu
		WspLin wsp;
		Sector tabSect[AMOR_KALIBR_CNT];
		Sector tabSectOdwr[AMOR_KALIBR_CNT];
	} Cfg;
	Cfg mCfg;
	KSuspensDataRec mRecData;
	bool mDevActiv;
	bool mMemQ;
	int mBufferNr;
	int mSampleNr;
	DigiFiltrTm *mFilter;

	float getWaga(float proc);
	float getProc(float waga);

protected:
	virtual void execKalibr(SvrTargetStream *trg, uint8_t kalibNr, float valFiz);

public:
	SuspensionDev(Side side);
	virtual ~SuspensionDev() {
	}
	;
	virtual void init();
	virtual bool onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len);
	virtual void tick();
};

class SlipSideDev: public BaseDev {
private:
	//konfiguracja
	typedef struct {
		byte typPlyty;
		bool isZjazdSensor;
		bool negNajazdSensor;
		bool negZjazdSensor;
		uint8_t anInputNr;
		uint8_t digNajazdNr;
		uint8_t digZjazdNr;
		float deadZone;       // rozmiar strefy martwej, wykorzystywany gdy nie ma czujnika najazdowego
		float maxStartZeroShift;
		float maxFlip;
		uint32_t maxMeasTime;       // zbyt długi czas pomiaru
		uint32_t minMeasTime;   //zbyt krotki czas pomiaru
		uint32_t deActiveTime;   // czas nieaktywności urządzenia po okesie aktywności
		uint32_t maxFliptTme;   // maksymalny czas przelotu płyty
		WspLin wsp;
	} Cfg;  //
	Cfg mCfg;

private:  //zmienne
	int mSampleNr;
	int mBufferNr;
	KSlipSideDataRecFull mRecData;
	DigiFiltrTm *mNajazdFiltr;
	DigiFiltrTm *mZjazdFiltr;
	DigiFiltrTm *mDtLevelFiltr;
	float mZeroShift;
	bool mDevActiv;
	SlipSideResult mMeasStatus;
	float mWychylMaxPlus;
	float mWychylMaxMinus;

	uint32_t mStartActivTick;
	uint32_t mEndActivTick;

protected:
	virtual void doStart(SvrTargetStream *trg, uint8_t mode);
	virtual void execKalibr(SvrTargetStream *trg, uint8_t kalibNr, float valFiz);
public:
	SlipSideDev();
	virtual ~SlipSideDev() {

	}
	virtual void init();
	virtual bool onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len);
	virtual void tick();
};

class WeightDev: public BaseDev {
private:
	enum {
		CH_NUM = 4,
	};
	Side mSide;
	struct {
		uint8_t anInpNr[CH_NUM];
		uint16_t anZero[CH_NUM];
		float wspSkali[CH_NUM];
		float wsp_a;
	} mCfg;
private:
	int mMemBufferNr;

protected:
	virtual void doStart(SvrTargetStream *trg, uint8_t mode);
	virtual void execKalibr(SvrTargetStream *trg, uint8_t kalibNr, float valFiz);

public:
	WeightDev(Side side);
	virtual ~WeightDev() {

	}
	;

	virtual void init();
	virtual bool onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len);
	virtual void tick();
};

//--------------------------------------------------------------------------------
class DevTab {
private:
	typedef struct {
		BaseDev *tab[uuMAX_DEV];
		int devCnt;
	} MyData;
	static MyData dt;
	static void insertDev(BaseDev *dev);
	static void clearDevTab();
public:
	static void init();
	static void tick();
	static void doAfterNewCfg();
	static bool onReciveCmd(SvrTargetStream *trg, uint8_t dstDev, uint8_t cmd, uint8_t *data, int len);

};

class Engine {
public:
	static void tick();

};

#endif /* ENGINE_H_ */
