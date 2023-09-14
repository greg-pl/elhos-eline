/*
 * Pilot.cpp
 *
 *  Created on: Mar 20, 2021
 *      Author: Grzegorz
 */

#include "string.h"

#include "RadioTypes.h"
#include "Config.h"
#include "UMain.h"
#include "utils.h"
#include <Token.h>
#include <ShellItem.h>
#include <Kobj.h>
#include <IOStream.h>

#include <Pilot.h>
#include <I2cFrontExp.h>
#include <Engine.h>

extern Config *config;
extern I2cFront *frontPanel; // expander I2C na płycie czołowej

int Pilot::mDebug;
uint16_t Pilot::mLastpKeySendCnt;
uint8_t Pilot::mCommandNr;
uint32_t Pilot::mSetupChannelTick;
bool Pilot::mRecivedFlag;
uint32_t Pilot::mRecivedTick;

enum {
#include  "Host.ctg"
};

extern Engine *engine;

void Pilot::Init() {
	initRFM();
	mSetupChannelTick = 0;
	mDebug = 3;

}

void Pilot::initRFM() {
	RFMCfg cfg;

	if (mSetupChannelTick == 0)
		cfg.ChannelFreq = RFM69::getChannelFreq(config->data.R.H.radioChannel);
	else
		cfg.ChannelFreq = RFM69::getChannelFreq(SETUP_CH);
	cfg.BaudRate = bd19200;
	cfg.TxPower = config->data.R.H.radioTxPower;
	cfg.PAMode = paMode1;

	RFM69::Init(&cfg);
	setLedRadio();
}

void Pilot::setLedRadio() {
	bool q = (mSetupChannelTick != 0) | mRecivedFlag;
	frontPanel->setLed(I2cFront::ledRADIO, q);
	frontPanel->updateLeds();
}

void Pilot::buildKeyText(char *txt, int max, uint16_t key) {
	int n = 0;
	if (key & 0x0001)
		n += snprintf(&txt[n], max - n, "EngL ");
	if (key & 0x0002)
		n += snprintf(&txt[n], max - n, "EngR ");
	if (key & 0x0004)
		n += snprintf(&txt[n], max - n, "EngLR ");
	if (key & 0x0008)
		n += snprintf(&txt[n], max - n, "UP ");
	if (key & 0x0010)
		n += snprintf(&txt[n], max - n, "DN ");
	if (key & 0x0020)
		n += snprintf(&txt[n], max - n, "LF ");
	if (key & 0x0040)
		n += snprintf(&txt[n], max - n, "RT ");
	if (key & 0x0080)
		n += snprintf(&txt[n], max - n, "OK ");
	if (key & 0x0100)
		n += snprintf(&txt[n], max - n, "MN ");
	if (key & 0x0200)
		n += snprintf(&txt[n], max - n, "ESC ");
}

void Pilot::execRadioRec(RadioRecord *radioRec) {
	if (pilotCheckFrame(radioRec->DataBuf, radioRec->DataLen)) {
		mRecivedFlag = true;
		mRecivedTick = HAL_GetTick();
		setLedRadio();
		Pilot_DataBegin *pBg = (Pilot_DataBegin*) radioRec->DataBuf;

		if (pBg->cmd != plcmdDATA) {
			sendPcMsg(dsdHOST, msgPilotDtEx, radioRec->DataBuf, radioRec->DataLen);
		}

		switch (pBg->cmd) {
		case plcmdDATA: {  // {P-->} ramka danych z pilota
			Pilot_DataStruct *pDt = (Pilot_DataStruct*) pBg;
			if (pDt->key_code == (pDt->n_key_code ^ 0xFFFF)) {

				if (mDebug >= MSG_ERR) {
					char keyTxt[120];
					buildKeyText(keyTxt, sizeof(keyTxt), pDt->key_code);
					char nrCheck = '!';
					if (++mLastpKeySendCnt == pDt->keySendCnt)
						nrCheck = '.';

					getOutStream()->oMsgX(colYELLOW, "PILOT: rep=%d key=0x%04X N=%u%c (%s)", pDt->repCnt, //
							pDt->key_code, pDt->keySendCnt, nrCheck, keyTxt);
				}
				mLastpKeySendCnt = pDt->keySendCnt;

				KPilotDt dt;
				dt.code = pDt->key_code;
				dt.SendCnt = pDt->keySendCnt;
				dt.repCnt = pDt->repCnt;
				dt.free[0] = 0;
				dt.free[1] = 0;
				dt.free[2] = 0;
				sendPcMsgNow(dsdHOST, msgPilotKey, &dt, sizeof(dt));
				switch (config->data.R.H.pilotBeep){
				case 1:
					engine->makeBuzzer(ssQ);
					break;
				case 2:
					engine->makeBuzzer(ssK);
					break;
				}

			} else {
				if (mDebug >= MSG_ERR) {
					getOutStream()->oMsgX(colRED, "PILOT: data error");
				}
			}
		}
			break;
		case plcmdINFO: { // {P-->} ramka informacyjna z pilota
			Pilot_InfoStruct *pInf = (Pilot_InfoStruct*) pBg;

			if (mDebug >= MSG_INFO) {
				TDATE tm;
				char tmStr[24];
				TimeTools::UnPackTime(pInf->PackTime, &tm);
				TimeTools::DtTmStr(tmStr, &tm);

				getOutStream()->oMsgX(colYELLOW, "PILOT: firm.%u.%03u  LicznikStart=%u LicznikKey=%u od %s", pInf->firmVer, pInf->firmRev, //
						pInf->startCnt, pInf->keyGlobSendCnt, tmStr);
			}
		}
			break;
		case plcmdCHIP_SN: { // {P-->} ramka informacyjna 2 z pilota
			Pilot_ChipIDStruct *pId = (Pilot_ChipIDStruct*) pBg;
			if (mDebug >= MSG_INFO) {
				getOutStream()->oMsgX(colYELLOW, "PILOT: NS: %08X.%08X.%08X", pId->ChipID[0], pId->ChipID[1], pId->ChipID[2]);
			}
		}
			break;
		case plcmdACK: { // {P-->} potwierdzenie komend
			Pilot_AckStruct *pAck = (Pilot_AckStruct*) pBg;
			if (mDebug >= MSG_INFO)
				getOutStream()->oMsgX(colYELLOW, "PILOT: CmdAck : %u cmdNr=%u err=%u", pAck->ackCmd, pAck->ackCmdNr, pAck->ackError);
			if (mSetupChannelTick != 0) {
				mSetupChannelTick = 0;
				initRFM();
			}

		}
			break;
		case plcmdEXIT_SETUP: //{P-->} informacja o wyjściu z trybu setup
			if (mDebug >= MSG_INFO) {
				getOutStream()->oMsgX(colYELLOW, "PILOT: exit main loop");
			}
			mSetupChannelTick = 0;
			initRFM();
			break;

		case plcmdSETUP: // {-->P} ramka konfiguracyjna do pilota
			if (mDebug >= MSG_ERR) {
				getOutStream()->oMsgX(colRED, "PILOT: SETUP frame");
			}
			break;
		case plcmdCLR_CNT: // {-->P} rozkaz kasowania liczników
			if (mDebug >= MSG_ERR) {
				getOutStream()->oMsgX(colRED, "PILOT: CLR_CNT frame");
			}
			break;
		case plcmdGET_INFO: // {-->P} wyślij info rekord
			if (mDebug >= MSG_ERR) {
				getOutStream()->oMsgX(colRED, "PILOT: GET_INFO frame");
			}
			break;
		case plcmdGO_SLEEP: // {-->P} uśpij pilot
			if (mDebug >= MSG_ERR) {
				getOutStream()->oMsgX(colRED, "PILOT: GoSlep");
			}
			break;
		default:
			if (mDebug >= MSG_ERR) {
				getOutStream()->oMsgX(colRED, "PILOT: UnknownFrame, code=%u", pBg->cmd);
			}
			break;
		}
	}
}

void Pilot::tick() {
	RFM69::tick();

	if (RFM69::isNewFrame()) {
		//nowe dane z pilota
		execRadioRec(&RFM69::recVar);
	}

	if (mSetupChannelTick != 0) {
		if (HAL_GetTick() - mSetupChannelTick > TIME_TO_SETUP_CH) {
			mSetupChannelTick = 0;
			initRFM();
		}
	}
	if (mRecivedFlag) {
		if (HAL_GetTick() - mRecivedTick > 100) {
			mRecivedFlag = false;
			setLedRadio();
		}
	}

}

void Pilot::sendQuerySetupChn() {
	mSetupChannelTick = HAL_GetTick();
	initRFM();

	HAL_Delay(200);

	Pilot_SetupStruct pkt;
	memset(&pkt, 0, sizeof(pkt));
	pkt.cmd = plcmdSETUP;
	pkt.channelNr = config->data.R.H.radioChannel;
	pkt.n_channelNr = ~pkt.channelNr;
	pilotBuildFrameXor(&pkt, sizeof(pkt));
	RFM69::sendPacket(PILOT_SRC_HOST, &pkt, sizeof(pkt));
}

void Pilot::sendQuery(uint8_t cmd) {
	Pilot_CmdStruct pkt;

	memset(&pkt, 0, sizeof(pkt));
	pkt.cmd = cmd;
	pkt.cmdNr = mCommandNr++;
	pkt.PackTime = 0;
	pilotBuildFrameXor(&pkt, sizeof(pkt));
	RFM69::sendPacket(PILOT_SRC_HOST, &pkt, sizeof(pkt));
}

void Pilot::sendQueryGetInfo() {
	sendQuery(plcmdGET_INFO);
}
void Pilot::sendQueryGoSleep() {
	sendQuery(plcmdGO_SLEEP);
}


void Pilot::sendQueryClrCnt(uint32_t time) {
	Pilot_CmdStruct pkt;

	memset(&pkt, 0, sizeof(pkt));
	pkt.cmd = plcmdCLR_CNT;
	pkt.cmdNr = mCommandNr++;
	pkt.PackTime = time;
	pilotBuildFrameXor(&pkt, sizeof(pkt));
	RFM69::sendPacket(PILOT_SRC_HOST, &pkt, sizeof(pkt));
}


void Pilot::execCmd(uint8_t cmd, uint32_t tm) {
	switch (cmd) {
	case kpltGET_INFO:
		sendQueryGetInfo();
		break;
	case kpltGO_SLEEP:
		sendQueryGoSleep();
		break;
	case kpltSET_SETUP:
		sendQuerySetupChn();
		break;
	case kpltCLR_CNT:
		sendQueryClrCnt(tm);
		break;
	}
}

const ShellItem menuPILOT[] = { //
		{ "s", "stan" }, //
		{ "dbg", "ustaw poziom komunikatów" }, //
		{ "init", "wykonaj init RFM69" }, //

		{ "getinfo", "wyślij rozkaz pobrania info" }, //
		{ "set_chn", "wyślij rozkaz ustawienia kanału" }, //
		{ "zero_cnt", "wyślij rozkaz zerowania liczników" }, //
		{ "sleep", "wyślij rozkaz usypienia pilota" }, //

		{ NULL, NULL } };

void Pilot::shell(OutStream *strm, const char *cmd) {
	char tok[20];
	int idx = -1;

	if (Token::get(&cmd, tok, sizeof(tok)))
		idx = findCmd(menuPILOT, tok);
	switch (idx) {
	case 0: //s
		if (strm->oOpen(colWHITE)) {
			strm->oMsg("debug=%d", mDebug);
			strm->oMsg("channel=%d", config->data.R.H.radioChannel);
			strm->oClose();
		}
		break;
	case 1:  //dbg
		Token::getAsInt(&cmd, &mDebug);
		break;
	case 2:  //init
		initRFM();
		break;
	case 3:  //getinfo
		sendQueryGetInfo();
		break;
	case 4:  //set_chn
		sendQuerySetupChn();
		break;
	case 5:  //zero_cnt
		sendQueryClrCnt(getPackTime());
		break;
	case 6:  //sleep
		sendQueryGoSleep();
		break;

	default:
		showHelp(strm, "Pilot Menu", menuPILOT);
		break;
	}

}

