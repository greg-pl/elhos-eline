/*
 * LogKey.cpp
 *
 *  Created on: Mar 15, 2021
 *      Author: Grzegorz
 */

#include "stdlib.h"
#include <string.h>
#include <stdio.h>

#include <utils.h>
#include <Token.h>
#include <ShellItem.h>

#include <LogKey.h>
#include "main.h"
#include "UMain.h"

LogKey::LogKey(uint8_t PortNr) :
		TUart::TUart(PortNr, 8) {
	mThreadId = NULL;
	clearData();
	memset(&rxRec, 0, sizeof(rxRec));
	memset(&txRec, 0, sizeof(txRec));
	restartActivTab();
}

void LogKey::restartActivTab() {
	for (int i = 0; i < KEYLOG_MAX_PACK_NR; i++) {
		activTab[i] = kyUNKNOWN;
	}
}

HAL_StatusTypeDef LogKey::Init() {
	HAL_StatusTypeDef st = TUart::Init(9600, parityODD);
	HAL_UART_Receive_IT(&mHuart, (uint8_t*) &rxRec.recByte, 1);

	return st;
}

void LogKey::TxCpltCallback() {
	txRec.sending = false;

}
void LogKey::RxCpltCallback() {
	rxRec.tick = HAL_GetTick();
	if (rxRec.ptr < KEYLOG_PACKET_SIZE) {
		rxRec.pkt.buf[rxRec.ptr] = rxRec.recByte;
		rxRec.ptr++;
		if (rxRec.ptr == KEYLOG_PACKET_SIZE) {
			rxRec.pktRdy = true;

			if (mThreadId != NULL) {
				osSignalSet(mThreadId, SIGNAL_KEYLOG_RXPKT);
			}
		}
	}

	HAL_UART_Receive_IT(&mHuart, (uint8_t*) &rxRec.recByte, 1);

}

bool LogKey::isKeyDataRdy() {
	if (data.info.Info.ProductionDate == 0)
		return false;
	if (data.info.Info.ProductionDate == 0xffff)
		return false;
	if (data.info.Info.SerNumber == 0)
		return false;
	if (data.info.Info.SerNumber == 0xffff)
		return false;
	return true;
}

void LogKey::clearData() {
	memset(&data, 0, sizeof(data));
	mDataRdOK = false;

}

void LogKey::clearRxRec() {
	rxRec.ptr = 0;
	rxRec.pktRdy = false;
	memset(&rxRec.pkt, 0x77, sizeof(rxRec.pkt));
}

void LogKey::sendPkt(TKeyLogPacket *pkt) {
	clearRxRec();
	TCrc::Set((uint8_t*) pkt, sizeof(TKeyLogPacket) - 2);

	memcpy(&txRec.pkt, pkt, sizeof(txRec.pkt));
	writeBuf(&txRec.pkt, sizeof(TKeyLogPacket));
	txRec.sndTick = HAL_GetTick();
	txRec.sending = true;
}

void LogKey::readKeyInfo() {
	TKeyLogPacket pkt;
	memset(&pkt, 0, sizeof(pkt));
	pkt.R.Cmd = 'F';
	pkt.R.Sign = SIGN_PKT_F;
	sendPkt(&pkt);
}

//odczyt 3 elementów
void LogKey::readItemDt(int recNr) {
	TKeyLogPacket pkt;
	memset(&pkt, 0, sizeof(pkt));
	pkt.R.Cmd = 'R';
	pkt.R.Sign = SIGN_PKT_R;
	pkt.R.RecNr = recNr;
	sendPkt(&pkt);
}

void LogKey::readAll() {
	clearData();
	readKeyInfo();
}

void LogKey::getKeyActivHd(int kyNr) {
	TKeyLogPacket pkt;
	memset(&pkt, 0, sizeof(pkt));
	pkt.R.Cmd = 'Q';
	pkt.R.Sign = SIGN_PKT_Q;

	KeyLogQueryBuild(&mGlob.KeyLogQueryIn, kyNr);
	memcpy(&pkt.R.Data, &mGlob.KeyLogQueryIn, sizeof(pkt.R.Data));

	sendPkt(&pkt);
	mGlob.keyNr = kyNr;
	mGlob.workFlag = true;
	activTab[kyNr] = kyUNKNOWN;

	//oczekiwanie na odpowiedź
	int tt = HAL_GetTick();
	while (HAL_GetTick() - tt < KEY_TIME_REPL) {
		if (!mGlob.workFlag) {
			break;
		}
		osDelay(10);
	}
}

//wątek: DefaultTask
void LogKey::execNewPkt() {
	if (TCrc::Check((const uint8_t*) &rxRec.pkt, sizeof(rxRec.pkt))) {
		if (rxRec.pkt.R.RepSign == (txRec.pkt.R.Sign ^ SIGN_RPL_XOR)) {
			if (rxRec.pkt.R.Sign == SIGN_REPL_SIGN) {

				switch (rxRec.pkt.R.Cmd) {
				case 'F':
					memcpy(&data.info, rxRec.pkt.R.Data, sizeof(data.info));
					readItemDt(0);
					break;
				case 'R': {
					int recNr = rxRec.pkt.R.RecNr;
					if (recNr < KEYLOG_MAX_PACK_NR - 2) {
						memcpy(&data.tab[recNr], rxRec.pkt.R.Data, 3 * sizeof(TKeyLogItem));
					}
					recNr += 3;
					if (recNr < KEYLOG_MAX_PACK_NR) {
						readItemDt(recNr);
					} else {
						mDataRdOK = true;
						getOutStream()->oMsgX(colGREEN, "KeyLog: DataRed");
					}
				}
					break;
				case 'Q': {
					TKeyLogQueryOut *out = (TKeyLogQueryOut*) rxRec.pkt.R.Data;
					int res = KeyLogCheckQueryReply(out, &mGlob.KeyLogQueryIn);
					switch (res) {
					case keyACTIV:
						activTab[mGlob.keyNr] = kyACTIV;
						break;
					case keyNO_ACTIV:
						activTab[mGlob.keyNr] = kyNOACTIV;
						break;
					default:
					case keyBAD_RPL:
						activTab[mGlob.keyNr] = kyERROR;
						break;
					}
					mGlob.workFlag = false;
				}
					break;
				}
			} else {
				getOutStream()->oMsgX(colRED, "KeyLog: Rx-SignError");
			}
		} else {
			getOutStream()->oMsgX(colRED, "KeyLog: Rx-ReplSignError");
		}
	} else {
		getOutStream()->oMsgX(colRED, "KeyLog: CrcError");

	}

}

void LogKey::tick() {
	if (rxRec.pktRdy) {
		rxRec.pktRdy = false;
		execNewPkt();
	}
	if (txRec.sending) {
		if (HAL_GetTick() - txRec.sndTick > 500) {
			txRec.sending = false;
			getOutStream()->oMsgX(colRED, "KeyLog: timeout");
		}
	}
}
#define KNOWN_CNT 5
const char *const tabKeyLogName[KNOWN_CNT] = { "Wspom", "Kier.Kol.", "4x4", "Urz.zewn", "Waga" };

const char* LogKey::getKeyActivStr(KeyActiv kyActiv) {
	switch (kyActiv) {
	case kyUNKNOWN:
		return "???";
	case kyACTIV:
		return "ACTIV";
	case kyNOACTIV:
		return "NOACTIV";
	default:
	case kyERROR:
		return "ERROR";
	}

}

void LogKey::showKeyData(OutStream *strm) {
	if (strm->oOpen(colWHITE)) {
		strm->oMsg("Firmware : %u.%03u", data.info.Ver, data.info.Rev);
		strm->oMsg("PacketCnt: %u", data.info.PacketCnt);
		if (isKeyDataRdy()) {
			TDATE tm;
			char txt[80];
			char txt1[20];
			strm->oMsg("Ver.danych: %u", data.info.Info.Version);
			strm->oMsg("Serial nr : %u", data.info.Info.SerNumber);
			TimeTools::UnPackDate(&tm, data.info.Info.ProductionDate);
			TimeTools::DateStr(txt1, &tm);
			strm->oMsg("ProdData: %s", txt1);

			for (int i = 0; i < KEYLOG_MAX_PACK_NR; i++) {
				TKeyLogItem *item = &data.tab[i];
				int n = snprintf(txt, sizeof(txt), "%2u.", i);
				const char *pTxt = "";
				if (i < KNOWN_CNT)
					pTxt = tabKeyLogName[i];
				n += snprintf(&txt[n], sizeof(txt) - n, "%-11s", pTxt);
				n += snprintf(&txt[n], sizeof(txt) - n, "%-8s", getKeyActivStr(activTab[i]));

				switch (item->R.Mode) {
				default:
				case kmdOFF:
					n += snprintf(&txt[n], sizeof(txt) - n, "OFF");
					break;
				case kmdON:
					n += snprintf(&txt[n], sizeof(txt) - n, "ON");
					break;
				case kmdDEMO:
					TimeTools::UnPackDate(&tm, item->R.ValidDate);
					TimeTools::DateStr(txt1, &tm);
					n += snprintf(&txt[n], sizeof(txt) - n, "DEMO Cnt=%u Tm=%s", item->R.ValidCnt, txt1);
					break;
				}
				strm->oMsg(txt);
			}
		}
		strm->oClose();
	}

}

KeyActiv LogKey::getGetActiv(int kyNr) {
	if (kyNr >= 0 && kyNr < KEYLOG_MAX_PACK_NR) {
		if (!(activTab[kyNr] == kyACTIV || activTab[kyNr] == kyNOACTIV)) {
			getKeyActivHd(kyNr);
		}
		return activTab[kyNr];
	}
	return kyERROR;

}

const char *const tabKeyActivStr[] = { "UNKNOWN", "ACTIV", "4x4", "Urz.zewn", "Waga" };

const char* LogKey::keyActivAsStr(KeyActiv act) {
	switch (act) {
	case kyUNKNOWN:
		return "kyUNKNOWN";
	case kyACTIV:
		return "kyACTIV";
	case kyNOACTIV:
		return "kyNOACTIV";
	default:
	case kyERROR:
		return "kyERROR";
	}
}

const ShellItem menuLOGKEY[] = { //
		{ "s", "stan" }, //
				{ "v", "pokaż zawartość klucza" }, //
				{ "read", "czytaj zawrtość klucza" }, //
				{ "get", "sprawdź klucz" }, //
				{ "restart_tab", "restart ActivTab" }, //
				{ "rd", "czytaj rekordy danych" }, //
				{ NULL, NULL } };

void LogKey::shell(OutStream *strm, const char *cmd) {
	char tok[20];
	int idx = -1;

	if (Token::get(&cmd, tok, sizeof(tok)))
		idx = findCmd(menuLOGKEY, tok);
	switch (idx) {
	case 0: //s
		break;
	case 1: //v
		showKeyData(strm);
		break;
	case 2: //read
		readAll();
		break;
	case 3: { //get
		int nr;
		if (Token::getAsInt(&cmd, &nr)) {
			int tt = HAL_GetTick();
			KeyActiv keyActiv = getGetActiv(nr);
			tt = HAL_GetTick() - tt;
			strm->oMsgX(colWHITE, "Key[%u]:%s (tm=%d[ms])", nr, keyActivAsStr(keyActiv), tt);
		}

	}
		break;
	case 4: //restart_tab
		restartActivTab();
		break;
	case 5: { //rd
		int nr;
		if (Token::getAsInt(&cmd, &nr)) {
			readItemDt(nr);
			strm->oMsgX(colWHITE, "read item nr=%d", nr);
		}

	}

		break;

	default:
		showHelp(strm, "KeyLog Menu", menuLOGKEY);
		break;
	}

}
