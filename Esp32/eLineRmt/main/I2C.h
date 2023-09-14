/*
 * I2C.h
 *
 *  Created on: 3 kwi 2021
 *      Author: Grzegorz
 */

#ifndef MAIN_I2C_H_
#define MAIN_I2C_H_

#include "esp_system.h"
#include "freertos/FreeRTOS.h"
#include "freertos/semphr.h"



class I2C {
	friend class I2CDev;
private:
	enum{
		I2C_NUMBER =1 ,
	};
	static SemaphoreHandle_t bus_mux ;
	static void lock();
	static void unlock();
	static bool checkDevExist(uint8_t adr);
public:
	static esp_err_t Init();
	static void scan();

};

class I2CDev {
protected:
	void lock();
	void unlock();
	bool checkDevExist(uint8_t adr);
	bool _writeMem(uint8_t devAdr, uint8_t adr, uint8_t  *dt, int cnt);
	bool _writeByte(uint8_t devAdr, uint8_t adr, uint8_t  val);
	bool writeMem(uint8_t devAdr, uint8_t adr, uint8_t  *dt, int cnt);
	bool writeByte(uint8_t devAdr, uint8_t adr, uint8_t  val);
	bool _writeReg(uint8_t devAdr, uint8_t val);
	bool writeReg(uint8_t devAdr, uint8_t val);
	bool _writeReg2(uint8_t devAdr, uint8_t val1,uint8_t val2);
	bool writeReg2(uint8_t devAdr, uint8_t val1,uint8_t val2);
	bool _readReg(uint8_t devAdr, uint8_t *tab, uint8_t cnt);
	bool readReg(uint8_t devAdr, uint8_t *tab, uint8_t cnt);


};


#endif /* MAIN_I2C_H_ */
