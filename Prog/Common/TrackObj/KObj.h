/*
 * KObj.h
 *
 *  Created on: Apr 15, 2021
 *      Author: Grzegorz
 */

#ifndef TRACKOBJ_KOBJ_H_
#define TRACKOBJ_KOBJ_H_

#include "stdint.h"
#include "cmsis_gcc.h"

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

//----------------------------------------------------------------------------
//  firmware update
//----------------------------------------------------------------------------
typedef struct __PACKED {
	uint8_t status;
	uint8_t free[3];
	uint32_t adr;
}KUFlashRply;

typedef struct __PACKED {
	uint32_t Adr;
	uint32_t dtLen;
	uint32_t buf[1]; //początek bufora o rozmiarze do 1kB
}KFlashDt;

typedef struct __PACKED {
	uint8_t status;
	uint8_t free[3];
	uint32_t Adr;
	uint32_t dtLen;
}KFlashHeadSt;









//----------------------------------------------------------------------------
//  PILOT
//----------------------------------------------------------------------------
typedef struct __PACKED {
	uint16_t code;  //kod klawisza
	uint16_t SendCnt; // licznik wysłanych klawiszy od WakeUP
	uint8_t repCnt; // licznik powtórzeń pilota
	uint8_t free[3];
} KPilotDt;

//Rozkazy do pilota
enum {
	kpltGET_INFO = 1, kpltGO_SLEEP, kpltSET_SETUP, kpltCLR_CNT,
};

//----------------------------------------------------------------------------
//  Urządzenia KP
//----------------------------------------------------------------------------
typedef enum {
	sLeft = 0, //
	sRight = 1 //
} Side;

typedef enum {
	uuBREAK_L = 0, //
	uuBREAK_R, //
	uuSUSP_L, //
	uuSUSP_R, //
	uuSLIP_SIDE, //
	uuWEIGHT_L, //
	uuWEIGHT_R, //
	uuMAX_DEV
} KpService;

typedef struct {
	float a;
	float b;
} WspLin;

enum {
	CHANNEL_DATA_LEN = 100,
};

//----------------------------------------------------------------------------
//  urządzenie rolkowe
//----------------------------------------------------------------------------

typedef struct {
	int bufferNr;
	float silHamowProc;
	float silHamow;
	float speed;
	union {
		uint32_t bb;
		struct {
			uint32_t pressRol :1;
			uint32_t pls :1;
		};
	} flags;
	WspLin wsp;
	uint16_t buffer[CHANNEL_DATA_LEN];
} KRollDataRec;

typedef struct {
	int bufferNr;
	float anProc;
} KRollDataRecErrCfg;

//----------------------------------------------------------------------------
//  Suspension
//----------------------------------------------------------------------------
typedef struct {
	int bufferNr;
	float proc;
	float wychyl;
	float waga;
	union {
		uint32_t bb;
		struct {
			uint32_t aktiv :1;
		};
	} flags;
	WspLin wsp;
	uint16_t buffer[CHANNEL_DATA_LEN];
} KSuspensDataRec;

typedef struct {
	int bufferNr;
	float anProc;
} KSuspensDataRecErrCfg;

//----------------------------------------------------------------------------
//  zbieżność
//----------------------------------------------------------------------------

typedef struct {
	int bufferNr;
	float proc;
	float wychyl;
	float startShift; // położenie płyty w momencie otrzymania rozkazu startPomiaru

	union {
		uint32_t bb;
		struct {
			uint32_t activ :1;
			uint32_t isNajazdSensorActiv :1;
			uint32_t isZjazdSensorActi :1;
			uint32_t free :1;
			uint32_t typPlyty:4;
		};
	} flags;
} KSlipSideDataRec;


typedef struct {
	KSlipSideDataRec n;
	WspLin wsp;
	uint16_t buffer[CHANNEL_DATA_LEN];
} KSlipSideDataRecFull;

typedef struct {
	int bufferNr;
	float anProc;
} KSlipSideDataRecErrCfg;

typedef enum{
	sslOK=0,
	sslTimeTooLong,
	sslTimeTooShort,
	sslFlipExceeded,
	sslMaxStartShiftExceeded,

} SlipSideResult;


typedef struct {
	int status;  //SlipSideResult
	float wychyl;  // wychylenie maksymalne, wielkość ze znakiem
	float measTime; //czas w sekundach

} KSlipSideMeasEnd;


//----------------------------------------------------------------------------
//  Waga
//----------------------------------------------------------------------------

typedef struct {
	int samplNr;
	float chnProc[4];
	float chnVal[4];
	float weight;
} KWeightData;

enum {
#include "Group.dsd"
};

#endif /* TRACKOBJ_KOBJ_H_ */
