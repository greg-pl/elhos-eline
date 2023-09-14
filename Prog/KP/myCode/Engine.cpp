/*
 * Engine.cpp
 *
 *  Created on: 25 kwi 2021
 *      Author: Grzegorz
 */

#include <string.h>
#include <Engine.h>
#include <UMain.h>
#include <math.h>

#include <hdw.h>

enum {
#include "ServiceCommon.ctg"
};

extern Config *config;

//-------------------------------------------------------------------------------------------------------------------------
// Internal ADC, czytanie pinów cyfrowych jako analogowe
//-------------------------------------------------------------------------------------------------------------------------
extern ADC_HandleTypeDef hadc1;
DigInput::DinAdcData DigInput::dinDt;

void DigInput::init() {
	//reszta inicjalizacji zostala zrobiona przez CubeMX
	doAfterNewCfg();
}

void DigInput::doAfterNewCfg() {
	for (int i = 0; i < Hdw::DIN_CNT; i++) {
		bool asAc = config->data.R.B.BinAsAcCfg.inp[i].Enab;
		dinDt.dinCh[i].asAc = asAc;
		Hdw::setDINAsAnalog(i, asAc);
		dinDt.dinCh[i].lewL = (uint16_t) (4096 * config->data.R.B.BinAsAcCfg.inp[i].RLow / 100);
		dinDt.dinCh[i].lewH = (uint16_t) (4096 * config->data.R.B.BinAsAcCfg.inp[i].RHigh / 100);
		dinDt.dinCh[i].filtrOn = false;
	}
}

//filtr_tm - czas w milisekundach
void DigInput::onfiltr(uint8_t ch, int filtr_tm) {
	onfiltr(ch, filtr_tm, filtr_tm);
}

void DigInput::onfiltr(uint8_t ch, int filtr_tm_up, int filtr_tm_dn) {

	if (ch < Hdw::DIN_CNT) {
		dinDt.dinCh[ch].filtrOn = true;
		dinDt.dinCh[ch].filtr_cfg_up = 2 * filtr_tm_up;
		dinDt.dinCh[ch].filtr_cfg_dn = 2 * filtr_tm_dn;

		dinDt.dinCh[ch].filtr_cnt = 0;
	}
}

//wywoływana z przerwania TIM2 co  500[usek]
void DigInput::StartMeasure() {
	memset(dinDt.buffer, 0, sizeof(dinDt.buffer));
	HAL_ADC_Start_DMA(&hadc1, (uint32_t*) (dword) &dinDt.buffer, sizeof(dinDt.buffer) / sizeof(short int));
	dinDt.startTick = HAL_GetTick();
}

//wywoływana z przerwania końca obsługi DMA co 500[usek]
void DigInput::ADC_Complete(ADC_HandleTypeDef *hadc) {
	HAL_ADC_Stop(&hadc1);
	dinDt.workTick = HAL_GetTick() - dinDt.startTick;

	for (int chNr = 0; chNr < Hdw::DIN_CNT; chNr++) {
		DinChannel *ch = &dinDt.dinCh[chNr];
		bool state = ch->state;
		if (ch->asAc) {
			int sum = 0;
			for (int i = 0; i < ADC_SAMPL_CNT; i++) {
				sum += dinDt.buffer[i].tab[chNr];
			}
			ch->avr = sum / ADC_SAMPL_CNT;
			if (!state) {
				if (ch->avr > ch->lewH)
					state = true;
			} else {
				if (ch->avr < ch->lewL)
					state = false;
			}
		} else {
			state = Hdw::getDIN(chNr);
		}
		Hdw::setDL(chNr, state);
		if (ch->state != state)
			dinDt.dinChg = true;

		ch->state = state;
		if (ch->filtrOn) {
			if (ch->filtr_state != state) {
				ch->filtr_cnt++;
				bool q;
				if (!ch->filtr_state)
					q = (ch->filtr_cnt >= ch->filtr_cfg_up);
				else
					q = (ch->filtr_cnt >= ch->filtr_cfg_dn);
				if (q) {
					ch->filtr_state = state;
				}
			} else {
				if (ch->filtr_cnt != 0) {
					ch->filtr_cnt--;
				}
			}
		}
	}
	dinDt.rdy = true;
	dinDt.smplCnt++;
}

bool DigInput::getDinChg() {
	bool q = dinDt.dinChg;
	dinDt.dinChg = false;
	return q;
}

void DigInput::showState(OutStream *strm) {

	if (strm->oOpen(colWHITE)) {
		strm->oMsg("smplCnt=%u", dinDt.smplCnt);
		strm->oMsg("workTm=%u[ms]", dinDt.workTick);

		for (int i = 0; i < Hdw::DIN_CNT; i++) {
			if (dinDt.dinCh[i].asAc)
				strm->oMsg("DIN[%i]=%u Avr=%.1f[%%]", i, dinDt.dinCh[i].state, getDinAvr(i));
			else
				strm->oMsg("DIN[%i]=%u ", i, dinDt.dinCh[i].state);
		}
		strm->oClose();
	}
}

float DigInput::getSpeed(Side side) {
	return 0.0; //todo
}

void DigInput::tick() {

}

extern "C" void HAL_ADC_ConvCpltCallback(ADC_HandleTypeDef *hadc) {
	DigInput::ADC_Complete(hadc);
}

//-------------------------------------------------------------------------------------------------------------------------
// AnInput
//-------------------------------------------------------------------------------------------------------------------------
extern SPI_HandleTypeDef hspi1;

AnInput::SpiRec AnInput::spiRec;

// Numery kanałów zgodnie z TABELA I w dokumentacji ADS8344
const uint8_t TxData[] = {
		0x87, 0x00, 0x00, 0x00, //
		0xC7, 0x00, 0x00, 0x00, //
		0x97, 0x00, 0x00, 0x00, //
		0xD7, 0x00, 0x00, 0x00, //
		0xA7, 0x00, 0x00, 0x00, //
		0xE7, 0x00, 0x00, 0x00, //
		0xB7, 0x00, 0x00, 0x00, //
		0xF7, 0x00, 0x00, 0x00, //
		0x87, 0x00, 0x00, 0x00, //
		0xC7, 0x00, 0x00, 0x00, //
		0x97, 0x00, 0x00, 0x00, //
		0xD7, 0x00, 0x00, 0x00, //
		0xA7, 0x00, 0x00, 0x00, //
		0xE7, 0x00, 0x00, 0x00, //
		0xB7, 0x00, 0x00, 0x00, //
		0xF7, 0x00, 0x00, 0x00, //
		0x00 };

void AnInput::init() {
	memset(&spiRec, 0, sizeof(spiRec));

}

// wywoływana z przerwania TIM2 co 1[ms]
void AnInput::StartMeasure() {

	Hdw::setAcCs(1);
	HAL_SPI_TransmitReceive_DMA(&hspi1, (uint8_t*) TxData, (uint8_t*) spiRec.RxData, 64 + 1);
	spiRec.startCnt++;

}

void AnInput::SPI_Complete(SPI_HandleTypeDef *hspi) {
	spiRec.doneCnt++;
	Hdw::setAcCs(0);
	if (spiRec.wrPtr < CHANNEL_DATA_LEN) {
		uint8_t bIdx = spiRec.setNr;
		uint8_t ptr = spiRec.wrPtr;

		for (int i = 0; i < 8; i++) {
			int aa1 = spiRec.RxDataX[0 + i];
			int aa2 = spiRec.RxDataX[8 + i];
			aa1 = swap32(aa1);
			aa2 = swap32(aa2);

			aa1 >>= 7;
			aa2 >>= 7;
			aa1 = (aa1 + aa2) >> 1; //uśrednienie dwóch próbek
#if 1
			if (i == 7)
				aa1 = spiRec.samplNr;
#endif
			spiRec.chn[i].ch_buf[bIdx][ptr] = aa1;
			spiRec.chn[i].currMeas = aa1;
		}
		spiRec.wrPtr++;
		if (spiRec.wrPtr == CHANNEL_DATA_LEN) {
			spiRec.wrPtr = 0;
			spiRec.rdySetNr = spiRec.setNr;
			spiRec.rdy = true;
			spiRec.setNr = SwSet(spiRec.setNr);
		}
		spiRec.samplNr++;
	}
}

float AnInput::getValProc(uint8_t nr) {
	return spiRec.chn[nr].proc;
}

const uint16_t* AnInput::getChBuffer(uint8_t nr) {
	return spiRec.chn[nr].ch_buf[spiRec.rdySetNr];
}

uint8_t AnInput::SwSet(uint8_t nr) {
	if (nr == 0)
		return 1;
	else
		return 0;
}

bool AnInput::getSampleByNr(int chNr, int sampleNr, uint16_t *val) {
	__disable_irq();
	int wrPtr = spiRec.wrPtr;
	int dd = spiRec.samplNr - sampleNr;
	uint8_t setNr = spiRec.setNr;
	__enable_irq();

	if ((dd >= 0) && (dd < 2 * CHANNEL_DATA_LEN - 4)) {
		int idx;

		if (dd <= wrPtr) {
			idx = wrPtr - dd;
		} else {
			dd -= wrPtr;
			if (dd <= CHANNEL_DATA_LEN) {
				idx = CHANNEL_DATA_LEN - dd;
				setNr = SwSet(setNr);
			} else {
				dd -= CHANNEL_DATA_LEN;
				idx = CHANNEL_DATA_LEN - dd;
			}
		}
		*val = spiRec.chn[chNr].ch_buf[setNr][idx];
		return true;
	} else
		return false;
}

void AnInput::tick() {
	if (spiRec.rdy) {
		spiRec.rdy = 0;
		spiRec.bufferNr++;

		uint8_t ss = spiRec.rdySetNr;
		for (int i = 0; i < Hdw::AN_CNT; i++) {
			int minV = spiRec.chn[i].ch_buf[ss][0];
			int maxV = minV;
			int suma = 0;
			for (int j = 0; j < CHANNEL_DATA_LEN; j++) {
				int v = spiRec.chn[i].ch_buf[ss][j];
				if (v > maxV)
					maxV = v;
				if (v < minV)
					minV = v;
				suma += v;
			}
			float avr = (float) suma / CHANNEL_DATA_LEN;
			float proc = 100 * avr / 65536;

			spiRec.chn[i].maxV = maxV;
			spiRec.chn[i].minV = minV;
			spiRec.chn[i].proc = proc;
			spiRec.chn[i].avrR = avr;
			spiRec.chn[i].avr = (uint16_t) avr;
		}
	}

}
void AnInput::showState(OutStream *strm) {

	if (strm->oOpen(colWHITE)) {

		strm->oMsg("StartCnt=%u", spiRec.startCnt);
		strm->oMsg("DoneCnt=%u", spiRec.doneCnt);

		strm->oMsg("-------+-------+-----+-----+---------+----------+");
		strm->oMsg("ChNr   |Max-Min| Min | Max |   AVR   | proc     |");
		strm->oMsg("-------+-------+-----+-----+---------+----------+");

		for (int i = 0; i < Hdw::AN_CNT; i++) {
			strm->oMsg("ADS[%i] | %-5u |%5u|%5u| %7.1f | %5.2f[%%] |", i, //
					spiRec.chn[i].maxV - spiRec.chn[i].minV, //
					spiRec.chn[i].minV, //
					spiRec.chn[i].maxV, //
					spiRec.chn[i].avrR, //
					spiRec.chn[i].proc);
		}
		strm->oClose();
	}

}

extern "C" void HAL_SPI_TxRxCpltCallback(SPI_HandleTypeDef *hspi) {
	AnInput::SPI_Complete(hspi);
}

//-------------------------------------------------------------------------------------------------------------------------
// BaseDev
//-------------------------------------------------------------------------------------------------------------------------
BaseDev::BaseDev() {
	mRun = 0;
	mRunMode = 0;
	mRunTick = 0;
	mSrvDevNr = 0;
	mKpService = uuMAX_DEV;
	mCfgOk = false;
	setServName("???");

}

void BaseDev::LiczWsp(WspLin *wsp, const TKalibrDt *kalibr) {
	float x0 = kalibr->P0.valMeas;
	float y0 = kalibr->P0.valFiz;
	float x1 = kalibr->P1.valMeas;
	float y1 = kalibr->P1.valFiz;

	wsp->a = (y1 - y0) / (x1 - x0);
	wsp->b = (y0 * x1 - y1 * x0) / (x1 - x0);
}

float BaseDev::LiczVal(WspLin *wsp, float x) {
	return wsp->a * x + wsp->b;
}

//  przeliczenie z procentów na kwanty
void BaseDev::convertWspToHd(WspLin *wspHd, WspLin *src) {
	wspHd->a = src->a * 100.0 / 65536;  //przeliczenie z procentów na kwanty
	wspHd->b = src->b;
}

void BaseDev::init() {

}

void BaseDev::SendActive(bool activ) {
	sendPcMsgNow(mSrvDevNr, msgServicActiv, &activ, 1);
}

void BaseDev::doStart(SvrTargetStream *trg, uint8_t mode) {

}

void BaseDev::doStop(SvrTargetStream *trg) {

}

void BaseDev::doSetRun(SvrTargetStream *trg, bool aRun, uint8_t mode) {
	if (!mCfgOk) {
		if (!mRun && aRun) {
			uint8_t err_code = 0;
			clearRunflag();
			trg->addToSend(mSrvDevNr, msgCfgError, &err_code, 1);
		}
	}
	if (mRun != aRun) {
		getOutStream()->oMsgX(colYELLOW, "%s: Run=%u Mode=%u", srvName(), aRun, mode);
	}
	bool memRun = mRun;
	mRun = aRun;
	mRunTick = HAL_GetTick();
	if (memRun != mRun) {
		mRunMode = mode;  // mode ważne tylko przy starcie
		if (mRun)
			doStart(trg, mode);
		else
			doStop(trg);
	}

}

void BaseDev::setServName(const char *nm) {
	strlcpy(mServName, nm, sizeof(mServName));
}

bool BaseDev::isMeasRun() {
	if (!mRun)
		return false;
	if (HAL_GetTick() - mRunTick > RUN_REPEAT_TM) {
		mRun = false;
	}
	return mRun;
}

void BaseDev::execKalibr(SvrTargetStream *trg, uint8_t kalibNr, float valFiz) {

}

bool BaseDev::onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len) {
	switch (cmd) {
	case msgStartMeas:
		doSetRun(trg, data[0], data[1]);
		break;
	case msgMakeKalibr: {
		float f = getFloat(&data[1]);
		execKalibr(trg, data[0], f);
	}
		break;

	default:
		return false;
	}
	return true;
}
void BaseDev::tick() {

}

//-------------------------------------------------------------------------------------------------------------------------
// BreakDev
//-------------------------------------------------------------------------------------------------------------------------
BreakDev::BreakDev(Side side) :
		BaseDev::BaseDev() {
	mSide = side;
	mSrvDevNr = dsdBREAK_L + side;
	mKpService = (KpService) (uuBREAK_L + side);
	mPressMem = false;
	mPL_state = false;
	mBufferNr = 0;
	mSampleNr = 0;
	if (side == sLeft)
		setServName("BREAK_L");
	else
		setServName("BREAK_R");
}

//false- OPEN   - otwarty klucz
//true - CLOSE  - zamknięty klucz wyjściowy
void BreakDev::setPL(bool q) {
	Hdw::setPL(mCfg.AnInutNr, q);
	mPL_state = q;
}
void BreakDev::LiczWspZero(WspLin *wsp, const TKalibrDtDblZero *kalibr, bool md) {
	TKalibrDt tmp;
	tmp.P1 = kalibr->P1;
	tmp.P0.valFiz = 0;
	if (!md)
		tmp.P0.valMeas = kalibr->Z0.InpVal_Open;
	else
		tmp.P0.valMeas = kalibr->Z0.InpVal_Close;
	LiczWsp(wsp, &tmp);
}

void BreakDev::init() {
	BaseDev::init();

	TRollDevCfg *pCfg = &config->data.R.H[mSide].RollDevCfg;

	mCfg.PressBitNr = pCfg->PressBitNr;
	mCfg.RollBitNr = pCfg->RollBitNr;
	mCfg.AnInutNr = pCfg->AnInutNr;
	mCfg.RollDiameter = pCfg->RollDiameter;
	mCfg.RollImpCnt = pCfg->RollImpCnt;

	LiczWspZero(&mCfg.wsp_open, &pCfg->Kalibr, false);
	LiczWspZero(&mCfg.wsp_close, &pCfg->Kalibr, true);

	mCfgOk = (mCfg.PressBitNr < Hdw::DIN_CNT);
	mCfgOk &= (mCfg.RollBitNr < Hdw::DIN_CNT);
	mCfgOk &= (mCfg.AnInutNr < Hdw::AN_CNT);
	mCfgOk &= (mCfg.RollImpCnt >= 1 && mCfg.RollImpCnt < Config::MAX_ROLL_IMP);
	mCfgOk &= (mCfg.RollDiameter > 0);
	mCfgOk &= (mCfg.wsp_close.a > 0);
	mCfgOk &= (mCfg.wsp_open.a > 0);
	if (mCfgOk) {
		DigInput::onfiltr(mCfg.PressBitNr, 50);
	} else {
		uint8_t err_code = 0;
		sendPcMsgNow(mSrvDevNr, msgCfgError, &err_code, 1);
	}
}

void BreakDev::doStart(SvrTargetStream *trg, uint8_t mode) {
	mSampleNr = AnInput::getSampleNr();
	mBufferNr = AnInput::getBufferNr();
	mPL_state = Hdw::getPL(mCfg.AnInutNr);
	mCfg.wsp = mCfg.wsp_open;
}

void BreakDev::execKalibr(SvrTargetStream *trg, uint8_t kalibNr, float valFiz) {
	byte repl[2];
	repl[0] = kalibNr;
	TRollDevCfg *pCfg = &config->data.R.H[mSide].RollDevCfg;

	bool mem_PL = mPL_state;

	switch (kalibNr) {
	case 0: {
//kalibracja zera;
		setPL(false);
		osDelay(400);
		float proc = AnInput::getValProc(mCfg.AnInutNr);
		pCfg->Kalibr.Z0.InpVal_Open = proc;
		setPL(true);
		osDelay(400);
		proc = AnInput::getValProc(mCfg.AnInutNr);
		pCfg->Kalibr.Z0.InpVal_Close = proc;
		repl[1] = config->save();
	}
		break;
	case 1: {
		setPL(false);
		osDelay(400);
		float proc = AnInput::getValProc(mCfg.AnInutNr);
		pCfg->Kalibr.P1.valFiz = valFiz;
		pCfg->Kalibr.P1.valMeas = proc;

		repl[1] = config->save();
	}
		break;
	default:
		repl[1] = stUnknowKalibrNr;
		break;

	}

	setPL(mem_PL);

	trg->addToSend(mSrvDevNr, msgMakeKalibr, repl, sizeof(repl));
	getOutStream()->oMsgX(colYELLOW, "%s:  KalibrPt=%u ValFiz=%f st=%u", srvName(), kalibNr, valFiz, repl[1]);
}

bool BreakDev::onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len) {
	if (BaseDev::onReciveCmd(trg, cmd, data, len))
		return true;

	switch (cmd) {
	case msgRollTurnOnWhiteL: {
		bool q = data[0];
		setPL(q);
		trg->addToSend(mSrvDevNr, msgRollTurnOnWhiteL, data, 1);
		getOutStream()->oMsgX(colYELLOW, "%s: set PL=%u", srvName(), q);

		if (!q)
			mCfg.wsp = mCfg.wsp_open;
		else
			mCfg.wsp = mCfg.wsp_close;
	}
		break;
	default:
		return false;
	}
	return true;
}

void BreakDev::tick() {
	if (mCfgOk) {
		bool press = DigInput::getDinFiltrState(mCfg.PressBitNr);
		if (press != mPressMem) {
			mPressMem = press;
			SendActive(mPressMem);
		}
		if (isMeasRun()) {
			if (mBufferNr != AnInput::getBufferNr()) {
				mBufferNr = AnInput::getBufferNr();

				const uint16_t *pBuf = AnInput::getChBuffer(mCfg.AnInutNr);
				memcpy(mRecData.buffer, pBuf, sizeof(mRecData.buffer));
				mRecData.bufferNr = mBufferNr;
				convertWspToHd(&mRecData.wsp, &mCfg.wsp);

				float v1 = AnInput::getValProc(mCfg.AnInutNr);
				mRecData.silHamowProc = v1;
				mRecData.silHamow = mCfg.wsp.a * v1 + mCfg.wsp.b;
				mRecData.speed = DigInput::getSpeed(mSide);
				mRecData.flags.bb = 0;
				mRecData.flags.pls = mPL_state;
				mRecData.flags.pressRol = mPressMem;
				sendPcMsgNow(mSrvDevNr, msgMeasData, &mRecData, sizeof(mRecData));

			}
		}
	} else {

	}
}

//-------------------------------------------------------------------------------------------------------------------------
// SuspensionDev
//-------------------------------------------------------------------------------------------------------------------------
SuspensionDev::SuspensionDev(Side side) :
		BaseDev::BaseDev() {
	mSide = side;
	mSrvDevNr = dsdSUSP_L + side;
	mKpService = (KpService) (uuSUSP_L + side);
	memset(&mCfg, 0, sizeof(mCfg));
	mDevActiv = false;
	mBufferNr = 0;
	mSampleNr = 0;
	mFilter = new DigiFiltrTm(50, 500);
	mMemQ = false;
	if (side == sLeft)
		setServName("SUSPENS_L");
	else
		setServName("SUSPENS_R");

}

void SuspensionDev::init() {
	BaseDev::init();
	mCfgOk = true;
	TSuspensionDevCfg *pCfg = &config->data.R.S[mSide].SuspensionDevCfg;

	memset(&mCfg, 0, sizeof(mCfg));

	mCfg.anInputNr = pCfg->AnInutNr;
	mCfg.DeactivTime = pCfg->DeactivTime;
	LiczWsp(&mCfg.wsp, &pCfg->KalibrLn);

	int sekOKIdx = -1;
	for (int i = 0; i < AMOR_KALIBR_CNT - 1; i++) {
		TKalibrDt kalibr;
		kalibr.P0 = pCfg->KalibrTab[i];
		kalibr.P1 = pCfg->KalibrTab[i + 1];
		if (kalibr.P0.valMeas < kalibr.P1.valMeas) {
			LiczWsp(&mCfg.tabSect[i].wsp, &kalibr);
			mCfg.tabSect[i].secEndVal = kalibr.P1.valMeas;
			mCfg.tabSect[i].Ok = true;

			TKalibrDt kalibrOdwr;

			kalibrOdwr.P0.valFiz = kalibr.P0.valMeas;
			kalibrOdwr.P0.valMeas = kalibr.P0.valFiz;
			kalibrOdwr.P1.valFiz = kalibr.P1.valMeas;
			kalibrOdwr.P1.valMeas = kalibr.P1.valFiz;

			LiczWsp(&mCfg.tabSectOdwr[i].wsp, &kalibrOdwr);
			mCfg.tabSectOdwr[i].secEndVal = kalibrOdwr.P1.valMeas;
			mCfg.tabSectOdwr[i].Ok = true;

			sekOKIdx = i;
		} else {
			break;
		}
	}
	if (sekOKIdx >= 0) {
		mCfg.tabSect[sekOKIdx].Last = true;
		mCfg.tabSectOdwr[sekOKIdx].Last = true;
	} else {
		mCfgOk = false;
	}

	float actProc = getProc(pCfg->DeadZone);
	mCfg.DeadZone = 65535 * actProc / 100.0;
	float wag = getWaga(actProc);
	getOutStream()->oMsgX(colGREEN, " %s: DeadZone=%.1f[kg] Pr=%.1f[%%] di=%u wag=%.1f[kg]", srvName(), pCfg->DeadZone, actProc, mCfg.DeadZone, wag);

	if (mCfg.anInputNr >= Hdw::AN_CNT)
		mCfgOk = false;
	if (mCfg.DeactivTime == 0)
		mCfgOk = false;
	if (mCfg.DeadZone == 0)
		mCfgOk = false;
	if (pCfg->KalibrLn.P1.valMeas == 0 || pCfg->KalibrLn.P1.valFiz == 0)
		mCfgOk = false;

	if (!mCfgOk) {
		uint8_t err_code = 0;
		sendPcMsgNow(mSrvDevNr, msgCfgError, &err_code, 1);
	} else {
		mFilter->setTimes(50, mCfg.DeactivTime);
	}

}

void SuspensionDev::execKalibr(SvrTargetStream *trg, uint8_t kalibNr, float valFiz) {
	byte repl[2];
	repl[0] = kalibNr;
	TSuspensionDevCfg *pCfg = &config->data.R.S[mSide].SuspensionDevCfg;

	osDelay(400);
	float proc = AnInput::getValProc(mCfg.anInputNr);

	switch (kalibNr) {
	case 0:
//kalibracja zera;
		pCfg->KalibrLn.P0.valFiz = valFiz;
		pCfg->KalibrLn.P0.valMeas = proc;
		repl[1] = config->save();
		break;
	case 1:
		pCfg->KalibrLn.P1.valFiz = valFiz;
		pCfg->KalibrLn.P1.valMeas = proc;
		repl[1] = config->save();
		break;
	default:
		if (kalibNr >= 10 && kalibNr < 10 + AMOR_KALIBR_CNT) {
			pCfg->KalibrTab[kalibNr - 10].valFiz = valFiz;
			pCfg->KalibrTab[kalibNr - 10].valMeas = proc;
			repl[1] = config->save();
		} else
			repl[1] = stUnknowKalibrNr;
		break;

	}

	trg->addToSend(mSrvDevNr, msgMakeKalibr, repl, sizeof(repl));
	getOutStream()->oMsgX(colYELLOW, "%s: Kalibracja  Pt=%u ValFiz=%f st=%u", srvName(), kalibNr, valFiz, repl[1]);
}

bool SuspensionDev::onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len) {
	if (BaseDev::onReciveCmd(trg, cmd, data, len))
		return true;

	switch (cmd) {
	default:
		return false;
	}
	return true;
}

float SuspensionDev::getWaga(float proc) {
	int secNr = 0;

	while (secNr < AMOR_KALIBR_CNT) {
		if ((proc < mCfg.tabSect[secNr].secEndVal) || mCfg.tabSect[secNr].Last) {
			WspLin *wsp = &mCfg.tabSect[secNr].wsp;
			return proc * wsp->a + wsp->b;
		}
		secNr++;
	}
	return 0;
}

float SuspensionDev::getProc(float waga) {
	int secNr = 0;

	while (secNr < AMOR_KALIBR_CNT) {
		if ((waga < mCfg.tabSectOdwr[secNr].secEndVal) || mCfg.tabSectOdwr[secNr].Last) {
			WspLin *wsp = &mCfg.tabSectOdwr[secNr].wsp;
			return waga * wsp->a + wsp->b;
		}
		secNr++;
	}
	return 0;

}

void SuspensionDev::tick() {
	if (mCfgOk) {
		if (mSampleNr != AnInput::getSampleNr()) {
			mSampleNr = AnInput::getSampleNr();
			uint32_t avr = AnInput::getAvr(mCfg.anInputNr);
			bool q = (avr > mCfg.DeadZone);
			if (q != mMemQ) {
				getOutStream()->oMsgX(colCYAN, "%s: Q=%u TT=%u ", srvName(), q, HAL_GetTick());
				mMemQ = q;
			}

			mFilter->input(q);
			if (mDevActiv != mFilter->val()) {
				mDevActiv = mFilter->val();
				SendActive(mDevActiv);
				getOutStream()->oMsgX(colGREEN, "%s: DevActiv=%u TT=%u ", srvName(), mDevActiv, HAL_GetTick());

			}
		}
	}

//wysyłanie danych
	if (isMeasRun()) {
		if (mBufferNr != AnInput::getBufferNr()) {
			mBufferNr = AnInput::getBufferNr();

			if (mCfgOk) {
				mRecData.bufferNr = AnInput::getBufferNr();
				float v1 = AnInput::getValProc(mCfg.anInputNr);
				mRecData.proc = v1;
				mRecData.wychyl = mCfg.wsp.a * v1 + mCfg.wsp.b;
				mRecData.waga = getWaga(v1);
				convertWspToHd(&mRecData.wsp, &mCfg.wsp);
				mRecData.flags.bb = 0;
				mRecData.flags.aktiv = mDevActiv;

				const uint16_t *pBuf = AnInput::getChBuffer(mCfg.anInputNr);
				memcpy(mRecData.buffer, pBuf, sizeof(mRecData.buffer));
				sendPcMsgNow(mSrvDevNr, msgMeasData, &mRecData, sizeof(mRecData));

			}
		} else {
			// dane w przypadku niepoprawnej konfiguracji
			if (mCfg.anInputNr < Hdw::AN_CNT) {
				KSuspensDataRecErrCfg dt;
				dt.bufferNr = AnInput::getBufferNr();
				dt.anProc = AnInput::getValProc(mCfg.anInputNr);
				sendPcMsgNow(mSrvDevNr, msgMeasDataNoCfg, &dt, sizeof(dt));
			}

		}
	}

}

//-------------------------------------------------------------------------------------------------------------------------
// SlipSideDev
//-------------------------------------------------------------------------------------------------------------------------
SlipSideDev::SlipSideDev() :
		BaseDev::BaseDev() {
	mSrvDevNr = dsdSLIP_SIDE;
	mKpService = uuSLIP_SIDE;
	setServName("SLIP_SIDE");
	mNajazdFiltr = new DigiFiltrTm(10);
	mZjazdFiltr = new DigiFiltrTm(10);
	mDtLevelFiltr = new DigiFiltrTm(10);
	mZeroShift = 0;
	mDevActiv = false;
	mEndActivTick = HAL_GetTick();
	mStartActivTick = 0;
	mMeasStatus = sslOK;
}

void SlipSideDev::init() {
	BaseDev::init();

	TSlipSideDevCfg *pCfg = &config->data.R.L.SlipSideDevCfg;

	mCfg.anInputNr = pCfg->AnInutNr;
	mCfg.digNajazdNr = pCfg->PressNajazdNr;
	mCfg.digZjazdNr = pCfg->PressZjazdNr;

	mCfg.typPlyty = pCfg->TypPlyty;

	mCfg.negNajazdSensor = pCfg->InvertNajazd;
	mCfg.negZjazdSensor = pCfg->InvertZjazd;

	LiczWsp(&mCfg.wsp, &pCfg->Kalibr);
	mCfg.deadZone = pCfg->DeadZone; // wartość w [mm]
	mCfg.maxStartZeroShift = pCfg->MaxStartZeroShift;
	mCfg.maxFlip = pCfg->MaxMeasFlip;
	mCfg.maxMeasTime = (uint32_t) (1000 * pCfg->MaxMeasTime);
	mCfg.minMeasTime = (uint32_t) (1000 * pCfg->MinMeasTime);
	mCfg.maxFliptTme = (uint32_t) (1000 * pCfg->MaxFlipTime);

	mCfg.deActiveTime = (uint32_t) (1000 * pCfg->DeActivtime);

	mCfgOk = (mCfg.anInputNr < Hdw::AN_CNT);
	switch (mCfg.typPlyty) {
	case 0:
		mCfgOk &= (mCfg.deadZone > 0);
		mCfgOk &= (mCfg.maxFliptTme > 0);
		break;
	case 1:
		mCfgOk &= (mCfg.digNajazdNr < Hdw::DIN_CNT);
		break;
	case 2:
		mCfgOk &= (mCfg.digNajazdNr < Hdw::DIN_CNT);
		mCfgOk &= (mCfg.digZjazdNr < Hdw::DIN_CNT);
		break;
	}
	if (!mCfgOk) {
		uint8_t err_code = 0;
		sendPcMsgNow(mSrvDevNr, msgCfgError, &err_code, 1);
	} else {
		mDtLevelFiltr->setTimes(10, mCfg.maxFliptTme);

	}

}

void SlipSideDev::doStart(SvrTargetStream *trg, uint8_t mode) {
	mSampleNr = AnInput::getSampleNr();
	mBufferNr = AnInput::getBufferNr();
	mDevActiv = false;
	mMeasStatus = sslOK;
	mWychylMaxPlus = 0;
	mWychylMaxMinus = 0;

}

void SlipSideDev::execKalibr(SvrTargetStream *trg, uint8_t kalibNr, float valFiz) {
	byte repl[2];
	repl[0] = kalibNr;
	TSlipSideDevCfg *pCfg = &config->data.R.L.SlipSideDevCfg;

	osDelay(400);
	float proc = AnInput::getValProc(mCfg.anInputNr);

	switch (kalibNr) {
	case 0:
		pCfg->Kalibr.P0.valFiz = valFiz;
		pCfg->Kalibr.P0.valMeas = proc;
		repl[1] = config->save();
		break;
	case 1:
		pCfg->Kalibr.P1.valFiz = valFiz;
		pCfg->Kalibr.P1.valMeas = proc;
		repl[1] = config->save();
		break;
	default:
		repl[1] = stUnknowKalibrNr;
		break;

	}
	trg->addToSend(mSrvDevNr, msgMakeKalibr, repl, sizeof(repl));
	getOutStream()->oMsgX(colYELLOW, "%s:  KalibrPt=%u ValFiz=%f st=%u", srvName(), kalibNr, valFiz, repl[1]);
}

bool SlipSideDev::onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len) {
	if (BaseDev::onReciveCmd(trg, cmd, data, len))
		return true;

	switch (cmd) {
	case msgSlipSideSetZeroShift: {

		mZeroShift = LiczVal(&mCfg.wsp, AnInput::getValProc(mCfg.anInputNr));
		if (abs(mZeroShift) > mCfg.maxStartZeroShift) {
			mMeasStatus = sslMaxStartShiftExceeded;
		}
		uint8_t b = mMeasStatus;
		trg->addToSend(mSrvDevNr, msgSlipSideSetZeroShift, &b, 1);
		getOutStream()->oMsgX(colYELLOW, "%s: ZeroShift=%.1f[mm] st=%d", srvName(), mZeroShift, b);

	}
		break;
	default:
		return false;
	}
	return true;
}

void SlipSideDev::tick() {
	if (mCfgOk) {

		switch (mCfg.typPlyty) {
		case 2: {
			bool q = DigInput::getDinState(mCfg.digZjazdNr);
			if (mCfg.negZjazdSensor)
				q = !q;
			mZjazdFiltr->input(q);
		}
		case 1: {
			bool q = DigInput::getDinState(mCfg.digNajazdNr);
			if (mCfg.negNajazdSensor)
				q = !q;
			mNajazdFiltr->input(q);
		}
			break;
		}

		if (mSampleNr != AnInput::getSampleNr()) {
			mSampleNr = AnInput::getSampleNr();

			float wych = LiczVal(&mCfg.wsp, AnInput::getValProc(mCfg.anInputNr)) - mZeroShift;

			if (mCfg.typPlyty == 0) {
				float dWychAbs = abs(wych);
				bool q = (dWychAbs > mCfg.deadZone);
				mDtLevelFiltr->input(q);
			}

			if (mDevActiv) {
				if (wych < mWychylMaxMinus)
					mWychylMaxMinus = wych;
				if (wych > mWychylMaxPlus)
					mWychylMaxPlus = wych;
			}

		}

		bool memAct = mDevActiv;
		switch (mCfg.typPlyty){
		case 0:
			mDevActiv = mDtLevelFiltr->val();
			break;
		case 1:
			mDevActiv = mNajazdFiltr->val();
			break;
		case 2:
			if (mNajazdFiltr->val()) {
				mDevActiv = true;
			}
			if (mZjazdFiltr->val()) {
				mDevActiv = false;
			}
			break;
		}

		bool flMeasEnd = false;
		if (memAct != mDevActiv) {
			if (mDevActiv) {
				mStartActivTick = HAL_GetTick();
				mMeasStatus = sslOK;
				mWychylMaxPlus = 0;
				mWychylMaxMinus = 0;
				SendActive(true);
			} else {
				mEndActivTick = HAL_GetTick();
				flMeasEnd = true;
				if (HAL_GetTick() - mStartActivTick < mCfg.minMeasTime) {
					if (mMeasStatus == sslOK) {
						mMeasStatus = sslTimeTooShort;
					}
				}
			}
		}

		if (mDevActiv) {
			if (HAL_GetTick() - mStartActivTick > mCfg.maxMeasTime) {
				if (mMeasStatus == sslOK) {
					mMeasStatus = sslTimeTooLong;
				}
				flMeasEnd = true;
			}
		}

		if (flMeasEnd) {
			float maxWychyl = 0;

			if (mMeasStatus == sslOK) {
				float aMinus = abs(mWychylMaxMinus);
				float aPlus = abs(mWychylMaxPlus);
				float divM;

				if (aPlus > aMinus) {
					maxWychyl = mWychylMaxPlus;
					divM = 100 * aMinus / aPlus;
				} else {
					maxWychyl = mWychylMaxMinus;
					divM = 100 * aPlus / aMinus;
				}
				if (divM > mCfg.maxFlip) {
					mMeasStatus = sslFlipExceeded;
				}
			}

			KSlipSideMeasEnd dt;

			dt.status = mMeasStatus;
			dt.measTime = (HAL_GetTick() - mStartActivTick) / 1000.0;
			dt.wychyl = maxWychyl;
			sendPcMsg(mSrvDevNr, msgSlipSideResult, &dt, sizeof(dt));

			SendActive(false);
		}

	}

//wysyłanie danych - tylko tryb eLineTest
	if (isMeasRun()) {
		if (mBufferNr != AnInput::getBufferNr()) {
			mBufferNr = AnInput::getBufferNr();

			if (mCfgOk) {
				mRecData.n.bufferNr = AnInput::getBufferNr();
				float v1 = AnInput::getValProc(mCfg.anInputNr);
				mRecData.n.proc = v1;
				mRecData.n.wychyl = LiczVal(&mCfg.wsp, v1) - mZeroShift;
				mRecData.n.startShift = mZeroShift;
				mRecData.n.flags.bb = 0;
				mRecData.n.flags.activ = mDevActiv;
				mRecData.n.flags.typPlyty = mCfg.typPlyty;
				mRecData.n.flags.isNajazdSensorActiv = mNajazdFiltr->val();
				mRecData.n.flags.isZjazdSensorActi = mZjazdFiltr->val();

				convertWspToHd(&mRecData.wsp, &mCfg.wsp);

				const uint16_t *pBuf = AnInput::getChBuffer(mCfg.anInputNr);
				memcpy(mRecData.buffer, pBuf, sizeof(mRecData.buffer));
				sendPcMsgNow(mSrvDevNr, msgMeasData, &mRecData, sizeof(mRecData));

			} else {
				// dane w przypadku niepoprawnej konfiguracji
				if (mCfg.anInputNr < Hdw::AN_CNT) {
					KSlipSideDataRecErrCfg dt;
					dt.bufferNr = AnInput::getBufferNr();
					dt.anProc = AnInput::getValProc(mCfg.anInputNr);
					sendPcMsgNow(mSrvDevNr, msgMeasDataNoCfg, &dt, sizeof(dt));
				}

			}
		}
	}

}

//-------------------------------------------------------------------------------------------------------------------------
// WeightDev
//-------------------------------------------------------------------------------------------------------------------------
WeightDev::WeightDev(Side side) :
		BaseDev::BaseDev() {
	mSide = side;
	mSrvDevNr = dsdWEIGHT_L + side;
	mKpService = (KpService) (uuWEIGHT_L + side);
	mMemBufferNr = 0;
	if (side == sLeft)
		setServName("WEIGHT_L");
	else
		setServName("WEIGHT_R");
}

void WeightDev::init() {
	BaseDev::init();
	TKalibrPt p1 = config->data.R.W[mSide].WeightDevCfg.P1;
	mCfg.wsp_a = p1.valFiz / p1.valMeas;
	for (int i = 0; i < CH_NUM; i++) {
		mCfg.anInpNr[i] = config->data.R.W[mSide].WeightDevCfg.chKalibr[i].AnInputNr;
		mCfg.anZero[i] = config->data.R.W[mSide].WeightDevCfg.chKalibr[i].AnZero;
		mCfg.wspSkali[i] = config->data.R.W[mSide].WeightDevCfg.chKalibr[i].WspSkali;
	}
}

bool WeightDev::onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len) {
	if (BaseDev::onReciveCmd(trg, cmd, data, len))
		return true;

	switch (cmd) {
	default:

		return false;
	}
	return true;
}

void WeightDev::doStart(SvrTargetStream *trg, uint8_t mode) {
	mMemBufferNr = AnInput::getBufferNr();
}

void WeightDev::execKalibr(SvrTargetStream *trg, uint8_t kalibNr, float valFiz) {
	byte repl[2];
	repl[0] = kalibNr;

	switch (kalibNr) {
	case 0:
//kalibracja zera;
		osDelay(400);
		for (int i = 0; i < CH_NUM; i++) {
			mCfg.anZero[i] = AnInput::getAvr(mCfg.anInpNr[i]);
			config->data.R.W[mSide].WeightDevCfg.chKalibr[i].AnZero = mCfg.anZero[i];
		}
		repl[1] = config->save();
		break;
	case 1: {
		osDelay(400);

		float s = 0;
		for (int i = 0; i < CH_NUM; i++) {
			uint16_t w = AnInput::getAvr(mCfg.anInpNr[i]);
			s += (mCfg.wspSkali[i] / 4) * (w - mCfg.anZero[i]);
		}
		config->data.R.W[mSide].WeightDevCfg.P1.valMeas = s;
		config->data.R.W[mSide].WeightDevCfg.P1.valFiz = valFiz;
		TKalibrPt p1 = config->data.R.W[mSide].WeightDevCfg.P1;
		mCfg.wsp_a = p1.valFiz / p1.valMeas;

		repl[1] = config->save();
	}
		break;
	default:
		repl[1] = stUnknowKalibrNr;
		break;

	}

	trg->addToSend(mSrvDevNr, msgMakeKalibr, repl, sizeof(repl));
	getOutStream()->oMsgX(colYELLOW, "%s:  KalibrPt=%u ValFiz=%f st=%u", srvName(), kalibNr, valFiz, repl[1]);
}

void WeightDev::tick() {
//waga nie zgłasza aktywności urzadzenia

	if (isMeasRun()) {
		int n = AnInput::getBufferNr();
		if (n != mMemBufferNr) {
			mMemBufferNr = n;
			KWeightData dt;

			dt.samplNr = mMemBufferNr;
			float suma = 0;
			for (int i = 0; i < CH_NUM; i++) {
				uint16_t m = AnInput::getAvr(mCfg.anInpNr[i]);
				float pr = AnInput::getValProc(mCfg.anInpNr[i]);

				float w1 = mCfg.wsp_a * (mCfg.wspSkali[i] / 4) * (m - mCfg.anZero[i]);
				dt.chnVal[i] = w1;
				dt.chnProc[i] = pr;
				suma += w1;
			}
			dt.weight = suma;
			sendPcMsgNow(mSrvDevNr, msgMeasData, &dt, sizeof(dt));
		}
	}

}

//-------------------------------------------------------------------------------------------------------------------------
// DevTab
//-------------------------------------------------------------------------------------------------------------------------
DevTab::MyData DevTab::dt;

BreakDev *breakDev[2];
SuspensionDev *suspensionDev[2];
SlipSideDev *slipSideDev;
WeightDev *weightDev[2];

void DevTab::init() {
	breakDev[sLeft] = new BreakDev(sLeft);
	breakDev[sRight] = new BreakDev(sRight);
	suspensionDev[sLeft] = new SuspensionDev(sLeft);
	suspensionDev[sRight] = new SuspensionDev(sRight);
	slipSideDev = new SlipSideDev();
	weightDev[sLeft] = new WeightDev(sLeft);
	weightDev[sRight] = new WeightDev(sRight);

	doAfterNewCfg();
}

void DevTab::tick() {
	for (int i = 0; i < uuMAX_DEV; i++) {
		if (dt.tab[i] != NULL) {
			dt.tab[i]->tick();
		}
	}
}

void DevTab::doAfterNewCfg() {
	clearDevTab();
	for (int i = 0; i < 2; i++) {
		if (config->data.R.H[i].RollDevCfg.Enabled)
			insertDev(breakDev[i]);

		if (config->data.R.S[i].SuspensionDevCfg.Enabled)
			insertDev(suspensionDev[i]);

		if (config->data.R.W[i].WeightDevCfg.Enabled)
			insertDev(weightDev[i]);
	}
	if (config->data.R.L.SlipSideDevCfg.Enabled)
		insertDev(slipSideDev);

	for (int i = 0; i < uuMAX_DEV; i++) {
		if (dt.tab[i] != NULL) {
			dt.tab[i]->init();
		}
	}

}

void DevTab::clearDevTab() {
	for (int i = 0; i < uuMAX_DEV; i++) {
		dt.tab[i] = NULL;
	}
}

void DevTab::insertDev(BaseDev *dev) {
	int typ = dev->getKpService();
	if (typ >= 0 && typ < uuMAX_DEV) {
		dt.tab[typ] = dev;
	}
}

bool DevTab::onReciveCmd(SvrTargetStream *trg, uint8_t dstDev, uint8_t cmd, uint8_t *data, int len) {
	int idx = dstDev - dsdFIRST_SERVICE;
	if (idx >= 0 && idx < uuMAX_DEV) {
		if (dt.tab[idx] != NULL) {
			return dt.tab[idx]->onReciveCmd(trg, cmd, data, len);
		}
	}
	return false;
}

//-------------------------------------------------------------------------------------------------------------------------
// Engine
//-------------------------------------------------------------------------------------------------------------------------

void Engine::tick() {

}
