/*
 * UMain.c
 *
 *  Created on: Mar 12, 2021
 *      Author: Grzegorz
 */
#include "string.h"

#include "myDef.h"
#include "main.h"
#include "UMain.h"
#include "KeyLogDef.h"
#include "CrcFunc.h"

void setLed1(uint8_t q);
void setLed2(uint8_t q);
void setSygIrq(uint8_t q);

VerInfo mSoftVer;

uint8_t mGlobError = 0;

#define HAL_BAD_CMD       ((HAL_StatusTypeDef)5)
#define HAL_BAD_REC_NR    ((HAL_StatusTypeDef)6)
#define HAL_BAD_REC_MODE  ((HAL_StatusTypeDef)7)

//-------------------------------------------------------------------------------------------------------------------------
// LABEL
//-------------------------------------------------------------------------------------------------------------------------
#define SEC_LABEL   __attribute__ ((section (".label")))
SEC_LABEL char DevLabel[] = //
		"ZZZZ            "
				"                "
				"                "
				"                "
				"****************"
				"*              *"
				"* eLINE-LOGKEY *"
				"*              *"
				"****************";

//-------------------------------------------------------------------------------------
// loadSoftVer
//-------------------------------------------------------------------------------------

static uint16_t getDec(const char *p) {
	char ch = *p;
	if (ch >= '0' || ch <= '9')
		return ch - '0';
	else
		return 0;
}

static uint16_t getInt3(const char *p) {
	uint16_t w = getDec(p++) * 100;
	w += getDec(p++) * 10;
	w += getDec(p);
	return w;
}

static uint8_t getInt2(const char *p) {
	uint8_t w = getDec(p++) * 10;
	w += getDec(p);
	return w;
}

//0123456789012345
//Date : 20.06.11
//Time : 00:10:51
//Ver.001 Rev.203

const char Tx1[] = "Date :";
const char Tx2[] = "Time :";
const char Tx3[] = "Ver.";
const char Tx4[] = "Rev.";

uint8_t _strcmp(const char *s1, const char *s2) {
	while (*s1 && *s2) {
		if (*s1 != *s2)
			return 0;
		s1++;
		s2++;
	}
	return 1;
}

uint8_t loadSoftVer(VerInfo *ver, const char *mem) {
	if (_strcmp(Tx1, &mem[0]) && _strcmp(Tx2, &mem[16]) && _strcmp(Tx3, &mem[32]) && _strcmp(Tx4, &mem[40])) {
		ver->ver = getInt3(&mem[36]);
		ver->rev = getInt3(&mem[44]);
		ver->time.rk = getInt2(&mem[7]);
		ver->time.ms = getInt2(&mem[10]);
		ver->time.dz = getInt2(&mem[13]);
		ver->time.gd = getInt2(&mem[16 + 7]);
		ver->time.mn = getInt2(&mem[16 + 10]);
		ver->time.sc = getInt2(&mem[16 + 13]);
		ver->time.se = 0;
		ver->time.timeSource = 0;
		return 1;
	} else {
		memset(ver, 0, sizeof(VerInfo));
		return 0;
	}
}

//-------------------------------------------------------------------------------
//UART
//-------------------------------------------------------------------------------
extern UART_HandleTypeDef huart2;

struct {
	uint8_t recByte;
	int recPtr;
	TKeyLogPacket pkt;
	volatile uint8_t pktRdy;
	volatile int recTick;
} rxRec = {
		0 };

void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart) {
	if (rxRec.recPtr < KEYLOG_PACKET_SIZE) {
		rxRec.pkt.buf[rxRec.recPtr] = rxRec.recByte;
		rxRec.recPtr++;
		if (rxRec.recPtr == KEYLOG_PACKET_SIZE) {
			rxRec.pktRdy = 1;
		}
	}
	rxRec.recTick = HAL_GetTick();
	HAL_UART_Receive_IT(&huart2, &rxRec.recByte, 1);
}

void clearRxRec() {
	rxRec.recPtr = 0;
	rxRec.pktRdy = 0;
}

void checkRxRcTimeOut() {
	if (rxRec.recPtr > 0) {
		int tt = HAL_GetTick();
		if (tt - rxRec.recTick > 100) {
			clearRxRec();
		}
	}
}

struct {
	TKeyLogPacket pkt;
	volatile uint8_t pktRdy;
} txRec = {
		0 };

void HAL_UART_TxCpltCallback(UART_HandleTypeDef *huart) {
	setLed2(mGlobError); //jeśli bład globalny to LED2 nie gaśnie
}

void sendPkt(void) {
	CrcSet((uint8_t*) &txRec.pkt, sizeof(txRec.pkt) - 2);
	HAL_UART_Transmit_IT(&huart2, (uint8_t*) &txRec.pkt, sizeof(txRec.pkt));
	setLed2(1);
}

void sendErrPkt(int err) {
	txRec.pkt.R.Cmd = 'E';
	txRec.pkt.R.RecNr = err;
	sendPkt();
}

//-------------------------------------------------------------------------------
//EEprom
//-------------------------------------------------------------------------------
//176 bytes;
typedef struct {
	TKeyLogInfo devInfo;  //8
	TKeyLogItem tab[KEYLOG_MAX_PACK_NR]; //168
} EepData;

const EepData *eepDataDev = (EepData*) DATA_EEPROM_BASE;

EepData eepData;

HAL_StatusTypeDef writeEEprom(uint32_t adrOfs, int cnt) {
	HAL_StatusTypeDef st = HAL_DATA_EEPROMEx_Unlock();
	if (st == HAL_OK) {
		HAL_FLASHEx_DATAEEPROM_EnableFixedTimeProgram();

		uint32_t dstAdr = DATA_EEPROM_BASE + adrOfs;
		uint32_t *srcPtr = (uint32_t*) &eepData;
		srcPtr += (adrOfs >> 2);

		while (cnt > 0) {
			st = HAL_DATA_EEPROMEx_Program(FLASH_TYPEPROGRAMDATA_WORD, dstAdr, *srcPtr);
			if (st != HAL_OK)
				break;
			srcPtr++;
			dstAdr += 4;
			cnt -= 4;
		}
		st = HAL_DATA_EEPROMEx_Lock();
	}
	if (st != HAL_OK)
		mGlobError = 1;

	return st;
}

void initEepData() {
	eepData = *eepDataDev;
}

//-------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------
HAL_StatusTypeDef incDecDemoCountr(uint8_t recNr, uint8_t dir) {
	TKeyLogItem *dt = &eepData.tab[recNr];
	if (dir) {
		//inc
		if (dt->R.ValidCnt != 0xffff)
			dt->R.ValidCnt++;
	} else {
		//dec
		if (dt->R.ValidCnt != 0xffff && dt->R.ValidCnt != 0) {
			dt->R.ValidCnt--;
		}
	}
	int ofs = (int) dt - (int) (&eepData);
	return writeEEprom(ofs, sizeof(TKeyLogItem));
}

uint8_t getKeyOn(uint8_t recNr, uint16_t time) {
	TKeyLogItem *dt = &eepData.tab[recNr];

	switch (dt->R.Mode) {
	default:
	case kmdOFF:
		return 0;
	case kmdON:
		return 1;
	case kmdDEMO: {
		uint8_t q = 1;
		if (dt->R.ValidCnt == 0)
			q = 0;
		if (dt->R.ValidDate != 0) {
			//sprawdzamy date
			if (time > dt->R.ValidDate)
				q = 0;
		}
		if (q)
			incDecDemoCountr(recNr, 0);
		return q;
	}
	}
}

void execNewQkt(void) {
	TKeyLogQueryIn *in = (TKeyLogQueryIn*) rxRec.pkt.R.Data;
	TKeyLogQueryOut *out = (TKeyLogQueryOut*) txRec.pkt.R.Data;
	uint8_t recNr = in->RecNrMx - REC_NR_OUT_IN;

	if (rxRec.pkt.R.RecNr < KEYLOG_MAX_PACK_NR) {
		uint8_t onV = getKeyOn(recNr, in->time);
		KeyLogQueryReply(out, in, recNr, onV);
		sendPkt();
	} else
		sendErrPkt(HAL_BAD_REC_NR);
}

void execNewRxPkt(void) {
	if (CrcCheck(rxRec.pkt.buf, sizeof(rxRec.pkt))) {

		memset(&txRec.pkt, 0, sizeof(txRec.pkt));
		txRec.pkt.R.Sign = SIGN_REPL_SIGN;
		txRec.pkt.R.Cmd = rxRec.pkt.R.Cmd;
		txRec.pkt.R.RepSign = rxRec.pkt.R.Sign ^ SIGN_RPL_XOR;
		txRec.pkt.R.ErrCode = 0;

		switch (rxRec.pkt.R.Cmd) {
		case 'F': {  //PUBLIC:odczyt rekordu informacyjnego
			if (rxRec.pkt.R.Sign == SIGN_PKT_F) {
				TKeyLogInfoRec *ir = (TKeyLogInfoRec*) txRec.pkt.R.Data;
				ir->Ver = mSoftVer.ver;
				ir->Rev = mSoftVer.rev;
				ir->PacketCnt = KEYLOG_MAX_PACK_NR;
				memcpy(&(ir->Info), (void*) &eepData.devInfo, sizeof(TKeyLogInfo));
				sendPkt();
			}
		}
			break;
		case 'R':  //PUBLIC:odczyt rekordu danych
			if (rxRec.pkt.R.Sign == SIGN_PKT_R) {

				if (rxRec.pkt.R.RecNr < KEYLOG_MAX_PACK_NR) {
					const void *adr = &eepData.tab[rxRec.pkt.R.RecNr];
					memcpy(txRec.pkt.R.Data, adr, sizeof(txRec.pkt.R.Data));
					txRec.pkt.R.RecNr = rxRec.pkt.R.RecNr;
					sendPkt();
				} else
					sendErrPkt(HAL_BAD_REC_NR);
			}
			break;
		case 'X': //LOADER:kasowanie całości
			memset(&eepData, 0, sizeof(eepData));
			txRec.pkt.R.ErrCode = writeEEprom(0, sizeof(eepData));
			sendPkt();
			break;
		case 'T': { //LOADER:zapis rekortu informacyjnego
			if (rxRec.pkt.R.Sign == SIGN_PKT_T) {
				TKeyLogInfoRec *ir = (TKeyLogInfoRec*) rxRec.pkt.R.Data;
				int sz = sizeof(TKeyLogInfo);
				memcpy((void*) &eepData.devInfo, &ir->Info, sz);
				txRec.pkt.R.ErrCode = writeEEprom(0, sz);
				sendPkt();
			}
		}
			break;
		case 'W': { //LOADER:zapis danych
			if (rxRec.pkt.R.Sign == SIGN_PKT_W) {
				TKeyLogItem *ir = (TKeyLogItem*) rxRec.pkt.R.Data;
				int nr = rxRec.pkt.R.RecNr;
				if (rxRec.pkt.R.RecNr < KEYLOG_MAX_PACK_NR) {
					int sz = sizeof(TKeyLogItem);
					memcpy((void*) &eepData.tab[nr], ir, sz);
					int ofs = (int) (&eepData.tab[nr]) - (int) (&eepData);
					txRec.pkt.R.ErrCode = writeEEprom(ofs, sz);
					sendPkt();
				} else
					sendErrPkt(HAL_BAD_REC_NR);
			}
		}
			break;
		case 'I': { //LOADER:inkrementacja liczników
			if (rxRec.pkt.R.Sign == SIGN_PKT_I) {
				TKeyLogIncRec *ptr = (TKeyLogIncRec*) rxRec.pkt.R.Data;
				if (rxRec.pkt.R.RecNr < KEYLOG_MAX_PACK_NR) {

					TKeyLogItem *dt = &eepData.tab[rxRec.pkt.R.RecNr];
					if (dt->R.Mode == kmdDEMO) {
						if (ptr->IncDec) {
							//inc
							if (dt->R.ValidCnt != 0xffff)
								dt->R.ValidCnt++;
						} else {
							//dec
							if (dt->R.ValidCnt != 0xffff && dt->R.ValidCnt != 0) {
								dt->R.ValidCnt--;
							}
						}
						int ofs = (int) dt - (int) (&eepData);
						txRec.pkt.R.ErrCode = writeEEprom(ofs, sizeof(TKeyLogItem));
						sendPkt();
					} else
						sendErrPkt(HAL_BAD_REC_MODE);
				} else
					sendErrPkt(HAL_BAD_REC_NR);

			}
		}
			break;
		case 'Q': //PUBLIC: zapytanie o aktywność klucza
			if (rxRec.pkt.R.Sign == SIGN_PKT_Q) {
				execNewQkt();
			}
			break;

		default:
			sendErrPkt(HAL_BAD_CMD);
			break;
		}

	}
}

//-------------------------------------------------------------------------------
// MAIN
//-------------------------------------------------------------------------------

extern TIM_HandleTypeDef htim2;

void setLed1(uint8_t q) {
	if (q)
		HAL_GPIO_WritePin(LED1_GPIO_Port, LED1_Pin, GPIO_PIN_RESET);
	else
		HAL_GPIO_WritePin(LED1_GPIO_Port, LED1_Pin, GPIO_PIN_SET);
}
void setLed2(uint8_t q) {
	if (q)
		HAL_GPIO_WritePin(LED2_GPIO_Port, LED2_Pin, GPIO_PIN_RESET);
	else
		HAL_GPIO_WritePin(LED2_GPIO_Port, LED2_Pin, GPIO_PIN_SET);
}

void setSygIrq(uint8_t q) {
	if (q)
		HAL_GPIO_WritePin(SYG_IRQ_GPIO_Port, SYG_IRQ_Pin, GPIO_PIN_RESET);
	else
		HAL_GPIO_WritePin(SYG_IRQ_GPIO_Port, SYG_IRQ_Pin, GPIO_PIN_SET);
}

void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim) {
	static uint8_t sPulse = 0;
	sPulse = !sPulse;
	setSygIrq(sPulse);
}

void uMain(void) {

// region funkcji do blokowania flasha
#if 1
	setLed2(1);
	FLASH_OBProgramInitTypeDef def;
	HAL_FLASHEx_OBGetConfig(&def);

	uint32_t opt = 0;

	if (def.RDPLevel != OB_RDP_LEVEL_1)
		opt |= OPTIONBYTE_RDP;  //blokada przed odczytem
	if (def.BORLevel != OB_BOR_LEVEL5)
		opt |= OPTIONBYTE_BOR; //BOR
	if (!def.BOOTBit1Config)
		opt |= OPTIONBYTE_BOOT_BIT1;

	if (opt) {
		HAL_StatusTypeDef st = HAL_FLASH_OB_Unlock();
		if (st == HAL_OK) {
			def.OptionType = opt;
			def.RDPLevel = OB_RDP_LEVEL_1;
			def.BORLevel = OB_BOR_LEVEL5;
			def.BOOTBit1Config = OPTIONBYTE_BOOT_BIT1;

			st = HAL_FLASHEx_OBProgram(&def);
			if (st == HAL_OK) {
				HAL_FLASH_OB_Lock();
			}
		}
	}

	//jesli blokowanie niepowdło się to nie uruchamiamy się
	HAL_FLASHEx_OBGetConfig(&def);
	if (def.RDPLevel != OB_RDP_LEVEL_1) {
		setLed1(1);
		setLed2(1);
		while (1) {

		}
	}
#endif
	setLed2(0);
	setLed1(1);
	if (!loadSoftVer(&mSoftVer, &DevLabel[16])) {
		mSoftVer.ver = 1;
		mSoftVer.rev = 777;
	}

	mGlobError = 0;
	initEepData();

	HAL_TIM_Base_Start_IT(&htim2);

	HAL_UART_Receive_IT(&huart2, &rxRec.recByte, 1);

	uint32_t ledT = HAL_GetTick();
	uint8_t led = 0;
	while (1) {
		uint32_t tt = HAL_GetTick();
		if (tt - ledT > 200) {
			ledT = tt;
			led = !led;
			setLed1(led);
		}
		checkRxRcTimeOut();
		if (rxRec.pktRdy) {
			execNewRxPkt();
			clearRxRec();
		}
	}
}
