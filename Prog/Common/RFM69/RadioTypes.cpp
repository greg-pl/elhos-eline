/*
 * RadioTypes.cpp
 *
 *  Created on: Mar 20, 2021
 *      Author: Grzegorz
 */

#include "RadioTypes.h"

uint8_t pilotCheckFrame(void *p, int len) {
	Pilot_DataBegin *pDt = (Pilot_DataBegin*) p;
	if (pDt->Sign == PILOT_SIGN) {
		uint32_t *pw = (uint32_t*) p;
		int n = len / 4;
		uint32_t xorW = 0;
		for (int i = 0; i < n; i++) {
			xorW ^= *pw++;
		}
		return (xorW == 0);
	}
	return 0;
}

void pilotBuildFrameXor(void *p, int len) {
	uint32_t *pw = (uint32_t*) p;
	*pw = PILOT_SIGN;
	int n = (len / 4) - 1;
	uint32_t xorW = 0;
	for (int i = 0; i < n; i++) {
		xorW ^= *pw++;
	}
	*pw = xorW;
}
