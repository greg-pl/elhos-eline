#ifndef __KEYLOG_MODULE__
#define __KEYLOG_MODULE__

#include "stdint.h"
#include "_ansi.h"

_BEGIN_STD_C

#define KEYLOG_PACKET_SIZE   0x20
#define KEYLOG_DATA_SIZE     (KEYLOG_PACKET_SIZE-8)
#define KEYLOG_MAX_PACK_NR   21

#define SIGN_PKT_F 0x11E7
#define SIGN_PKT_R 0x2E69
#define SIGN_PKT_T 0x10A0
#define SIGN_PKT_X 0x2580
#define SIGN_PKT_W 0xC3AB
#define SIGN_PKT_I 0x8E29
#define SIGN_PKT_Q 0x4AC5
#define SIGN_RPL_XOR 0x15A6
#define SIGN_REPL_SIGN 0x4747

//struktura zapisywana w Eeprom
typedef struct {
	uint16_t SerNumber;
	uint16_t ProductionDate;
	uint8_t Version; //wersja zapisanych danych
	uint8_t free[3];
} __attribute__ ((packed)) TKeyLogInfo;

// defincje pola Mode w TKeyLogData
#define kmdOFF   0
#define kmdON    1
#define kmdDEMO  2

//struktura zapisywana w Eeprom i transportowana w ramce po 3 sztuki
typedef union {
	struct {
		uint8_t Mode;  // 0, 0xff-Close, 1-Open, 2-TimeOpen
		uint8_t Free;
		uint16_t ValidDate;
		uint16_t ValidCnt;
		uint16_t Free2;
	} __attribute__ ((packed)) R;
	uint8_t buf[8];
} TKeyLogItem;

//--------------------------------------------------------------
// Struktury transportowe
//--------------------------------------------------------------

//pakiet transportowy
typedef union {
	struct {
		uint16_t Sign;
		uint8_t Cmd;
		union {
			uint8_t RecNr;
			uint8_t ErrCode;
		};
		uint16_t RepSign;
		uint8_t Data[KEYLOG_DATA_SIZE];
		uint16_t Crc;
	} __attribute__ ((packed)) R;
	uint8_t buf[KEYLOG_PACKET_SIZE];
} TKeyLogPacket;

//struktura trnsportowana w ramce
typedef struct {
	uint8_t RecNr;          // numer rekordu, kt�rym nale�y zwi�kszy� licznik
	uint8_t IncDec;         // 0-Decrementation 1-Incrementation
} __attribute__ ((packed)) TKeyLogIncRec;

//struktura transportowana w ramce
typedef struct {
	uint16_t Ver;
	uint16_t Rev;
	uint8_t PacketCnt;
	TKeyLogInfo Info;
} __attribute__ ((packed)) TKeyLogInfoRec;

//----------------------
// Query
//----------------------
#define REC_NR_OUT_IN 47

//struktura zapytania o aktywność
typedef struct {
	uint16_t tabK1[4];
	uint8_t RecNrMx;
	uint8_t Zero;
	uint16_t time;
	uint16_t tabK2[6];
} __attribute__ ((packed)) TKeyLogQueryIn;

#define ACTIV_ON   0x67
#define ACTIV_OFF  0x23
#define REC_NR_OUT_ADD 117

typedef struct {
	uint16_t tabK1[7];
	uint8_t RecNrMx; //RecNr powiększony o stalą
	uint8_t Activ;
	uint16_t tabK2[4];
} __attribute__ ((packed)) TKeyLogQueryOut;


extern void KeyLogQueryBuild(TKeyLogQueryIn *in, uint8_t recNr);
extern void KeyLogQueryReply(TKeyLogQueryOut *out, const TKeyLogQueryIn *in, uint8_t recNr, uint8_t onV);

enum {
	keyBAD_RPL = 0, keyNO_ACTIV = 1, keyACTIV = 2
};
extern uint8_t KeyLogCheckQueryReply(const TKeyLogQueryOut *out, const TKeyLogQueryIn *in);

_END_STD_C

#endif
