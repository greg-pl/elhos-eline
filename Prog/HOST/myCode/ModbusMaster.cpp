#include "stdlib.h"
#include <string.h>
#include <stdio.h>
#include <utils.h>
#include <Token.h>

#include "ModbusMaster.h"
#include "main.h"
#include "UMain.h"
#include <ShellItem.h>
#include <Engine.h>
#include <ErrorDef.h>

#define  MDB_FUN_3     3
#define  MDB_FUN_4     4
#define  MDB_FUN_6     6
#define  MDB_FUN_16   16

extern Engine *engine;

ReqFifo::ReqFifo() {
	clear();
}
void ReqFifo::clear() {
	mHead = 0;
	mTail = 0;

}
MdbReqItem* ReqFifo::getCurrWr() {
	//sprawdzenie czy nie dogonimy ogona
	int h = mHead;
	if (++h == BUF_DEEP) {
		h = 0;
	}
	if (h != mTail) {
		MdbReqItem *item = &buf[mHead];
		memset(item, 0, sizeof(MdbReqItem));
		item->repeatCnt = 3;
		return item;
	} else
		return NULL;
}

void ReqFifo::push() {
	if (++mHead == BUF_DEEP) {
		mHead = 0;
	}
}

MdbReqItem* ReqFifo::getCurrRd() {
	if (mTail != mHead)
		return &buf[mTail];
	else
		return NULL;
}

void ReqFifo::pop() {
	if (mTail != mHead) {
		if (++mTail == BUF_DEEP) {
			mTail = 0;
		}
	}
}

TModbusMaster::TModbusMaster(uint8_t PortNr) :
		TUart::TUart(PortNr, 7) {
	memset(&sndRec, 0, sizeof(sndRec));
	memset(&rxRec, 0, sizeof(rxRec));

	stateInfo.state = msRDY;

	reqFifo = new ReqFifo();
	mThreadId = NULL;
}

HAL_StatusTypeDef TModbusMaster::Init(int BaudRate) {
	HAL_StatusTypeDef st = TUart::Init(BaudRate);
	HAL_UART_Receive_IT(&mHuart, &rxRec.rxChar, 1);
	return st;
}

void TModbusMaster::setTxEn(bool txON) {
	if (txON)
		HAL_GPIO_WritePin(TX48_EN_GPIO_Port, TX48_EN_Pin, GPIO_PIN_SET);
	else
		HAL_GPIO_WritePin(TX48_EN_GPIO_Port, TX48_EN_Pin, GPIO_PIN_RESET);
}

void TModbusMaster::RxCpltCallback() {

	rxRec.FCharRecFlag = true;
	rxRec.tick = HAL_GetTick();
	if (rxRec.ptr < INP_BUF_SIZE) {
		rxRec.buf[rxRec.ptr] = rxRec.rxChar;
		rxRec.ptr++;
	}
	HAL_UART_Receive_IT(&mHuart, &rxRec.rxChar, 1);

	if (mThreadId != NULL) {
		osSignalSet(mThreadId, SIGNAL_MDB_RXCHAR);
	}
}

void TModbusMaster::clearRxRec() {
	memset(rxRec.buf, 0, sizeof(rxRec.buf));
	rxRec.ptr = 0;
}

void TModbusMaster::TxCpltCallback() {
	TUart::TxCpltCallback();
	setTxEn(false);

	sndRec.FEndTransmitCnt++;
	sndRec.FTransmiting = false;
}

void TModbusMaster::SetWord(uint8_t *p, uint16_t w) {
	p[0] = w >> 8;
	p[1] = w & 0xff;
}

uint16_t TModbusMaster::GetWord(const uint8_t *p) {
	return (p[0] << 8) | p[1];
}

int TModbusMaster::ProcessReplay() {

	if (rxRec.ptr > 4) {
		MdbReqItem *item = reqFifo->getCurrRd();
		OutStream *strm = item->rmtParams.strm;

		bool vERR = (mDbgLevel >= 1) || (item->reqSrc == reqCONSOLA);
		bool vINFO = (mDbgLevel >= 2) || (item->reqSrc == reqCONSOLA);
		bool vDAT = (mDbgLevel >= 3) || (item->reqSrc == reqCONSOLA);

		if (TCrc::Check(rxRec.buf, rxRec.ptr)) {
			if (rxRec.buf[0] == item->devNr) {

				uint8_t rxCmd = rxRec.buf[1] & 0x7F;
				if (rxCmd == item->mdbFun) {
					if ((rxRec.buf[1] & 0x80) == 0) {
						switch (rxCmd) {
						case MDB_FUN_3:
						case MDB_FUN_4: {
							int n = rxRec.buf[2] >> 1;
							if (n != item->regCnt) {
								if (vERR) {
									strm->oMsgX(colRED, "MDB: Fun%u REPLY ERROR", rxCmd);
									return stMdbError;
								}

							} else {
								if (vDAT) {
									char txt[200];
									int m = snprintf(txt, sizeof(txt), "MDB: %04X>", item->regAdr);
									for (int i = 0; i < n; i++) {
										uint16_t w = GetWord(&rxRec.buf[3 + 2 * i]);
										m += snprintf(&txt[m], sizeof(txt) - m, "%02X,", w);
									}
									strm->oMsgX(colWHITE, txt);
								}
								if (item->rmtParams.client != NULL) {
									item->rmtParams.client->OnModbusDone(item);

								}
								//onReciveData(rxCmd, &rxRec.buf[3], n);
								return HAL_OK;
							}

						}
							break;
						case MDB_FUN_6: {
							uint16_t reg = GetWord(&rxRec.buf[2]) + 1;
							uint16_t v = GetWord(&rxRec.buf[4]);
							if ((reg == item->regAdr) && (v == item->val[0])) {
								if (vINFO)
									strm->oMsgX(colWHITE, "MDB: Fun6 ACK");
								return HAL_OK;
							} else {
								if (vERR)
									strm->oMsgX(colRED, "MDB: Fun6 ACK ERROR");
								return stMdbError;
							}
						}
							break;
						case MDB_FUN_16: {
							uint16_t reg = GetWord(&rxRec.buf[2]) + 1;
							uint16_t cnt = GetWord(&rxRec.buf[4]);
							if ((reg == item->regAdr) && (cnt == item->regCnt)) {
								if (vINFO)
									strm->oMsgX(colWHITE, "MDB: Fun16 ACK");
								return HAL_OK;
							} else {
								if (vERR)
									strm->oMsgX(colRED, "MDB: Fun16 ACK ERROR");
								return stMdbError;
							}
						}

							break;

						}
						return stMdbError;
					} else {
						int excp = rxRec.buf[2];

						if (vERR)
							strm->oMsgX(colRED, "MDB: Modbus exception %u", excp);

						switch (excp) {
						case 1:
							return stMdbErr1;
						case 2:
							return stMdbErr2;
						case 3:
							return stMdbErr3;
						case 4:
							return stMdbErr4;
						}
						return stMdbError;
					}
				} else {
					if (vERR)
						strm->oMsgX(colRED, "MDB: replay FUN not agree: %u<->%u", item->mdbFun, rxCmd);
					return stMdbError;

				}
			} else {
				if (vERR)
					strm->oMsgX(colRED, "MDB: replay DEVNR not agree: %u<->%u", item->devNr, rxRec.buf[0]);
				return stMdbError;
			}
		} else {
			return stCrcError;
		}
	} else
		return stDataErr;
}

#define DELAY_TIME 200

void TModbusMaster::SetState(MdbState aNew) {
	stateInfo.entryTick = HAL_GetTick();
	stateInfo.state = aNew;
}

bool TModbusMaster::ChkStateTime(uint32_t Tm) {
	return (HAL_GetTick() - stateInfo.entryTick >= Tm);
}

void TModbusMaster::writeframe(int cnt) {
	clearRxRec();
	sndRec.FTransmiting = true;
	rxRec.FCharRecFlag = false;
	setTxEn(true);
	TUart::writeBuf(sndRec.snfBuf, cnt);

}

bool TModbusMaster::ExecFun(MdbReqItem *item) {

	item->repeatCnt--;

	int n = -1;

	sndRec.snfBuf[0] = item->devNr;
	sndRec.snfBuf[1] = item->mdbFun;

	switch (item->mdbFun) {
	case 3:
	case 4:
		SetWord(&sndRec.snfBuf[2], item->regAdr - 1);
		SetWord(&sndRec.snfBuf[4], item->regCnt);
		n = 6;
		break;
	case 6:
		SetWord(&sndRec.snfBuf[2], item->regAdr - 1);
		SetWord(&sndRec.snfBuf[4], item->val[0]);
		n = 6;
		break;
	case 16:
		SetWord(&sndRec.snfBuf[2], item->regAdr - 1);
		SetWord(&sndRec.snfBuf[4], item->regCnt);
		sndRec.snfBuf[6] = item->regCnt << 1;
		for (int i = 0; i < item->regCnt; i++) {
			SetWord(&sndRec.snfBuf[7 + 2 * i], item->val[i]);
		}
		n = 7 + 2 * item->regCnt;
		break;
	}
	if (n > 0) {
		TCrc::Set(sndRec.snfBuf, n);
		writeframe(n + 2);
		return true;
	} else
		return false;
}

void TModbusMaster::tick() {
	uint32_t par2;

	switch (stateInfo.state) {
	case msRDY: {
		MdbReqItem *item = reqFifo->getCurrRd();
		if (item != NULL) {
			if (ExecFun(item)) {
				SetState(msTRANSM);
			} else {
				SetState(msEND);
			}
		}
	}
		break;
	case msTRANSM: {
		MdbReqItem *item = reqFifo->getCurrRd();
		bool q = false;

		if (rxRec.FCharRecFlag) {
			if (HAL_GetTick() - rxRec.tick > TM_CHAR_DELAY) {
				rxRec.FCharRecFlag = false;
				item->Result = ProcessReplay();
				q = true;
			}
		}

		if (ChkStateTime(MAX_WAIT_TIME)) {
			item->Result = HAL_TIMEOUT;
			bool vERR = (mDbgLevel >= 1) || (item->reqSrc == reqCONSOLA);
			if (vERR) {
				getOutStream()->oMsgX(colRED, "MDB: replay TimeOut, devNr=%u", item->devNr);
			}
			q = true;
		}

		if (q) {
			if (item->Result == HAL_OK) {
				SetState(msDELAY);
			} else {
				if (item->repeatCnt > 0) {
					ExecFun(item);

					SetState(msTRANSM);
					par2 = item->devNr & 0x0F;
					par2 |= (item->mdbFun & 0x0F) << 4;
					par2 |= ((uint32_t) (item->repeatCnt & 0x0f)) << 8;
					par2 |= ((uint32_t) (item->rmtParams.Id & 0x0f)) << 12;
					par2 |= ((uint32_t) (item->regAdr)) << 16;
					//todo SendErrNotifyMsg(ntfModbusRepeat, ABS(WrRegBuf[FWrBufTail].Result), par2);
				} else {
					SetState(msACKFUN);
					engine->AwariaOff(awMODBUS_NOWORK); // wyłączenie wszystkich przekaźników i wysłanie inforamcji do PC
				}
			}
		}
	}
		break;
	case msDELAY: {
		MdbReqItem *item = reqFifo->getCurrRd();
		if (ChkStateTime(item->rmtParams.Delay)) {
			SetState(msACKFUN);
		}
	}
		break;
	case msACKFUN: {
		MdbReqItem *item = reqFifo->getCurrRd();
		if (item->rmtParams.client != NULL) {
			item->rmtParams.client->OnModbusDone(item);
		}
		SetState(msEND);
	}
		break;
	case msEND:
		reqFifo->pop();
		SetState(msRDY);
		break;
	}
}

void TModbusMaster::PushBufWrReg(RmtParams *params, uint8_t DevId, uint16_t Adr, uint16_t Val) {
	MdbReqItem *item = reqFifo->getCurrWr();
	if (item != NULL) {
		item->reqSrc = reqSYS;
		item->rmtParams = *params;
		item->mdbFun = MDB_FUN_6;
		item->devNr = DevId;
		item->regAdr = Adr;
		item->val[0] = Val;
		item->repeatCnt = 5;
		reqFifo->push();
	}
}

void TModbusMaster::PushBufRdReg(RmtParams *params, uint8_t DevId, uint16_t Adr, uint16_t *Val) {
	MdbReqItem *item = reqFifo->getCurrWr();
	if (item != NULL) {
		item->reqSrc = reqSYS;
		item->rmtParams = *params;
		item->mdbFun = MDB_FUN_3;
		item->devNr = DevId;
		item->regAdr = Adr;
		item->RdVal = Val;
		item->repeatCnt = 5;
		reqFifo->push();
	}
}

const ShellItem menuMODBUS[] = { //
		{ "s", "stan" }, //
		{ "dbg", "poziom komunikatów debug" }, //
		{ "rdreg", "read registers MDB3: devNr,Addr,cnt" }, //
		{ "rdinp", "read analog input MDB4: devNr,Addr,cnt" }, //
		{ "wrreg", "write register MDB6: devNr,Addr,val" }, //
		{ "wrmul", "write registers MDB16: devNr,Addr,val1,val2,..valX" }, //

		{ NULL, NULL } };

void TModbusMaster::fillReqForConsola(MdbReqItem *item, OutStream *strm) {
	item->reqSrc = reqCONSOLA;
	memset(&item->rmtParams, 0, sizeof(item->rmtParams));
	item->rmtParams.strm = strm;
}

void TModbusMaster::shell(OutStream *strm, const char *cmd) {
	char tok[20];
	int idx = -1;

	if (Token::get(&cmd, tok, sizeof(tok)))
		idx = findCmd(menuMODBUS, tok);
	switch (idx) {
	case 0: //s
		printf("EndTransmitCnt=%u", sndRec.FEndTransmitCnt);
		break;
	case 1: //s
		Token::getAsInt(&cmd, &mDbgLevel);
		printf("DbgLevel=%u", mDbgLevel);
		break;
	case 2: //rdreg
	case 3: { //rdinp
		int devNr;
		int adr;
		int cnt;
		if (Token::getAsInt(&cmd, &devNr)) {
			if (Token::getAsInt(&cmd, &adr)) {
				if (Token::getAsInt(&cmd, &cnt)) {
					MdbReqItem *item = reqFifo->getCurrWr();
					if (item != NULL) {
						fillReqForConsola(item, strm);
						item->devNr = devNr;
						item->regAdr = adr;
						item->regCnt = cnt;
						const char *nm;
						if (idx == 2) {
							item->mdbFun = MDB_FUN_3;
							nm = "RdReg";
						} else {
							item->mdbFun = MDB_FUN_4;
							nm = "RdInp";
						}
						strm->oMsgX(colWHITE, "DevNr=%u %s %u,%u", devNr, nm, adr, cnt);
						reqFifo->push();
					}

				}
			}
		}
	}
		break;

	case 4: { //wrreg
		int devNr;
		int adr;
		int val;
		if (Token::getAsInt(&cmd, &devNr)) {
			if (Token::getAsInt(&cmd, &adr)) {
				if (Token::getAsInt(&cmd, &val)) {
					MdbReqItem *item = reqFifo->getCurrWr();
					if (item != NULL) {
						fillReqForConsola(item, strm);

						item->mdbFun = MDB_FUN_6;
						item->devNr = devNr;
						item->regAdr = adr;
						item->val[0] = val;
						strm->oMsgX(colWHITE, "DevNr=%u wrReg %u: %u", devNr, adr, val);
						reqFifo->push();
					}
				}
			}
		}
	}
		break;
	case 5: { //wrmul
		int devNr;
		int adr;
		if (Token::getAsInt(&cmd, &devNr)) {
			if (Token::getAsInt(&cmd, &adr)) {
				MdbReqItem *item = reqFifo->getCurrWr();
				if (item != NULL) {
					int n = 0;
					while (n < MAX_VAL_CNT) {
						int val;
						if (Token::getAsInt(&cmd, &val)) {
							item->val[n] = val;
							n++;
						} else
							break;
					}
					if (n > 0) {
						fillReqForConsola(item, strm);

						item->mdbFun = MDB_FUN_16;
						item->devNr = devNr;
						item->regAdr = adr;
						item->regCnt = n;
						strm->oMsgX(colWHITE, "DevNr=%u WrMulReg %u: n=%u", devNr, adr, n);
						reqFifo->push();
					}
				}
			}
		}
	}
		break;

	default:
		showHelp(strm, "Modbus Menu", menuMODBUS);
		break;
	}
}

