/*
 * myDef.h
 *
 *  Created on: 15 mar 2021
 *      Author: Grzegorz
 */

#ifndef INC_MYDEF_H_
#define INC_MYDEF_H_

#include "stdint.h"

typedef struct {
	uint8_t rk; //
	uint8_t ms; //
	uint8_t dz; //
	uint8_t gd; //
	uint8_t mn; //
	uint8_t sc; //
	uint8_t se; // setne części sekundy
	uint8_t timeSource; //
} TDATE;

typedef struct {
	uint16_t ver;
	uint16_t rev;
	TDATE time;
} VerInfo;




#endif /* INC_MYDEF_H_ */
