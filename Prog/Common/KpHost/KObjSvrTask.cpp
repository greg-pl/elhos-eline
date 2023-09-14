/*
 * KObjSvrTask.cpp
 *
 *  Created on: 15 lis 2021
 *      Author: Grzegorz
 */

#include <KObjSvrTask.h>
#include <DevCommonCmd.h>

extern "C" __WEAK void updatePanelLedPC(bool q) {

}

extern "C" __WEAK void showLcdBigMsg(const char *txt) {

}

#define KOBJ_SVR_CNT 3

TcpSvrDev KObjTcpSvrDef = { //
		mPort: 9111, //
		svrCnt :KOBJ_SVR_CNT, //
		svrTaskName : "KOBJ_SVR", //
		cmmTaskName : "KOBJ", //
		getClientTask : &KObjCmmTask::createMe, //

		cmmDef : { //
				tmToAutoClose : 120 * 1000, // czas do rozłaczenia sesji z powodu braku aktywności
				tmKeepAlive :1000, // czas co który musi być coś wysłane
				tmMaxTimeInBuf :500, // maksymalny czas w buforze
				tmDataJoin : 100, //TM_DATA_JOIN = 100, // 250[ms] - czas sklejania danych
				}

		};

//----------------------------------------------------------------------------------------------
//  KObjCmmTask
//----------------------------------------------------------------------------------------------

KObjCmmTask::KObjCmmTask(int nr) :
		TcpCmmTask::TcpCmmTask(nr, 512, BUF_SIZE, BUF_SIZE) {
	base64Tool = new Base64Tool();
	memset(&txBin, 0, sizeof(txBin));
	txBin.smf.snd_mux = xSemaphoreCreateMutex();
}

TcpCmmTask* KObjCmmTask::createMe(int nr) {
	KObjCmmTask *item = new KObjCmmTask(nr);
	return (TcpCmmTask*) item;

}

const char* KObjCmmTask::getStrmName() {
	return getTaskName();
}

int KObjCmmTask::getIdx() {
	return getMyNr();
}

void KObjCmmTask::SendKeepAlive() {
	DevCommonCmd::SendKeepAlive(this);
}

void KObjCmmTask::onLoopProc() {
	if (isAnyToSend()) {
		sendBinBuf();
	}
}

void KObjCmmTask::beforeSleep() {
	KObjSvrTask::UpdateLed();
}
void KObjCmmTask::afterWakeUp() {
	KObjSvrTask::UpdateLed();

	char txt[40];
	snprintf(txt, sizeof(txt), "START:%u", getIdx() + 1);
	showLcdBigMsg(txt);
}
void KObjCmmTask::onDisConnecting() {
	char txt[40];
	snprintf(txt, sizeof(txt), "STOP:%u", getIdx() + 1);
	showLcdBigMsg(txt);
}

void KObjCmmTask::showWorkState(OutStream *strm) {
	strm->oMsg("  SumaRec:%u", mStatistic.sumaRec);
	strm->oMsg("  ErrTyp1Cnt:%u", mStatistic.errTyp1Cnt);
	strm->oMsg("  ErrTyp2Cnt:%u", mStatistic.errTyp2Cnt);
}

//semafor dostepu do bufora binarnego
bool KObjCmmTask::lockBin(int id) {
	bool q = (xSemaphoreTake(txBin.smf.snd_mux, portMAX_DELAY) == pdTRUE);
	if (q) {
		txBin.smf.lockID = id;
		txBin.smf.lockTask = uxTaskGetTaskNumber(osThreadGetId());
	}
	return q;
}

void KObjCmmTask::unlockBin() {
	txBin.smf.lockID = 0;
	txBin.smf.lockTask = 0;
	xSemaphoreGive(txBin.smf.snd_mux);
}

void KObjCmmTask::sendBinBuf() {
	if (lock(1)) {
		char *sndBuf = getSndBuf();
		int n = 0;

		if (lockBin(1)) {

			n = base64Tool->Encode(&sndBuf[1], bin_tx_buf, txBin.binPtr);
			sndBuf[0] = STX;
			sndBuf[1 + n] = ETX;
			n += 2;
			txBin.binPtr = 0;
			txBin.firstTick = 0;
			txBin.addTick = 0;
			txBin.sendTick = HAL_GetTick();
		}
		unlockBin();
		if (n > 0) {
			sendFromOwnBuf_(n);
		}
	}
	unlock();
}

bool KObjCmmTask::isAnyToSend() {
	bool q = false;
	if (lockBin(3)) {
		if (txBin.binPtr > 0) {
			uint32_t tt = HAL_GetTick();
			q = txBin.sndNow;
			q |= (tt - txBin.firstTick > KObjTcpSvrDef.cmmDef.tmMaxTimeInBuf);
			q |= (tt - txBin.addTick > KObjTcpSvrDef.cmmDef.tmDataJoin);
		}
		unlockBin();
	}
	return q;
}

void KObjCmmTask::sendNow() {
	txBin.sndNow = true;
}

void KObjCmmTask::addToSend2(uint8_t devNr, uint8_t code, const void *dt1, int dt1_sz, const void *dt2, int dt2_sz) {
	if ((dt1_sz + dt2_sz) < BUF_BIN_SIZE - (int) sizeof(KObjHead)) {

		if (lockBin(2)) {
			int sz = sizeof(KObjHead) + (dt1_sz + dt2_sz);

			if (txBin.binPtr + sz > BUF_BIN_SIZE) {
				sendBinBuf();
			}

			txBin.addTick = HAL_GetTick();
			if (txBin.binPtr == 0) {
				txBin.firstTick = txBin.addTick;
			}

			putWord(&bin_tx_buf[txBin.binPtr], sz);
			bin_tx_buf[txBin.binPtr + 2] = devNr;
			bin_tx_buf[txBin.binPtr + 3] = code;
			if (dt1_sz > 0 && dt1 != NULL) {
				memcpy(&bin_tx_buf[txBin.binPtr + 4], dt1, dt1_sz);
			}
			if (dt2_sz > 0 && dt2 != NULL) {
				memcpy(&bin_tx_buf[txBin.binPtr + 4 + dt1_sz], dt2, dt2_sz);
			}

			txBin.binPtr += sz;
		}
		unlockBin();
	} else {
		getOutStream()->oMsgX(colRED, "%s:addToSend Data too big dt_sz=%d", getTaskName(), dt1_sz + dt2_sz);
	}

}

void KObjCmmTask::addToSend(uint8_t devNr, uint8_t code, const void *dt, int dt_sz) {
	addToSend2(devNr, code, dt, dt_sz, NULL, 0);
}

void KObjCmmTask::showKObj(KObj *kObj) {
	int dt_sz = kObj->objSize - sizeof(KObjHead);
	char txt[80];
	switch (dt_sz) {
	case 1:
		snprintf(txt, sizeof(txt), "B:%u", *(uint8_t*) (&kObj->data));
		break;
	case 4:
		snprintf(txt, sizeof(txt), "I:%u", *(int*) (&kObj->data));
		break;
	default:
		snprintf(txt, sizeof(txt), "dt_sz=%u", dt_sz);
		break;
	}
	getOutStream()->oMsgX(colWHITE, "%s: Dev=%d, Code=%d <%s>", getTaskName(), kObj->dstDev, kObj->cmmCode, txt);
}

extern "C" __WEAK bool Layer2ProcessObj(SvrTargetStream *trg, uint8_t dstDev, uint8_t cmd, uint8_t *data, int len) {
	return false;
}

void KObjCmmTask::proceesObj(KObj *kObj) {
	bool q = false;
	int dt_sz = kObj->objSize - sizeof(KObjHead);
	if (kObj->dstDev == dsdDEV_COMMON) {
		q = DevCommonCmd::onReciveCmd(this, kObj->cmmCode, kObj->data, dt_sz);
	}
	if (!q) {
		q = Layer2ProcessObj(this, kObj->dstDev, kObj->cmmCode, kObj->data, dt_sz);
	}

	if (!q) {
		showKObj(kObj);
	}

}

int KObjCmmTask::onDataRecive(char *rxBuf, int len) {
//todo dorobic zabezpieczenie, w przypadku kiedy dwa pakiety w jednej paczce TCP !!!!!

	int wsk = 0;

	while (wsk < len - 2) {
		int err = 1;
		int cnt = 0;

		if (rxBuf[wsk + 0] == STX) {
			while (wsk + 1 + cnt < len) {
				if (rxBuf[wsk + 1 + cnt] == ETX) {
					err = 0;
					break;
				}
				cnt++;
			}
		} else
			err = 2;

		switch (err) {
		case 0: {
			int bn = base64Tool->Decode(bin_rx_buf, &rxBuf[wsk + 1], cnt);
			if (bn > 0) {
				if (mDebug > MSG_INFO)
					getOutStream()->oMsgX(colWHITE, "%s: Rec len=%u bn=%u", getTaskName(), len, bn);
				int ptr = 0;
				while (ptr < bn) {
					KObj *kObj = (KObj*) &bin_rx_buf[ptr];
					if (mDebug > MSG_DATA)
						getOutStream()->oMsgX(colWHITE, "%s: KObj dDev=%u code=%u", getTaskName(), kObj->dstDev, kObj->cmmCode);
					proceesObj(kObj);
					int n = kObj->objSize;
					ptr += n;
				}
			} else {
				mStatistic.errTyp1Cnt++;
				getOutStream()->oMsgX(colRED, "%s: RecError len=%u Base64Err", getTaskName(), len);
			}
			wsk += (cnt + 2);
		}
			break;
		case 1:
			// zostaje w buforze nicała ramka
			getOutStream()->oMsgX(colCYAN, "%s: Rest=%u", getTaskName(), len);
			return wsk;
		default:
			// jakis błąd, wszytko wyrzucamy
			getOutStream()->oMsgX(colRED, "%s: RecError len=%u no STX-ETX, err=%d", getTaskName(), len, err);
			mStatistic.errTyp2Cnt++;
			return len;

		}

	}
	return wsk;
//sendBuf_(tx_buffer, n);
}

//----------------------------------------------------------------------------------------------
//  KObjSvrTask
//----------------------------------------------------------------------------------------------

KObjSvrTask::KObjSvrTask() :
		TcpSvrTask::TcpSvrTask(&KObjTcpSvrDef) {

}

void KObjSvrTask::UpdateLed() {
	updatePanelLedPC(me->isAnyWorking());
}

void KObjSvrTask::addToSendNow(uint8_t devNr, uint8_t code, const void *dt, int dt_sz) {
	for (int i = 0; i < KOBJ_SVR_CNT; i++) {
		KObjCmmTask *tsk = (KObjCmmTask*) getCmmTask(i);

		if (tsk->isWorking()) {
			tsk->addToSend(devNr, code, dt, dt_sz);
			tsk->sendNow();
		}
	}
}

void KObjSvrTask::addToSend(uint8_t devNr, uint8_t code, const void *dt, int dt_sz) {
	for (int i = 0; i < KOBJ_SVR_CNT; i++) {
		KObjCmmTask *tsk = (KObjCmmTask*) getCmmTask(i);

		if (tsk->isWorking()) {
			tsk->addToSend(devNr, code, dt, dt_sz);
		}
	}
}

void KObjSvrTask::addToSend(uint8_t devNr, uint8_t code, const char *txt) {
	addToSend(devNr, code, (uint8_t*) txt, strlen(txt));
}
