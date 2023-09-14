/*
 * I2cDev.cpp
 *
 *  Created on: 30 gru 2020
 *      Author: Grzegorz
 */

#include "string.h"
#include "stdio.h"
#include "math.h"

#include <I2cDev.h>
#include <main.h>
#include <Utils.h>
#include <Hdw.h>
#include <cpx.h>
#include "ShellItem.h"
#include <Token.h>
#include <UMain.h>

I2C_HandleTypeDef I2c1Bus::hi2c;
MutexRec I2c1Bus::mutexRec;

int I2c1Bus::mDevCnt;
I2c1Dev *I2c1Bus::devTab[I2c1Bus::MAX_DEV_CNT];

#define TIME_DT_RD    2000
#define FILTR_FACTOR  0.8

TStatus I2c1Bus::BusInit() {

	mDevCnt = 0;
	for (int i = 0; i < MAX_DEV_CNT; i++) {
		devTab[i] = NULL;
	}

	osMutexDef(I2C1Dev);
	memset(&mutexRec, 0, sizeof(mutexRec));
	mutexRec.mBusMutex = osMutexCreate(osMutex(I2C1Dev));

	HAL_I2C_DeInit(&hi2c);
	setAsGpio();
	gpioSCLWave();

	return InitHd();
}
TStatus I2c1Bus::InitHd() {

	TStatus st = stNoSemafor;
	if (openMutex(1, 100)) {
		memset(&hi2c, 0, sizeof(hi2c));
		hi2c.Instance = I2C1;
		hi2c.Init.AddressingMode = I2C_ADDRESSINGMODE_7BIT;
		hi2c.Init.ClockSpeed = 400000; //400kHz
		hi2c.Init.DutyCycle = I2C_DUTYCYCLE_2;
		hi2c.Init.OwnAddress1 = 0;
		hi2c.Init.OwnAddress2 = 0;
		hi2c.Init.DualAddressMode = I2C_DUALADDRESS_DISABLE;
		hi2c.Init.GeneralCallMode = I2C_GENERALCALL_DISABLE;
		hi2c.Init.NoStretchMode = I2C_NOSTRETCH_DISABLE;
		st = (TStatus)HAL_I2C_Init(&hi2c);
		closeMutex();
	}
	return st;
}



TStatus I2c1Bus::BusRestart() {
	if (openMutex(6, 100)) {
		HAL_I2C_DeInit(&hi2c);
		setAsGpio();
		bool sdaBf = getGpioSDA();
		gpioSCLWave();
		bool sdaAf = getGpioSDA();
		bool busyAf = rdBusyFlag();
		closeMutex();
		getOutStream()->oMsgX(colRED, "I2CBus RESTART: sdaBf=%u, sdaAf=%u, busyAf=%u", sdaBf, sdaAf, busyAf);
		mutexRec.mBusRestartCnt++;
	}
	return InitHd();
}

bool I2c1Bus::openMutex(int who, int tm) {
	osStatus st = osMutexWait(mutexRec.mBusMutex, tm);
	if (st == osOK) {
		mutexRec.taskID = osThreadGetId();
		mutexRec.owner = who;
		mutexRec.openCnt++;
		mutexRec.openTick = HAL_GetTick();
	}
	return (st == osOK);
}
void I2c1Bus::closeMutex() {
	mutexRec.taskID = NULL;
	mutexRec.owner = 0;
	uint32_t tt = HAL_GetTick() - mutexRec.openTick;
	if (tt > mutexRec.maxTime)
		mutexRec.maxTime = tt;

	osMutexRelease(mutexRec.mBusMutex);

}
uint16_t I2c1Bus::swapD(uint16_t d) {
	return (d >> 8) | (d << 8);
}

TStatus I2c1Bus::checkDev(uint8_t dev_addr) {
	return (TStatus)HAL_I2C_IsDeviceReady(&hi2c, dev_addr, 3, 100);
}

TStatus I2c1Bus::readBytes(uint8_t dev_addr, uint8_t reg_addr, uint8_t len, uint8_t *data) {

	return (TStatus)HAL_I2C_Mem_Read(&hi2c, dev_addr, reg_addr, I2C_MEMADD_SIZE_8BIT, data, len, 100);
}

TStatus I2c1Bus::readBytesLong(uint8_t dev_addr, uint16_t reg_addr, uint16_t len, uint8_t *data) {

	return (TStatus)HAL_I2C_Mem_Read(&hi2c, dev_addr, reg_addr, I2C_MEMADD_SIZE_16BIT, data, len, 1000);
}

TStatus I2c1Bus::readByte(uint8_t dev_addr, uint8_t reg_addr, uint8_t *data) {
	return readBytes(dev_addr, reg_addr, 1, data);
}

TStatus I2c1Bus::readWord(uint8_t dev_addr, uint8_t reg_addr, uint16_t *data) {
	uint16_t tmp;
	TStatus st = readBytes(dev_addr, reg_addr, 2, (uint8_t*) &tmp);
	*data = swapD(tmp);
	return st;
}

TStatus I2c1Bus::writeBytes(uint8_t dev_addr, uint8_t reg_addr, uint8_t len, const uint8_t *data) {
	return (TStatus)HAL_I2C_Mem_Write(&hi2c, dev_addr, reg_addr, I2C_MEMADD_SIZE_8BIT, (uint8_t*) (int) data, len, 100);
}

TStatus I2c1Bus::writeBytesLong(uint8_t dev_addr, uint16_t reg_addr, uint16_t len, const uint8_t *data) {
	return (TStatus)HAL_I2C_Mem_Write(&hi2c, dev_addr, reg_addr, I2C_MEMADD_SIZE_16BIT, (uint8_t*) (int) data, len, 1000);
}

TStatus I2c1Bus::writeByte(uint8_t dev_addr, uint8_t reg_addr, uint8_t data) {
	return writeBytes(dev_addr, reg_addr, 1, &data);
}

TStatus I2c1Bus::writeWord(uint8_t dev_addr, uint8_t reg_addr, uint16_t data) {
	data = swapD(data);
	return writeBytes(dev_addr, reg_addr, 2, (const uint8_t*) &data);
}

void I2c1Bus::addDev(I2c1Dev *dev) {
	if (mDevCnt < MAX_DEV_CNT) {
		devTab[mDevCnt] = dev;
		mDevCnt++;
	}
}

TStatus I2c1Bus::checkDevMtx(uint8_t dev_addr) {
	TStatus st = stNoSemafor;
	if (I2c1Bus::openMutex(2, 100)) {
		st = checkDev(dev_addr);
		I2c1Bus::closeMutex();
	}
	return st;
}

//PB6     ------> I2C1_SCL
//PB7     ------> I2C1_SDA

void I2c1Bus::setAsGpio() {
	GPIO_InitTypeDef GPIO_InitStruct;
	GPIO_InitStruct.Pin = GPIO_PIN_6 | GPIO_PIN_7;
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_OD;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_HIGH;
	GPIO_InitStruct.Pull = GPIO_PULLUP;
	HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

	setGpioSDA(GPIO_PIN_SET);
	setGpioSCL(GPIO_PIN_SET);
}

void I2c1Bus::setGpioSDA(GPIO_PinState PinState) {
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_7, PinState);
}
void I2c1Bus::setGpioSCL(GPIO_PinState PinState) {
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, PinState);
}

bool I2c1Bus::rdBusyFlag() {
	return ((hi2c.Instance->SR2 & I2C_SR2_BUSY) != 0);
}

bool I2c1Bus::getGpioSDA() {
	return (HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_7) == GPIO_PIN_SET);
}

bool I2c1Bus::getGpioSCL() {
	return (HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_6) == GPIO_PIN_SET);
}

void I2c1Bus::gpioSCLWave() {
	setAsGpio();
	for (int i = 0; i < 64; i++) {
		setGpioSCL(GPIO_PIN_RESET);
		osDelay(2);
		setGpioSCL(GPIO_PIN_SET);
		osDelay(2);
	}
}

void I2c1Bus::ScanBus(OutStream *strm) {
	if (strm->oOpen(colWHITE)) {
		if (openMutex(3, 100)) {
			int devCnt = 0;
			for (int i = 0; i < 128; i++) {
				uint16_t dev_addr = 2 * i;
				if (HAL_I2C_IsDeviceReady(&hi2c, dev_addr, 2, 50) == HAL_OK) {
					strm->oMsg("Found adr=0x%02X", dev_addr);
					devCnt++;
				}
			}
			strm->oMsg("Found %u devices", devCnt);
			closeMutex();
		} else {
			strm->oMsg("I2c mutex error");
		}
		strm->oClose();
	}
}

void I2c1Bus::showState(OutStream *strm) {
	if (strm->oOpen(colWHITE)) {
		strm->oMsg("MutexTaskOwner: %d", uxTaskGetTaskNumber(mutexRec.taskID));
		strm->oMsg("MutexOwner    : %d", mutexRec.owner);
		strm->oMsg("mMutexOpenCnt : %d", mutexRec.openCnt);
		strm->oMsg("mMutexMaxTime : %d", mutexRec.maxTime);
		strm->oMsg("BusRestartCnt : %d", mutexRec.mBusRestartCnt);
		mutexRec.maxTime = 0;

		for (int i = 0; i < mDevCnt; i++) {
			devTab[i]->showState(strm);
		}
		strm->oClose();
	}
}
void I2c1Bus::showMeas(OutStream *strm) {
	if (strm->oOpen(colWHITE)) {
		for (int i = 0; i < mDevCnt; i++) {
			devTab[i]->showMeas(strm);
		}
		strm->oClose();
	}
}

void I2c1Bus::tick() {
	for (int i = 0; i < mDevCnt; i++) {
		devTab[i]->tick();
	}
}

const ShellItem menuI2C[] = { //
		{ "s", "stan" }, //
		{ "m", "pomiary" }, //
		{ "scan", "przeszukanie magistrali" }, //
		{ "restart", "restart magistrali" }, //

		{ NULL, NULL } };

void I2c1Bus::shell(OutStream *strm, const char *cmd) {
	char tok[20];

	const ShellItem *menuTab[MAX_DEV_CNT + 2];
	int devNrTab[MAX_DEV_CNT + 2];

	int k = 0;
	menuTab[k++] = menuI2C;
	for (int i = 0; i < mDevCnt; i++) {
		const ShellItem *mnItem = devTab[i]->getMenu();
		if (mnItem != NULL) {
			menuTab[k] = mnItem;
			devNrTab[k] = i;
			k++;
		}
	}
	menuTab[k++] = NULL;

	FindRes idxG;
	idxG.idx = -1;
	idxG.mnIdx = -1;

	if (Token::get(&cmd, tok, sizeof(tok)))
		findCmdEx(&idxG, menuTab, tok);
	bool fnd = false;
	if (idxG.mnIdx >= 0) {
		if (idxG.mnIdx == 0) {
			fnd = true;
			switch (idxG.idx) {
			case 0: //s
				showState(strm);
				break;
			case 1: //m
				showMeas(strm);
				break;
			case 2: //scan
				ScanBus(strm);
				break;
			case 3: //restart
				BusRestart();
				break;
			default:
				fnd = false;
			}
		} else {
			int devNr = devNrTab[idxG.mnIdx];
			fnd = devTab[devNr]->execFun(strm, idxG.idx, cmd);
		}
	}
	if (!fnd)
		showHelpEx(strm, "I2C Menu", menuTab);

}

//-------------------------------------------------------------------------------------------------------------------------
// I2c1Dev
//-------------------------------------------------------------------------------------------------------------------------
void I2c1Dev::showDevExist(OutStream *strm) {
	TStatus st = I2c1Bus::checkDevMtx(getAdr());
	strm->oMsg("DevExist=%s", getStatusStr(st));
}

//-------------------------------------------------------------------------------------------------------------------------
// FramI2c
//-------------------------------------------------------------------------------------------------------------------------
FramI2c::FramI2c(uint8_t adr) {
	mDevAdr = adr;
	mDevExist = false;
	Init();

}

void FramI2c::Init(void) {
	mDevExist = (I2c1Bus::checkDevMtx(mDevAdr) == stOK);
	if (!mDevExist)
		return;
}

void FramI2c::showState(OutStream *strm) {
	strm->oMsg("__FRAM__");
	strm->oMsg("chipOk: %s", OkErr(mDevExist));
	strm->oMsg("mError: %s", getStatusStr(mError));
}

TStatus FramI2c::saveCfg(const void *data, int size) {
	TStatus st = stNoSemafor;
	if (I2c1Bus::openMutex(4, 100)) {
		st = (TStatus)I2c1Bus::writeBytesLong(mDevAdr, CFG_ADR, size, (const uint8_t*) data);
		I2c1Bus::closeMutex();
	}
	return st;

}
TStatus FramI2c::loadCfg(void *data, int size) {
	TStatus st = stNoSemafor;
	if (I2c1Bus::openMutex(5, 100)) {
		st = (TStatus)I2c1Bus::readBytesLong(mDevAdr, CFG_ADR, size, (uint8_t*) data);
		I2c1Bus::closeMutex();
	}
	return st;
}

