/*
 * BaseDev.cpp
 *
 *  Created on: Mar 23, 2021
 *      Author: Grzegorz
 */

#include <BaseDev.h>
#include "string.h"
#include "cmsis_os.h"

#define SIGN_NO_INIT1  0x34568923
#define SIGN_NO_INIT2  0xAAFFEECC

VerInfo mSoftVer;
SEC_NOINIT NIR nir;
EventGroupHandle_t sysEvents;



extern int _snoinit;
extern int _enoinit;
void initNIR() {
	if (nir.Sign1 != SIGN_NO_INIT1 || nir.Sign2 != SIGN_NO_INIT2) {
		void *adr = &_snoinit;
		int len = (int) &_enoinit - (int) &_snoinit;
		memset(adr, 0, len);
		nir.Sign1 = SIGN_NO_INIT1;
		nir.Sign2 = SIGN_NO_INIT2;
	}
	nir.startCnt++;
}

