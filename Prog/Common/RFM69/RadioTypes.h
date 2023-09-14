/*
 * RadioTypes.h
 *
 *  Created on: 19 mar 2021
 *      Author: Grzegorz
 */

#ifndef RFM69_RADIOTYPES_H_
#define RFM69_RADIOTYPES_H_

#include "_ansi.h"
#include "stdint.h"

_BEGIN_STD_C

enum {
	plcmdUNKNOWN = 0, //
	plcmdDATA = 1, // {P-->} ramka danych z pilota
	plcmdINFO = 2, // {P-->} ramka informacyjna z pilota
	plcmdACK = 3, // {P-->} potwierdzenie komend
	plcmdSETUP = 4, // {-->P} ramka konfiguracyjna do pilota
	plcmdCLR_CNT = 5, // {-->P} rozkaz kasowania liczników
	plcmdGET_INFO = 6, // {-->P} wyślij info rekord
	plcmdEXIT_SETUP = 7, // {P-->} informacja o wyjściu z trybu setup
	plcmdCHIP_SN = 8, // {P-->} ramka informacyjna 2 z pilota
	plcmdGO_SLEEP = 9, // {-->P} uśpij pilot
};

//kody klawiszy
enum {
	kyENG_L = 0x0001, //
	kyENG_R = 0x0002, //
	kyENG_LR = 0x0004, //
	kyUP = 0x0008, //
	kyDN = 0x0010, //
	kyLF = 0x0020, //
	kyRT = 0x0040, //
	kyOK = 0x0080, //
	kyMN = 0x0100, //
	kyESC = 0x0200, //
};

//komunikaty błedów
enum {
	plerrOK = 0, //
	plerrBAD_ARG = 1, //
	plerrFLASH_ERR = 2,

};

#define PILOT_SIGN  0x5B07AF12
#define PILOT_CLR_SIGN 0x3A
#define PILOT_SRC_PILOT 1
#define PILOT_SRC_HOST  2
#define SETUP_CH 	    0

typedef struct {
	uint32_t Sign;  //kod stały ramki
	uint8_t cmd;
} __attribute__ ((packed)) Pilot_DataBegin;

//{P-->} ramka danych z pilota
typedef struct {
	uint32_t Sign;  //kod stały ramki
	uint8_t cmd;
	uint8_t repCnt; // licznik powtórzeń pilota
	uint16_t keySendCnt; // licznik wysłanych klawiszy od WakeUP
	uint16_t key_code;  //kod klawisza
	uint16_t n_key_code; // negacja key_code
	uint32_t SumaXor;
} __attribute__ ((packed)) Pilot_DataStruct;

//{P-->} ramka informacyjna z pilota
typedef struct {
	uint32_t Sign;  //kod stały ramki
	uint8_t cmd;
	uint8_t free[3];
	uint16_t firmVer; //versja virmware
	uint16_t firmRev; //revision firmware
	uint32_t startCnt; // licznik pobudek pilota od włożenia baterii
	uint32_t keyGlobSendCnt; // licznik wysłanych ramek od włożenia baterii
	uint32_t PackTime; // data.czas skasowania liczników
	uint32_t SumaXor;
} __attribute__ ((packed)) Pilot_InfoStruct;

//{P-->} ramka informacyjna2 z pilota
typedef struct {
	uint32_t Sign;  //kod stały ramki
	uint8_t cmd;
	uint8_t free[3];
	uint32_t ChipID[3]; //numer seryjny procesora pilota
	uint32_t SumaXor;
} __attribute__ ((packed)) Pilot_ChipIDStruct;

//{-->P} ramka konfiguracyjna do pilota
typedef struct {
	uint32_t Sign;  //kod stały ramki
	uint8_t cmd;
	uint8_t channelNr;  //numer kanału
	uint8_t n_channelNr; // negacja channelNr
	uint8_t txPower;
	uint32_t cmdNr;
	uint32_t SumaXor;
} __attribute__ ((packed)) Pilot_SetupStruct;

//dla rozkazów: plcmdCLR_CNT,plcmdGET_INFO
typedef struct {
	uint32_t Sign;  //kod stały ramki
	uint8_t cmd;
	uint8_t cmdNr;  //numer rozkazu
	uint8_t free[2];
	uint32_t PackTime; // data.cza skasowania liczników
	uint32_t SumaXor;
} __attribute__ ((packed)) Pilot_CmdStruct;


typedef struct {
	uint32_t Sign;  //kod stały ramki
	uint8_t cmd;
	uint8_t ackCmd;  //kod potwierdzanego rozkazu
	uint8_t ackCmdNr; // numer potwierdzanego rozkazu
	uint8_t ackError; //status wykonania operacji
	uint32_t free2;
	uint32_t SumaXor;
} __attribute__ ((packed)) Pilot_AckStruct;

typedef union {
	Pilot_DataStruct data;
	Pilot_InfoStruct info;
	Pilot_SetupStruct setup;
	Pilot_CmdStruct command;
	Pilot_AckStruct ack;
} __attribute__ ((packed)) PilotUnion;

extern void pilotBuildFrameXor(void *p, int len);
extern uint8_t pilotCheckFrame(void *p, int len);

_END_STD_C

#endif /* RFM69_RADIOTYPES_H_ */
