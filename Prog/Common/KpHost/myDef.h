/*
 * myDef.h
 *
 *  Created on: 25 lis 2019
 *      Author: Grzegorz
 */

#ifndef INC_MYDEF_H_
#define INC_MYDEF_H_

#include "stdint.h"
#include "lwip.h"
#include "ErrorDef.h"





#define SEC_LABEL    __attribute__ ((section (".label")))
#define SEC_NOINIT   __attribute__ ((section (".noinit")))
#define SEC_RAM_FUNC __attribute__ ((section (".ram_func")))



typedef unsigned char byte;
typedef unsigned int dword;
typedef unsigned short word;

#define false 0
#define true 1

enum {
	tmSrcUNKNOWN = 0, tmSrcMANUAL, //wprowadzony ręcznie
	tmSrcNTP, //protokół NTP
	tmSrcGPS, //GPS
	tmFirmVer,
};

typedef enum {
	posFREE = 0, //
	posGND, //
	posVCC, //
} ST3;

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
	word ver;
	word rev;
	TDATE time;
} VerInfo;

typedef enum {
	measRDY, // dane gotowe
	measWAIT, // stan oczekiwania
	measWAIT_LONG, // stan d�ugiego czekania
	measUNAV, //dane niedost�pne
} MeasState;

typedef struct {
	uint8_t dhcp;
	uint8_t free[3];
	ip4_addr_t ip;
	ip4_addr_t mask;
	ip4_addr_t gw;
	ip4_addr_t dns1;
	ip4_addr_t dns2;
} TcpInterfDef;

#endif /* INC_MYDEF_H_ */
