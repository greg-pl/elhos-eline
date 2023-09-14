/*
 * HostProcessObj.cpp
 *
 *  Created on: 18 kwi 2021
 *      Author: Grzegorz
 */

#include <string.h>

#include <HostProcessObj.h>
#include <KObj.h>
#include <LogKey.h>
#include <UMain.h>
#include <Pilot.h>
#include <Hdw.h>
#include <Engine.h>
#include <ErrorDef.h>

extern LogKey *logKey;
extern Engine *engine;

enum {
#include  "Host.ctg"
};


extern "C" bool Layer2ProcessObj(SvrTargetStream *trg, uint8_t dstDev, uint8_t cmd, uint8_t *data, int len) {
	if (dstDev == dsdHOST) {
		return HostProcessObj::onReciveCmd(trg, cmd, data, len);
	} else {
		return false;
	}
}

DelayedItem HostProcessObj::delayedTab[DELAYED_CNT];

void HostProcessObj::init() {
	memset(&delayedTab, 0, sizeof(delayedTab));
}

void HostProcessObj::addDelayedTask(SvrTargetStream *trg, uint8_t code) {
	for (int i = 0; i < DELAYED_CNT; i++) {
		if (delayedTab[i].trg == NULL) {
			delayedTab[i].trg = trg;
			delayedTab[i].code = code;
			delayedTab[i].startTick = HAL_GetTick();
			break;
		}
	}

}

//odbiór ramek z PC
bool HostProcessObj::onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len) {
	switch (cmd) {
	case msgRdKeyLog: // odczyt informacji z KeyLog'a
		logKey->readAll();
		addDelayedTask(trg, msgRdKeyLog);
		break;
	case msgRdMdbReg:               //
		break;
	case msgWrMdbReg:               //
		break;
	case msgHostGetOut: {
		getOutStream()->oMsgX(colYELLOW, "HostGetP");
		uint8_t pk = engine->getPKs();
		trg->addToSend(dsdHOST, msgHostGetOut, &pk, 1);
		trg->sendNow();
	}
		break;
	case msgHostSetOut: {             // posyłane fo Host'a sterowanie wyjściami out1..out6
		int pknr = data[0];
		bool state = data[1];
		getOutStream()->oMsgX(colYELLOW, "HostSetPk: nr=%u, state=%u", pknr, state);
		engine->setPk(pknr, state);
		trg->addToSend(dsdHOST, msgHostSetOut, data, 2);
		trg->sendNow();
	}
		break;
	case msgHostSterFalownik: {      // sterowanie falownikami: B0-numer_falownika, B1-Funkcja
		uint8_t falNr = data[0];
		uint8_t cmd = data[1];
		engine->SterFalownik(trg, falNr,cmd);
		getOutStream()->oMsgX(colYELLOW, "SterFalow: nr=%u, cmd=%u", falNr, cmd);
	}break;
	case msgHostBuzzer:             // Host sterowanie BUZZEREM
		engine->makeBuzzer(data[0]);
		break;
	case msgPilotCmd:               // komendy do pilota
		if (len == 1)
			Pilot::execCmd(data[0], 0);
		else
			Pilot::execCmd(data[0], getDWord(&data[1]));
		break;
	default:
		return false;
	}
	return true;
}

void HostProcessObj::tick() {
	for (int i = 0; i < DELAYED_CNT; i++) {
		if (delayedTab[i].trg != NULL) {
			DelayedItem *it = &delayedTab[i];
			switch (it->code) {
			case msgRdKeyLog: // odczyt informacji z KeyLog'a
				if (logKey->isDataRed()) {
					it->trg->addToSend(dsdHOST, msgRdKeyLog, logKey->getData(), sizeof(KeyLogData));
					getOutStream()->oMsgX(colGREEN, "%s:KeyLogData Sended", it->trg->getStrmName());
					it->trg = NULL;
				}
				if (HAL_GetTick() - it->startTick > 5000) {
					it->trg->addToSend(dsdHOST, msgRdKeyLog, NULL, 0);
					getOutStream()->oMsgX(colGREEN, "%s:KeyLogData Error", it->trg->getStrmName());
					it->trg = NULL;
				}
				break;
			}
		}
	}
}
