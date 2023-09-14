/*
 * UMain.c
 *
 *  Created on: Mar 16, 2021
 *      Author: Grzegorz
 */

#include "string.h"

#include "myDef.h"
#include "main.h"
#include "UMain.h"
#include "RFM69.h"
#include "RadioTypes.h"

bool mGlobError = 0;
VerInfo mSoftVer;

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
				"* eLINE-PILOT  *"
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

//-------------------------------------------------------------------------------------
// HDW
//-------------------------------------------------------------------------------------

void setLed1(uint8_t q) {
	if (q)
		HAL_GPIO_WritePin(LED1_GPIO_Port, LED1_Pin, GPIO_PIN_RESET);
	else
		HAL_GPIO_WritePin(LED1_GPIO_Port, LED1_Pin, GPIO_PIN_SET);
}

void setPinRx(uint8_t q) {
	if (q)
		HAL_GPIO_WritePin(PIN_RX_GPIO_Port, PIN_RX_Pin, GPIO_PIN_SET);
	else
		HAL_GPIO_WritePin(PIN_RX_GPIO_Port, PIN_RX_Pin, GPIO_PIN_RESET);
}

void setPinTx(uint8_t q) {
	if (q)
		HAL_GPIO_WritePin(PIN_TX_GPIO_Port, PIN_TX_Pin, GPIO_PIN_SET);
	else
		HAL_GPIO_WritePin(PIN_TX_GPIO_Port, PIN_TX_Pin, GPIO_PIN_RESET);
}

void onCol1() {
	//ustawienie stanu niskiego
	COL1_GPIO_Port->BRR = COL1_Pin;

}
void offCol1() {
	//ustawienie stanu wysokiego
	COL1_GPIO_Port->BSRR = COL1_Pin;
}

void onCol2() {
	//ustawienie stanu niskiego
	COL2_GPIO_Port->BRR = COL2_Pin;

}
void offCol2() {
	//ustawienie stanu wysokiego
	COL2_GPIO_Port->BSRR = COL2_Pin;
}

void onCol3() {
	//ustawienie stanu niskiego
	COL3_GPIO_Port->BRR = COL3_Pin;

}
void offCol3() {
	//ustawienie stanu wysokiego
	COL3_GPIO_Port->BSRR = COL3_Pin;
}

void onCol4() {
	//ustawienie stanu niskiego
	COL4_GPIO_Port->BRR = COL4_Pin;

}
void offCol4() {
	//ustawienie stanu wysokiego
	COL4_GPIO_Port->BSRR = COL4_Pin;
}

void onCol5() {
	//ustawienie stanu niskiego
	COL5_GPIO_Port->BRR = COL5_Pin;

}
void offCol5() {
	//ustawienie stanu wysokiego
	COL5_GPIO_Port->BSRR = COL5_Pin;
}

void allColOff() {
	offCol1();
	offCol2();
	offCol3();
	offCol4();
	offCol5();
}

void ColsAsPushPull() {
	GPIO_InitTypeDef GPIO_InitStruct = { 0 };

	GPIO_InitStruct.Pin = COL5_Pin | COL4_Pin | COL3_Pin | COL2_Pin | COL1_Pin;
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
}

void ColsAsOpenDrian() {
	GPIO_InitTypeDef GPIO_InitStruct = { 0 };

	GPIO_InitStruct.Pin = COL5_Pin | COL4_Pin | COL3_Pin | COL2_Pin | COL1_Pin;
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_OD;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

}

void allColUp() {
	ColsAsPushPull();
	uint32_t pin = COL5_Pin | COL4_Pin | COL3_Pin | COL2_Pin | COL1_Pin;
	HAL_GPIO_WritePin(GPIOA, pin, GPIO_PIN_SET);
}

void RowsAsInp() {
	GPIO_InitTypeDef GPIO_InitStruct = { 0 };
	GPIO_InitStruct.Pin = ROW1_Pin | ROW2_Pin;
	GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
	GPIO_InitStruct.Pull = GPIO_PULLUP;
	HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
}

uint8_t rdRows2() {
	uint8_t b = 0;
	if (HAL_GPIO_ReadPin(ROW1_GPIO_Port, ROW1_Pin) == GPIO_PIN_RESET)
		b |= 0x01;
	if (HAL_GPIO_ReadPin(ROW2_GPIO_Port, ROW2_Pin) == GPIO_PIN_RESET)
		b |= 0x02;
	return b;
}

//ROW1->PA.0  ROW2->PA.2
uint8_t rdRows() {
	uint32_t w = GPIOA->IDR;
	uint8_t b = (w & ROW1_Pin) ^ ROW1_Pin;
	if ((w & ROW2_Pin) == 0)
		b |= 0x02;
	return b;
}

uint16_t hdReadKey() {
	onCol1();
	uint16_t w = rdRows();
	offCol1();
	onCol2();
	w |= (rdRows() << 2);
	offCol2();
	onCol3();
	w |= (rdRows() << 4);
	offCol3();
	onCol4();
	w |= (rdRows() << 6);
	offCol4();
	onCol5();
	w |= (rdRows() << 8);
	offCol5();
	return w;
}

#define KEY1  (1<<4)
#define KEY2  (1<<2)
#define KEY3  (1<<3)
#define KEY4  (1<<5)

uint16_t translateKey(uint16_t inp) {
	uint16_t w = 0;
	if (inp & KEY1)
		w |= kyUP;
	if (inp & KEY2)
		w |= kyDN;
	if (inp & KEY3)
		w |= kyLF;
	if (inp & KEY4)
		w |= kyRT;
	return w;
}

struct {
	volatile int devRdy = 0;
	volatile uint8_t flag;
	uint16_t code_hd;
	volatile uint16_t code;
	uint16_t counter;
	uint8_t repPhase;
	uint8_t repCnt;
	uint8_t keyUpCnt; // licznik czasu odpuszczenia klawisza

} keyRec;

const uint16_t tabRepTm[] = { 5, 500, 250 };

void checkKey() {
	uint16_t key = hdReadKey();
	if (key != 0) {
		if (++keyRec.counter > tabRepTm[keyRec.repPhase]) {
			keyRec.counter = 0;

			if (keyRec.repPhase < 2)
				keyRec.repPhase++;

			if (keyRec.repCnt < 15)
				keyRec.repCnt++;
			if (keyRec.code_hd != key) {
				keyRec.code_hd = key;
				keyRec.code = translateKey(key);
			}

			keyRec.flag = 1;
		}
		keyRec.keyUpCnt = 0;
	} else {
		if (++keyRec.keyUpCnt > 50) {
			keyRec.counter = 0;
			keyRec.repPhase = 0;
			keyRec.repCnt = 0;
		}
	}
}

void initKeyRec() {
	memset(&keyRec, 0, sizeof(keyRec));
	keyRec.devRdy = 1;
}

extern "C" void mySysTick_Handler() {
	if (keyRec.devRdy) {
		checkKey();
	}

}

//-------------------------------------------------------------------------------
//Utils
//-------------------------------------------------------------------------------

void insertXor(void *ptr, int size) {
	uint32_t *pW = (uint32_t*) ptr;
	int n = (size - 4) / 4;
	uint32_t xorw = 0;
	for (int i = 0; i < n; i++) {
		xorw ^= *pW;
		pW++;
	}
	*pW = xorw;
}

bool checkXor(void *p, int len) {
	uint32_t *pw = (uint32_t*) p;
	int n = len / 4;
	uint32_t xorW = 0;
	for (int i = 0; i < n; i++) {
		xorW ^= *pw++;
	}
	return (xorW == 0);
}
//-------------------------------------------------------------------------------
//EEprom
//-------------------------------------------------------------------------------
#define EEP_SIGN1 0x3456A031
#define EEP_SIGN2 0x345EE0CC

typedef struct {
	int Sign1;
	uint8_t channelNr;
	uint8_t txPower;
	uint8_t free1;
	uint8_t free2;
	int Sign2;
	uint32_t Xor;
} EepDataCfg;

typedef struct {
	int Sign1;
	int keyGlobSendCnt;
	int startCnt;
	uint32_t clearCntTime;
	uint32_t free1;
	uint32_t free2;
	int Sign2;
	uint32_t Xor;
} EepDataRob;

#define EEP_DATA1_OFS 0x00
#define EEP_DATA2_OFS 0x40

const EepDataCfg *eepDataDevCfg = (EepDataCfg*) (DATA_EEPROM_BASE + EEP_DATA1_OFS);
const EepDataRob *eepDataDevRob = (EepDataRob*) (DATA_EEPROM_BASE + EEP_DATA2_OFS);

EepDataCfg eepCfg;
EepDataRob eepRob;

HAL_StatusTypeDef writeEEprom(const void *dst, uint32_t *srcPtr, int cnt) {
	HAL_StatusTypeDef st = HAL_DATA_EEPROMEx_Unlock();
	if (st == HAL_OK) {
		HAL_FLASHEx_DATAEEPROM_EnableFixedTimeProgram();

		uint32_t dstAdr = (int) dst;

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

HAL_StatusTypeDef writeEepCfg() {
	eepCfg.Sign1 = EEP_SIGN1;
	eepCfg.Sign2 = EEP_SIGN2;
	insertXor(&eepCfg, sizeof(eepCfg));
	return writeEEprom(eepDataDevCfg, (uint32_t*) &eepCfg, sizeof(EepDataCfg));
}

HAL_StatusTypeDef writeEepRob() {
	eepRob.Sign1 = EEP_SIGN1;
	eepRob.Sign2 = EEP_SIGN2;
	insertXor(&eepRob, sizeof(eepRob));
	return writeEEprom(eepDataDevRob, (uint32_t*) &eepRob, sizeof(EepDataRob));
}

bool checkRadioPar(uint8_t channelNr, uint8_t txPower) {
	bool q = true;
	q &= (eepCfg.channelNr >= 1 && eepCfg.channelNr <= 15);
	q &= (eepCfg.txPower <= 31);
	return q;
}

void initEepCfg() {
	eepCfg = *eepDataDevCfg;
	bool q = true;
	q &= (eepCfg.Sign1 == EEP_SIGN1);
	q &= (eepCfg.Sign2 == EEP_SIGN2);
	q &= checkRadioPar(eepCfg.channelNr, eepCfg.txPower);
	q &= checkXor(&eepCfg, sizeof(eepCfg));

	if (!q) {
		memset(&eepCfg, 0, sizeof(eepCfg));
		eepCfg.channelNr = 1;
		eepCfg.txPower = 31;
		writeEepCfg();
	}
}

void initEepRob() {
	eepRob = *eepDataDevRob;
	bool q = true;
	q &= (eepRob.Sign1 == EEP_SIGN1);
	q &= (eepRob.Sign2 == EEP_SIGN2);
	q &= checkXor(&eepRob, sizeof(eepRob));

	if (!q) {
		memset(&eepRob, 0, sizeof(eepRob));
		writeEepRob();
	}
}

void initEepData() {
	initEepCfg();
	initEepRob();
}

//-------------------------------------------------------------------------------
//Radio
//-------------------------------------------------------------------------------
bool mSetupMode = false;
bool mReciverOn = false;
bool mDoOff = false;

void initRadio() {
	RFMCfg cfg;

	cfg.ChannelFreq = RFM69::getChannelFreq(eepCfg.channelNr);
	cfg.BaudRate = bd19200;
	cfg.TxPower = eepCfg.txPower;
	cfg.PAMode = paMode1;

	RFM69::Init(&cfg);
	if (!mReciverOn) {
		RFM69::setStandByMode();
	}
}

void initRadioSetup() {
	RFMCfg cfg;

	cfg.ChannelFreq = RFM69::getChannelFreq(0);
	cfg.BaudRate = bd19200;
	cfg.TxPower = 31;
	cfg.PAMode = paMode1;

	RFM69::Init(&cfg);
}

uint16_t keySendCnt = 0;

void sendPacket(void *ptr, int size) {
	Pilot_DataBegin *pBg = (Pilot_DataBegin*) ptr;
	pBg->Sign = PILOT_SIGN;
	insertXor(ptr, size);

	RFM69::sendPacket(PILOT_SRC_PILOT, ptr, size);
	if (!mReciverOn) {
		RFM69::setStandByMode();
	}
	keySendCnt++;
	eepRob.keyGlobSendCnt++;
}

void sendKeyMsg(uint16_t code, uint8_t repCnt) {
	Pilot_DataStruct pkt;

	memset(&pkt, 0, sizeof(pkt));
	pkt.cmd = plcmdDATA;
	pkt.key_code = code;
	pkt.n_key_code = ~code;
	pkt.repCnt = repCnt;
	pkt.keySendCnt = keySendCnt;
	sendPacket(&pkt, sizeof(pkt));
}

void sendInfoMsg() {
	Pilot_InfoStruct pkt;
	memset(&pkt, 0, sizeof(pkt));
	pkt.cmd = plcmdINFO;
	pkt.firmVer = mSoftVer.ver;
	pkt.firmRev = mSoftVer.rev;
	pkt.startCnt = eepRob.startCnt;
	pkt.keyGlobSendCnt = eepRob.keyGlobSendCnt;
	pkt.PackTime = eepRob.clearCntTime;

	sendPacket(&pkt, sizeof(pkt));
}

void sendChipIDMsg() {
	Pilot_ChipIDStruct pkt;
	memset(&pkt, 0, sizeof(pkt));
	pkt.cmd = plcmdCHIP_SN;
	pkt.ChipID[0] = HAL_GetUIDw0();
	pkt.ChipID[1] = HAL_GetUIDw1();
	pkt.ChipID[2] = HAL_GetUIDw2();

	sendPacket(&pkt, sizeof(pkt));
}

void sendExitMsg() {
	Pilot_CmdStruct pkt;

	memset(&pkt, 0, sizeof(pkt));
	pkt.cmd = plcmdEXIT_SETUP;
	pkt.cmdNr = 1;
	sendPacket(&pkt, sizeof(pkt));
}

void sendAckMsg(uint8_t ackCmd, uint8_t ackCmdNr, uint8_t ackError) {
	Pilot_AckStruct pkt;
	memset(&pkt, 0, sizeof(pkt));
	pkt.cmd = plcmdACK;
	pkt.ackCmd = ackCmd;
	pkt.ackCmdNr = ackCmdNr;
	pkt.ackError = ackError;

	sendPacket(&pkt, sizeof(pkt));
}

bool execNewRadioFrame() {
	if (pilotCheckFrame(RFM69::recVar.DataBuf, RFM69::recVar.DataLen)) {
		Pilot_DataBegin *pBg = (Pilot_DataBegin*) RFM69::recVar.DataBuf;
		switch (pBg->cmd) {
		case plcmdSETUP: { // {-->P} ramka konfiguracyjna do pilota
			Pilot_SetupStruct *pSet = (Pilot_SetupStruct*) pBg;
			uint8_t err = plerrBAD_ARG;
			if ((pSet->channelNr ^ pSet->n_channelNr) == 0xFF) {
				if (checkRadioPar(pSet->channelNr, pSet->txPower)) {
					err = plerrOK;
					eepCfg.channelNr = pSet->channelNr;
					eepCfg.txPower = pSet->txPower;

					if (writeEepCfg() != HAL_OK)
						err = plerrFLASH_ERR;
				}

			}
			sendAckMsg(plcmdSETUP, pSet->cmdNr, err);
			if (err == plerrOK) {
				HAL_Delay(500);
				return true;
			}
		}
			break;
		case plcmdCLR_CNT: { // {-->P} rozkaz kasowania liczników
			Pilot_CmdStruct *pCmd = (Pilot_CmdStruct*) pBg;
			eepRob.clearCntTime = pCmd->PackTime;
			eepRob.keyGlobSendCnt = 0;
			eepRob.startCnt = 0;
			setLed1(1);
			HAL_Delay(200);
			sendAckMsg(pCmd->cmd, pCmd->cmdNr, plerrOK);
			setLed1(0);
		}
			break;
		case plcmdGET_INFO: { // {-->P} wyślij info rekord
			setLed1(1);
			HAL_Delay(100);
			sendInfoMsg();
			HAL_Delay(300);
			sendChipIDMsg();
			setLed1(0);
			break;
		}
			break;
		case plcmdGO_SLEEP: {
			Pilot_CmdStruct *pCmd = (Pilot_CmdStruct*) pBg;
			sendAckMsg(pCmd->cmd, pCmd->cmdNr, plerrOK);
			mDoOff = true;

		}
			return true;
		}
	}

	return false;
}

uint32_t freq;

#define ENTER_SERVICE_CODE (kyLF | kyRT)
#define EXIT_SERVICE_CODE kyUP
#define SHOW_NR_CODE (kyUP | kyDN)

void showSelfNr() {
	HAL_Delay(1000); //sekunda przerwy już była
	setLed1(1);
	HAL_Delay(1000);
	setLed1(0);
	HAL_Delay(1000);
	for (int i = 0; i < eepCfg.channelNr; i++) {
		setLed1(1);
		HAL_Delay(100);
		setLed1(0);
		HAL_Delay(500);
	}
	HAL_Delay(1500);
}

void workLoop(void) {
	ColsAsOpenDrian();
	allColOff();
	RowsAsInp();

	initRadio();

	int ledT = 0;
	uint32_t exitTm = HAL_GetTick();
	bool doRun = true;
	mDoOff = false;

	while (doRun) {
		int tt = HAL_GetTick();

		//gaszenie LED
		if ((ledT != 0) && !mSetupMode) {
			if (tt - ledT > 100) {
				ledT = 0;
				setLed1(0);
			}
		}
		if (keyRec.flag) {
			keyRec.flag = 0;
			setLed1(1);
			ledT = tt;

			sendKeyMsg(keyRec.code, keyRec.repCnt);

			if (!mSetupMode) {
				if (keyRec.repCnt == 5) {
					if (keyRec.code == ENTER_SERVICE_CODE) {
						mSetupMode = true;
						mReciverOn = true;

						initRadioSetup();
						setLed1(1);
						keyRec.flag = 0;
						ledT = 0;
					}
					if (keyRec.code == SHOW_NR_CODE) {
						mReciverOn = true;
						HAL_Delay(1000);
						sendInfoMsg();
						showSelfNr();
						keyRec.flag = 0;
						ledT = 0;
					}

				}
			}

			if (mSetupMode) {
				if (keyRec.code == EXIT_SERVICE_CODE) {
					mSetupMode = false;
					mReciverOn = false;
					initRadio();
				}
			}
			exitTm = HAL_GetTick();

		}
		RFM69::tick();
		if (RFM69::isNewFrame()) {
			if (execNewRadioFrame()) {
				doRun = false;
			}
			exitTm = HAL_GetTick();
		}
		uint32_t tm = 5000;
		if (mSetupMode | mReciverOn)
			tm = 60000;
		if (mDoOff)
			tm = 200;
		if (HAL_GetTick() - exitTm > tm) {
			doRun = false;
		}
		__WFI();
	}
	if (mSetupMode | mReciverOn) {
		sendExitMsg();
	}
	writeEepRob();
}

void goStopMode() {
	RFM69::setSleepMode();

	HAL_PWR_EnableWakeUpPin (PWR_WAKEUP_PIN1);
#if defined(STM32L031xx)
	HAL_PWR_EnableWakeUpPin(PWR_WAKEUP_PIN3);
#endif
	__HAL_PWR_CLEAR_FLAG(PWR_FLAG_WU);
	__HAL_PWR_CLEAR_FLAG(PWR_FLAG_SB);
	HAL_PWR_EnterSTANDBYMode();
}

#define NIR_SIGN1 0x12345678
#define NIR_SIGN2 0xABCDABCD
#define NIR_SIGN3 0x77777777

extern "C" void uMain(void) {

	HAL_PWR_DisableWakeUpPin (PWR_WAKEUP_PIN1);
#if defined(STM32L031xx)
	HAL_PWR_DisableWakeUpPin (PWR_WAKEUP_PIN3);
#endif
	__HAL_PWR_CLEAR_FLAG(PWR_FLAG_WU);
	__HAL_PWR_CLEAR_FLAG(PWR_FLAG_SB);

	initEepData();
	eepRob.startCnt++;

	keySendCnt = 0;

	if (!loadSoftVer(&mSoftVer, &DevLabel[16])) {
		mSoftVer.ver = 1;
		mSoftVer.rev = 777;
	}

	initKeyRec();

	workLoop();
	goStopMode();

}
