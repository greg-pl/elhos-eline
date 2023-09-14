/*
 * BaseDev.h
 *
 *  Created on: Mar 23, 2021
 *      Author: Grzegorz
 */

#ifndef KPHOST_BASEDEV_H_
#define KPHOST_BASEDEV_H_

#include "stdint.h"
#include "_ansi.h"

#include <myDef.h>

_BEGIN_STD_C

#define EVENT_TERM_RDY 			(1<<0)
#define EVENT_CREATE_DEVICES  	(1<<1)
#define EVENT_NETIF_OK			(1<<2)
extern EventGroupHandle_t sysEvents;


typedef volatile struct {
	uint32_t Sign1;
	union {
		uint8_t buf[0x80 - 8];
		struct {
			int startCnt;
			int itmp1;
			int itmp2;
			int itmp3;
		};
	};
	uint32_t Sign2;
} NIR;

extern NIR nir;
extern VerInfo mSoftVer;



extern void initNIR();


_END_STD_C

#endif /* KPHOST_BASEDEV_H_ */
