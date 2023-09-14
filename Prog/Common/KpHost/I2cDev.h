/*
 * I2cDev.h
 *
 *  Created on: 30 gru 2020
 *      Author: Grzegorz
 */

#ifndef I2CDEV_H_
#define I2CDEV_H_

#include "cmsis_os.h"
#include "stm32f4xx_hal.h"
#include "IOStream.h"
#include "ShellItem.h"
#include "ErrorDef.h"

class I2c1Dev {
	friend class I2c1Bus;
protected:
	uint8_t mDevAdr;
	bool mDevExist;
	TStatus mError;

	void showDevExist(OutStream *strm);
	virtual void tick() {
	}
	virtual const ShellItem* getMenu() {
		return NULL;
	}
	virtual bool execFun(OutStream *strm, int idx, const char *cmd) {
		return false;
	}

public:
	virtual void showState(OutStream *strm)=0;
	virtual void showMeas(OutStream *strm) {
	}
	uint8_t getAdr() {
		return mDevAdr;
	}
	bool isDevExist() {
		return mDevExist;
	}
};

typedef struct {
	osMutexId mBusMutex;
	int owner;
	int openCnt;
	osThreadId taskID;
	uint32_t maxTime;
	uint32_t openTick;
	int mBusRestartCnt;
} MutexRec;

class I2c1Bus {
private:
	static void ScanBus(OutStream *strm);
	static void showState(OutStream *strm);
	static void showMeas(OutStream *strm);

	static TStatus InitHd();
	static uint16_t swapD(uint16_t d);

	static void setAsGpio();

	static bool rdBusyFlag();
	static void setGpioSDA(GPIO_PinState PinState);
	static void setGpioSCL(GPIO_PinState PinState);
	static bool getGpioSDA();
	static bool getGpioSCL();
	static void gpioSCLWave();

public:
	enum {
		MAX_DEV_CNT = 4,
	};
	static I2C_HandleTypeDef hi2c;
	static MutexRec mutexRec;

	static int mDevCnt;
	static I2c1Dev *devTab[MAX_DEV_CNT];

	static bool openMutex(int who, int tm);
	static void closeMutex();

	static TStatus checkDev(uint8_t dev_addr);
	static TStatus checkDevMtx(uint8_t dev_addr);

	static TStatus readByte(uint8_t devAddr, uint8_t regAddr, uint8_t *data);
	static TStatus readWord(uint8_t devAddr, uint8_t regAddr, uint16_t *data);
	static TStatus readBytes(uint8_t devAddr, uint8_t regAddr, uint8_t length, uint8_t *data);
	static TStatus readBytesLong(uint8_t dev_addr, uint16_t reg_addr, uint16_t len, uint8_t *data);

	static TStatus writeByte(uint8_t devAddr, uint8_t regAddr, uint8_t data);
	static TStatus writeWord(uint8_t devAddr, uint8_t regAddr, uint16_t data);
	static TStatus writeBytes(uint8_t devAddr, uint8_t regAddr, uint8_t length, const uint8_t *data);
	static TStatus writeBytesLong(uint8_t dev_addr, uint16_t reg_addr, uint16_t len, const uint8_t *data);

public:
	static TStatus BusInit();
	static TStatus BusRestart();
	static void shell(OutStream *strm, const char *cmd);
	static void addDev(I2c1Dev *dev);
	static void tick();
};

//Pamięc FRAM
class FramI2c: public I2c1Dev {
private:
	enum {
		CFG_ADR = 0,
	};

protected:
	virtual void showState(OutStream *strm);
public:
	FramI2c(uint8_t adr);
	void Init(void);
	TStatus saveCfg(const void *data, int size);
	TStatus loadCfg(void *data, int size);
};

#endif /* I2CDEV_H_ */
