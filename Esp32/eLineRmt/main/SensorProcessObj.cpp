/*
 * SensorProcessObj.cpp
 *
 *  Created on: 8 maj 2021
 *      Author: Grzegorz
 */
#include <string.h>

#include "esp_event.h"
#include "esp_log.h"

#include "SensorProcessObj.h"
#include <MyConfig.h>
#include "Max11612.h"
#include "utils.h"
#include "UMain.h"

enum {
#include  "sensor.ctg"
};

extern MyConfig *myConfig;
extern Max11612 *max11612;

static const char *TAG = "SENS_OBJ";

extern "C" bool Layer2ProcessObj(SvrTargetStream *trg, uint8_t dstDev, uint8_t cmd, uint8_t *data, int len) {
	//ESP_LOGI(TAG, "Layer2ProcessObj dev=%u cmd=%u", dstDev, cmd);
	if (dstDev == dsdSENSOR) {
		return SensorProcessObj::onReciveCmd(trg, cmd, data, len);
	} else
		return false;
}

SendRec SensorProcessObj::sendRec;

void SensorProcessObj::execKalibr(SvrTargetStream *trg, uint8_t kalibNr, float valFiz) {
	uint8_t repl[2];
	repl[0] = kalibNr;

	if (kalibNr < 8) {
		uint8_t klbrCh = kalibNr / 2;
		uint8_t klbrItm = kalibNr - 2 * klbrCh;
		TKalibrDt *kalibr = myConfig->getKalibr(klbrCh);
		TKalibrPt *kPt;
		if (klbrItm == 0)
			kPt = &kalibr->P0;
		else
			kPt = &kalibr->P1;
		kPt->valFiz = valFiz;

		MeasRecEx rec;
		max11612->getMeasEx(&rec);

		kPt->valMeas = rec.tab[klbrCh].proc;
		myConfig->write();

	} else {
		repl[1] = stUnknowKalibrNr;
	}
	trg->addToSend(dsdSENSOR, msgSensorMakeKalibr, repl, sizeof(repl));
	ESP_LOGI(TAG, "KalibrPt=%u ValFiz=%f st=%u", kalibNr, valFiz, repl[1]);

}

bool SensorProcessObj::onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len) {
	switch (cmd) {
	case msgOnOffOut:               //   -->D sterowanie wyjœcie OUT
		Hdw::setSterOut(data[0]);
		trg->addToSend(dsdSENSOR, cmd, data, 1);
		ESP_LOGI(TAG, "SetOUT=%u", data[0]);
		break;
	case msgOnOff12V:              //   -->D sterowanie zasilaniem 12V
		Hdw::setV12(data[0]);
		trg->addToSend(dsdSENSOR, cmd, data, 1);
		ESP_LOGI(TAG, "Set12V=%u", data[0]);
		break;

	case msgSensorMakeKalibr: {
		float f = getFloat(&data[1]);
		execKalibr(trg, data[0], f);
	}
		break;
	case msgSensorStartMeas: {
		bool run = data[0];
		int idx = trg->getIdx();

		bool run_last = (sendRec.svr[idx].trg != NULL);
		if (run) {
			sendRec.svr[idx].lastReqTick = esp_log_timestamp();
			sendRec.svr[idx].trg = trg;
			sendRec.activ = true;
		} else {
			sendRec.svr[idx].trg = NULL;
		}
		if (run != run_last)
			ESP_LOGI(TAG, "StartMeas=%d", run);
	}
		break;

	default:
		return false;
	}
	return true;
}

void SensorProcessObj::init() {
	memset(&sendRec, 0, sizeof(sendRec));

}

typedef struct __PACKED {
	MeasRecEx meas;

} SensorData;

void SensorProcessObj::sendData() {
	MeasExp dt;

	max11612->getMeasExp(&dt);

	//wys³anie do zarejestrowanych jako odbiorcy
	for (int i = 0; i < TcpSvrTask::CMM_CNT; i++) {
		if (sendRec.svr[i].trg != NULL) {
			sendRec.svr[i].trg->addToSend(dsdSENSOR, msgSensorMeasData, &dt, sizeof(dt));
			//ESP_LOGI(TAG, "Send");
		}
	}
}

void SensorProcessObj::tickSendData() {
	uint32_t tt = esp_log_timestamp();
	bool doSnd = false;

	if (tt - sendRec.lastSendTick > SEND_DT_TM) {
		sendRec.lastSendTick = tt;
		doSnd = true;
		sendRec.sendFastCnt = 0;
	}

	if (doSnd) {
		sendData();
	}

	//wygaszanie odbiorców
	for (int i = 0; i < TcpSvrTask::CMM_CNT; i++) {
		if (tt - sendRec.svr[i].lastReqTick > DATA_REQ_TM) {
			sendRec.svr[i].trg = NULL;
		}
	}
	bool q = false;
	for (int i = 0; i < TcpSvrTask::CMM_CNT; i++) {
		if (sendRec.svr[i].trg != NULL) {
			q = true;
			break;
		}
	}
	sendRec.activ = q;
}

bool SensorProcessObj::isSendingMeas(){
	return sendRec.activ;
}


void SensorProcessObj::tick() {
	if (sendRec.activ) {
		tickSendData();

	}

}
