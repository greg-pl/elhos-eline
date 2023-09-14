/*
 * I2cDevHost.h
 *
 *  Created on: Mar 23, 2021
 *      Author: Grzegorz
 */

#ifndef I2CDEVHOST_H_
#define I2CDEVHOST_H_


#include "i2cDev.h"


//IOExpander MCP23017
class I2cFront: public I2c1Dev {
private:
	enum {
		MCP_REG_IODIR_A = 0x00, //
		MCP_REG_IODIR_B = 0x01, //
		MCP_REG_INTEN_A = 0x04,
		MCP_REG_DEFVAL_A = 0x06,
		MCP_REG_DEFVAL_B = 0x07,
		MCP_REG_INTCON_A = 0x08,

		MCP_REG_IOCON = 0x0A, // reg.konfiguracyjny

		MCP_REG_GPPUA = 0x0C, // polaryzacja A
		MCP_REG_GPPUB = 0x0D, // polaryzacja B

		MCP_REG_GPPU_A = 0x0C,    // PullUpRegister_A
		MCP_REG_GPIO_A = 0x12,  //
		MCP_REG_GPIO_B = 0x13,  //
	};
	uint16_t leds;
protected:
	virtual const ShellItem *getMenu();
	virtual bool execFun(OutStream *strm, int idx, const char *cmd);

public:
	enum {
		ledPK1 = 0, //
		ledPK2, //
		ledPK3, //
		ledPK4, //
		ledPK5, //
		ledPK6, //
		ledPK7, //
		ledPK8, //
		ledF1, //
		ledF2, //
		ledKP, //
		ledPC, //
		ledRADIO, //
		ledRES1, //
		LED_CNT,
	};
	I2cFront(uint8_t adr);


	void updateLeds();
	void ledsOFF();
	void setLed(int ledNr, bool q);
	void setLedUpdate(int ledNr, bool q);
	void setPK(uint8_t pk);
	void Init(void);
	uint8_t readKeys();
	void testLed();
	virtual void showState(OutStream *strm);
};


#endif /* I2CDEVHOST_H_ */
