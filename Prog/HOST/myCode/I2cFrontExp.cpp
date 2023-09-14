/*
 * I2cDevHost.cpp
 *
 *  Created on: Mar 23, 2021
 *      Author: Grzegorz
 */

#include <I2cFrontExp.h>
#include <utils.h>
#include <hdw.h>

//-------------------------------------------------------------------------------------------------------------------------
// I2cFront - IOExpander MCP23017
//-------------------------------------------------------------------------------------------------------------------------

I2cFront::I2cFront(uint8_t adr) {
	mDevAdr = adr;
	mDevExist = false;
	mError = stOK;
	leds = 0;
	Init();
}

void I2cFront::showState(OutStream *strm) {
	strm->oMsg("__MCP23017__");
	strm->oMsg("chipOk: %s", OkErr(mDevExist));
	strm->oMsg("mError: %s", getStatusStr(mError));
}

void I2cFront::Init(void) {
	mDevExist = (I2c1Bus::checkDevMtx(mDevAdr) == stOK);
	if (!mDevExist)
		return;

	if (I2c1Bus::openMutex(10, 100)) {
		uint8_t buf[11];

		buf[0] = 0x00; //IODIR_A: bitx: 0->OUT  1->IN
		buf[1] = 0xC0; //IODIR_B:
		buf[2] = 0x00; //IOPOL_A
		buf[3] = 0x00; //IOPOL_B
		buf[4] = 0x00; //INTEN_A
		buf[5] = 0xC0; //INTEN_B
		buf[6] = 0x00; //DEFVAL_A
		buf[7] = 0xC0; //DEFVAL_B
		buf[8] = 0x00; //INTCON_A
		buf[9] = 0xC0; //INTCON_B

		TStatus st = (TStatus)I2c1Bus::writeBytes(mDevAdr, MCP_REG_IODIR_A, 10, buf);
		if (st != stOK)
			mError = st;

		// połączenie INT_A i INT_B
		st = (TStatus)I2c1Bus::writeByte(mDevAdr, MCP_REG_IOCON, 0x40);
		if (st != stOK)
			mError = st;

		//pull-up dla klawiszy
		st = (TStatus)I2c1Bus::writeByte(mDevAdr, MCP_REG_GPPUB, 0xC0);
		if (st != stOK)
			mError = st;

		I2c1Bus::closeMutex();
	}
}
void I2cFront::ledsOFF() {
	leds = 0;
}

void I2cFront::setLed(int ledNr, bool q) {
	if (q)
		leds |= (1 << ledNr);
	else
		leds &= ~(1 << ledNr);
}

void I2cFront::setLedUpdate(int ledNr, bool q){
	setLed(ledNr, q);
	updateLeds();
}



void I2cFront::setPK(uint8_t pk) {
	setLed(ledPK1, ((pk & 0x01) != 0));
	setLed(ledPK2, ((pk & 0x02) != 0));
	setLed(ledPK3, ((pk & 0x04) != 0));
	setLed(ledPK4, ((pk & 0x08) != 0));
	setLed(ledPK5, ((pk & 0x10) != 0));
	setLed(ledPK6, ((pk & 0x20) != 0));
	setLed(ledPK7, ((pk & 0x40) != 0));
	setLed(ledPK8, ((pk & 0x80) != 0));
}

void I2cFront::updateLeds() {
	if (I2c1Bus::openMutex(11, 100)) {
		uint8_t a = leds & 0xff;
		uint8_t b = leds >> 8;
		uint8_t buf[2];
		buf[0] = a ^ 0xff;
		buf[1] = b ^ 0xff;

		TStatus st = (TStatus)I2c1Bus::writeBytes(mDevAdr, MCP_REG_GPIO_A, 2, buf);
		if (st != stOK)
			mError = st;

		I2c1Bus::closeMutex();
	}
}

void I2cFront::testLed() {
	if (I2c1Bus::openMutex(12, 100)) {
		uint8_t buf[2];
		for (int i = 0; i < 3; i++) {
			buf[0] = 0x00;
			buf[1] = 0x00;
			I2c1Bus::writeBytes(mDevAdr, MCP_REG_GPIO_A, 2, buf);
			osDelay(500);
			buf[0] = 0xFF;
			buf[1] = 0xFF;
			I2c1Bus::writeBytes(mDevAdr, MCP_REG_GPIO_A, 2, buf);
			osDelay(500);
		}
		for (int i = 0; i < LED_CNT; i++) {
			uint16_t w = 1 << i;
			w ^= 0x3FFF;
			buf[0] = w & 0xff;
			buf[1] = w >> 8;
			I2c1Bus::writeBytes(mDevAdr, MCP_REG_GPIO_A, 2, buf);
			osDelay(250);
		}

		TStatus st = (TStatus)I2c1Bus::writeBytes(mDevAdr, MCP_REG_GPIO_A, 2, buf);
		if (st != stOK)
			mError = st;

		I2c1Bus::closeMutex();
	}
	updateLeds();

}

uint8_t I2cFront::readKeys() {
	uint8_t b = 0;
	if (I2c1Bus::openMutex(13, 100)) {
		TStatus st = (TStatus)I2c1Bus::readByte(mDevAdr, MCP_REG_GPIO_B, &b);
		b &= 0xC0;
		I2c1Bus::writeByte(mDevAdr, MCP_REG_DEFVAL_B, b );

		if (st != stOK) {
			mError = st;
		}
		I2c1Bus::closeMutex();
	}
	return b >> 6;
}

const ShellItem menuFrontExp[] = { //
		{ "testLed", "lest led" }, //
		{ "rdkey", "stan klawiszy" }, //
		{ "dump", "dump reg" }, //
		{ "t1", "test1" }, //
		{ "t2", "test2" }, //

		{ NULL, NULL } };

const ShellItem* I2cFront::getMenu() {
	return menuFrontExp;
}

bool I2cFront::execFun(OutStream *strm, int idx, const char *cmd) {
	switch (idx) {
	case 0: //testLed
		strm->oMsg("testLed");
		testLed();
		break;
	case 1: { //rdkey
		uint8_t key = readKeys();
		bool ky1 = ((key & 0x01) == 0);
		bool ky2 = ((key & 0x02) == 0);
		bool irq = Hdw::rdPanelIrq();

		strm->oMsg("KEY1=%u KEY2=%u IRQ=%u", ky1, ky2, irq);
	}
		break;
	case 2: { //dump
		if (I2c1Bus::openMutex(14, 100)) {
			uint8_t buf[22];
			I2c1Bus::readBytes(mDevAdr, MCP_REG_IODIR_A, 22, buf);
			for (int i = 0; i < 11; i++) {
				if (i != 5)
					strm->oMsg("tab[%02X]=0x%02X  0x%02X", 2 * i, buf[2 * i], buf[2 * i + 1]);
				else
					strm->oMsg("tab[%02X]=0x%02X", 2 * i, buf[2 * i]);
			}
			I2c1Bus::closeMutex();
		}

	}
		break;
	case 3: //t1
		ledsOFF();
		setLed(ledPK1, true);
		setLed(ledPK2, true);
		updateLeds();
		break;
	case 4: //t2
		ledsOFF();
		setLed(ledRADIO, true);
		setLed(ledRES1, true);
		updateLeds();
		break;
	default:
		return false;
	}
	return true;
}
