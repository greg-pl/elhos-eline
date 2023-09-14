/*
 * KpProcessObj.cpp
 *
 *  Created on: 24 kwi 2021
 *      Author: Grzegorz
 */

#include <string.h>

#include <KpProcessObj.h>
#include <Hdw.h>
#include <Config.h>
#include <Engine.h>

enum {
#include  "KP.ctg"
};

extern Config *config;

extern "C" bool Layer2ProcessObj(SvrTargetStream *trg, uint8_t dstDev, uint8_t cmd, uint8_t *data, int len) {
	if (dstDev == dsdKP) {
		return KpProcessObj::onReciveCmd(trg, cmd, data, len);
	} else {
		return DevTab::onReciveCmd(trg, dstDev,cmd, data, len);
	}
}

SendTest KpProcessObj::sendTest;

bool KpProcessObj::onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len) {
	switch (cmd) {
	case msgKPGetServices:          // wysłanie informacji o usługach



		break;
	case msgKPSetPLS: {                 // sterowania liniami 'biały drut' w rybie testowym
		int nr = data[0];
		bool q = data[1];
		Hdw::setPL(nr, q);
		trg->addToSend(dsdKP, msgKPSetPLS, data, 2);

	}
		break;
	case msgKPGetPLS: {
		uint8_t b = Hdw::getPLs();
		trg->addToSend(dsdKP, msgKPGetPLS, &b, 1);
	}
		break;

	case msgKPGetTestData: {
		int idx = trg->getIdx();
		bool activ = data[0];
		bool chg = (activ != sendTest.activ);
		if (activ) {
			sendTest.activ = true;
			sendTest.svr[idx].lastReqTick = HAL_GetTick();
			sendTest.svr[idx].trg = trg;
		} else {
			sendTest.svr[idx].trg = NULL;
		}
		if (chg)
			getOutStream()->oMsgX(colYELLOW, "KP: SendTestData=%u", activ);
	}
		break;

	default:
		return false;
	}
	return true;
}

void KpProcessObj::init() {
	memset(&sendTest, 0, sizeof(sendTest));

}

typedef struct __PACKED {
	float anVal[Hdw::AN_CNT];  //wartość w procentach
	uint8_t binState;
	uint8_t binAsAC;
	uint16_t free;
	struct {
		float val; //wartości w procentach
		float levelL;
		float levelH;
	} bin[Hdw::DIN_CNT];
} KpTestData;

void KpProcessObj::sendTestData() {
	KpTestData testDt;

	for (int i = 0; i < Hdw::AN_CNT; i++) {
		testDt.anVal[i] = AnInput::getValProc(i);
	}
	uint8_t asAn = 0;
	uint8_t binState = 0;

	for (int i = 0; i < Hdw::DIN_CNT; i++) {
		testDt.bin[i].val = DigInput::getDinAvr(i);
		testDt.bin[i].levelL = config->data.R.B.BinAsAcCfg.inp[i].RLow;
		testDt.bin[i].levelH = config->data.R.B.BinAsAcCfg.inp[i].RHigh;
		if (config->data.R.B.BinAsAcCfg.inp[i].Enab) {
			asAn |= (1 << i);
		}
		if (DigInput::getDinState(i))
			binState |= (1 << i);
	}
	testDt.binState = binState;
	testDt.binAsAC = asAn;
	testDt.free = 0x1717;

	//wysłanie do aktywnych
	for (int i = 0; i < TcpSvrTask::CMM_CNT; i++) {
		if (sendTest.svr[i].trg != NULL) {
			sendTest.svr[i].trg->addToSend(dsdKP, msgKPTestData, &testDt, sizeof(testDt));
		}
	}
}

void KpProcessObj::tickTestData() {
	uint32_t tt = HAL_GetTick();
	bool doSnd = false;

	if (tt - sendTest.lastSendTick > TEST_SEND_TM) {
		sendTest.lastSendTick = tt;
		doSnd = true;
		sendTest.sendFastCnt = 0;
	}

	if (DigInput::getDinChg()) {
		if (sendTest.sendFastCnt < 2) {
			sendTest.sendFastCnt++;
			doSnd = true;
		}
	}

	if (doSnd) {
		sendTestData();
	}

	//wygaszanie odbiorców
	for (int i = 0; i < TcpSvrTask::CMM_CNT; i++) {
		if (tt - sendTest.svr[i].lastReqTick > TEST_REQ_TM) {
			sendTest.svr[i].trg = NULL;
		}
	}
	bool q = false;
	for (int i = 0; i < TcpSvrTask::CMM_CNT; i++) {
		if (sendTest.svr[i].trg != NULL) {
			q = true;
			break;
		}
	}
	sendTest.activ = q;
}

void KpProcessObj::tick() {
	if (sendTest.activ) {
		tickTestData();

	}

}
