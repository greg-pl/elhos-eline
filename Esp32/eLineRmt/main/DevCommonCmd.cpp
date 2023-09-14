/*
 * DevCommonCmd.cpp
 *
 *  Created on: 16 kwi 2021
 *      Author: Grzegorz
 */

#include "esp_event.h"
#include "esp_log.h"

#include <stdint.h>
#include <string.h>
#include <stdlib.h>

#include <DevCommonCmd.h>
#include "UMain.h"
#include "MyConfig.h"
#include <KObj.h>
#include <Utils.h>
#include <CxBuf.h>

enum {
#include  "DevCommon.ctg"
};

extern MyConfig *myConfig;

typedef struct __PACKED {
	uint8_t devType;
	uint8_t hdwVer;
	VerInfo firmVer;
	uint32_t devSpecData;
	char DevID[SIZE_DEV_NAME];
	char SerialNr[SIZE_SERIAL_NR];
} DevInfo;

uint8_t DevCommonCmd::AuthBuf[0x80];

static const char *TAG = "DEVCMM";


extern "C" uint16_t getRandom16(void) {
	return 0;
}

void DevCommonCmd::sendDevInfo(SvrTargetStream *trg) {
	DevInfo devInfo;
	memset(&devInfo,0,sizeof(devInfo));

	ESP_LOGI(TAG, "sendDevInfo");
	devInfo.devType = myConfig->cfg.devType;
	devInfo.hdwVer = 1;
	//devInfo.firmVer = mSoftVer;
	strlcpy(devInfo.SerialNr, myConfig->cfg.serNumTxt, sizeof(devInfo.SerialNr));

	strlcpy(devInfo.DevID, myConfig->cfg.devID, sizeof(devInfo.DevID));
	devInfo.devSpecData = myConfig->getDevInfoSpecDevData();

	trg->addToSend(dsdDEV_COMMON, msgDevInfo, &devInfo, sizeof(devInfo));
	trg->sendNow();
}

void DevCommonCmd::sendAuthorBuf(SvrTargetStream *trg) {

	for (int i = 0; i < (int) sizeof(AuthBuf); i++) {
		AuthBuf[i] = getRandom16() & 0xff;
	}
	trg->addToSend(dsdDEV_COMMON, msgGetAuthoBuf, &AuthBuf, sizeof(AuthBuf));
	trg->sendNow();
}

void DevCommonCmd::SendKeepAlive(SvrTargetStream *trg) {
	trg->addToSend(dsdDEV_COMMON, msgKeepAlive, NULL, 0);
	trg->sendNow();
}

bool DevCommonCmd::onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len) {

	switch (cmd) {
	case msgDevInfo: //              // Informacja o karcie
		sendDevInfo(trg);
		break;
	case msgPing:         	       // Ping - odbijanie messagów
		trg->addToSend(dsdDEV_COMMON, cmd, data, len);
		trg->sendNow();
		break;
	case msgExecReset:	           // wykonaj reset karty
		ESP_LOGI(TAG, "*** R E S E T ***");
		restartMe(500);
		break;
	case msgKeepAlive:              // komunikat o poprawnej pracy łącza PC-USB
		trg->addToSend(dsdDEV_COMMON, msgKeepAlive, NULL, 0);
		break;
	case msgGetAuthoBuf:	           // pobranie  bufora do autoryzacji
		sendAuthorBuf(trg);
		break;
	case msgSetAuthoRepl:           // wstawienie bufora autoryzującego

		break;
	case msgSynchTime:              // Synchronizacja czasu

		break;
	case msgGetCfg: {                 // pobranie konfiguracji
		CxBuf *cxBuf = myConfig->getCxBufWithCfgBin();
		trg->addToSend(dsdDEV_COMMON, cmd, cxBuf->mem(), cxBuf->len());
		trg->sendNow();
		free(cxBuf);
	}
		break;
	case msgSetCfg: {                 // ustawienie konfiguracji
		uint8_t st = myConfig->setFromKeyBin(data, len);
		trg->addToSend(dsdDEV_COMMON, cmd, &st, 1);
		trg->sendNow();
	}
		break;
	case msgGetCfgHistory: {
		MemInfo memInfo;
		myConfig->getHistMemInfo(&memInfo);
		trg->addToSend(dsdDEV_COMMON, cmd, memInfo.mem, memInfo.size);
		trg->sendNow();
	}
		break;
	case msgGetSerialNum: {                // pobranie numeru seryjnego
		const char *txt = myConfig->getSerialNum();
		trg->addToSend(dsdDEV_COMMON, cmd, txt, strlen(txt));
		trg->sendNow();
	}
		break;

	case msgSetSerialNum: {                 //wysłanie numeru seryjnego
		uint8_t st = myConfig->setSerialNum(data, len);
		trg->addToSend(dsdDEV_COMMON, cmd, &st, 1);
		trg->sendNow();
	}
		break;
	case msgSetTime: {
	/*
		TDATE tm;
		memcpy(&tm, data, sizeof(tm));
		if (TimeTools::CheckDtTm(&tm)) {
			char buf[TimeTools::DT_TM_SIZE];
			TimeTools::DtTmStr(buf, &tm);
			ESP_LOGI(TAG,"SetTime: %s", buf);
			GlobTime::setTm(&tm);
		ESP_LOGI(TAG,"SetTime: %s", buf);
		}
*/
		ESP_LOGI(TAG,"SetTime");

	}
		break;
	default:
		return false;

	}
	//msgAddToLog

	return true;
}
