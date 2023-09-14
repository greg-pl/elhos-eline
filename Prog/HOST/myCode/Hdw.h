/*
 * Hdw.h
 *
 *  Created on: 11 mar 2021
 *      Author: Grzegorz
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
	enum {
		PK_CNT = 8,
	};
	static void setPinAnsInpNoPull(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);
	static void setPinAnsInpPullUp(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);
	static void setPinAnsInpPullDn(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);
public:
	static void led1(bool q);
	static void led2(bool q);
	static bool getKey1();
	static void setPk(int pknr, bool state);
	static bool getPK(int pknr);
	static uint8_t getPKs();
	static void setBuzzer(bool state);
	static bool getInp1();
	static bool getInp2();
	static bool rdPanelIrq();
	static void phyReset(bool activ);
	static uint8_t getHdwVer(){
		return 1;
	}



};

#endif /* HDW_H_ */
