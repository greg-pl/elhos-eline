/*
 * Hdw.h
 *
 *  Created on: 11 mar 2021
 *      Author: Grzegorz
 *
 * KARTA: KP
 */

#ifndef HDW_H_
#define HDW_H_

#include "stdint.h"
#include "stm32f4xx_hal.h"
#include "myDef.h"

class Hdw {
private:
	static ST3 getPinCfg(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);
public:
	static uint8_t mDinMode;
	enum {
		DIN_CNT = 8,
		AN_CNT = 8,
	};
	static void setPinAsInpNoPull(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);
	static void setPinAsInpPullUp(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);
	static void setPinAsInpPullDn(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);
	static void setPinAsOutputPP(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);
public:
	static void led1(bool q);
	static void led2(bool q);
	static bool getKey1();
	static void phyReset(bool activ);
	static void setPL(int pknr, bool state);
	static bool getPL(int pknr);
	static uint8_t getPLs();
	static uint8_t getJMP();
	static bool getDIN(int inpNr);
	static void setDINAsAnalog(int inpNr, bool asAnalog);
	static void setDINAsAnalogs(uint8_t asAnalog);
	static uint8_t getDINs();
	static void setDL(int lednr, bool state);
	static void setDLs(uint8_t dls);
	static uint8_t getDinMode(){
		return mDinMode;
	}
	static void setAcCs(bool cs);
	static void setJMPAsOut();
	static void setJMP(int nr, bool q);
	static uint8_t getHdwVer(){
		return 1;
	}


};

#endif /* HDW_H_ */
