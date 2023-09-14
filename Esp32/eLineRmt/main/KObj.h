/*
 * KObj.h
 *
 *  Created on: 5 maj 2021
 *      Author: Grzegorz
 */

#ifndef MAIN_KOBJ_H_
#define MAIN_KOBJ_H_

#include <stdint.h>
#include <utils.h>

typedef struct __PACKED {
	uint16_t objSize;
	uint8_t dstDev;
	uint8_t cmmCode;
	uint8_t data[0x10];
} KObj;

typedef struct __PACKED {
	uint16_t objSize;
	uint8_t dstDev;
	uint8_t cmmCode;
} KObjHead;




#endif /* MAIN_KOBJ_H_ */
