/*
 * UMain.h
 *
 *  Created on: Mar 19, 2021
 *      Author: Grzegorz
 */

#ifndef UMAIN_H_
#define UMAIN_H_

#include "_ansi.h"
#include "stdint.h"

_BEGIN_STD_C

typedef  struct {
	uint32_t sign1;
	uint32_t sign2;
	int startCnt;
	int free;
	int t1;
	int t2;
	int t3;
	int t4;
	int t5;
	int t6;
	int PWR_CSR;
	int RCC_CSR;
	int freeTab[3];
	uint32_t sign3;
} NIR;

extern NIR nir;

extern void uMain(void);

_END_STD_C


#endif /* UMAIN_H_ */
