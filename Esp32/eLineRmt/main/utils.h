/*
 * utils.h
 *
 *  Created on: 5 maj 2021
 *      Author: Grzegorz
 */

#ifndef MAIN_UTILS_H_
#define MAIN_UTILS_H_

#include "stdint.h"

#define __WEAK        __attribute__((weak))
#define __PACKED      __attribute__((packed, aligned(1)))

enum {
	MSG_ERR = 1, //
	MSG_INF = 2, //
	MSG_DATA = 3,
};

// plik 'DevTypes.inn'

enum {
	devUNKNOWN=0,
	devHOST,
	devKP,
	devSENS_N,
	devSENS_P,
};

// czêœc pliku 'Group.dsd'
enum {
	dsdUNKNOWN = 0, //
	dsdDEV_COMMON = 1, //
	dsdHOST, //
	dsdKP, //
	dsdSENSOR, //
};

typedef struct {
	uint8_t rk; //
	uint8_t ms; //
	uint8_t dz; //
	uint8_t gd; //
	uint8_t mn; //
	uint8_t sc; //
	uint8_t se; // setne czêœci sekundy
	uint8_t timeSource; //
} TDATE;

typedef struct {
	uint16_t ver;
	uint16_t rev;
	TDATE time;
} VerInfo;

extern "C" uint32_t swap32(uint32_t inp);
extern "C" void putWord(uint8_t *ptr, uint16_t w);
extern "C" uint32_t getDWord(uint8_t *ptr);
extern "C" float getFloat(uint8_t *ptr);

extern "C" const char* YN(bool q);
extern "C" const char* HL(bool q);
extern "C" const char* OnOff(bool q);
extern "C" const char* ErrOk(bool q);
extern "C" const char* OkErr(bool q);
extern "C" const char* FalseTrue(bool q);


typedef struct {
	void *mem;
	int size;
} MemInfo;


class TimeTools {
public:
	enum {
		DT_TM_SIZE = 20, //
		DT_TM_ZZ_SIZE = 24, //
	};
	static bool CheckTime(const TDATE *tm);
	static bool CheckDate(const TDATE *tm);
	static bool CheckDtTm(const TDATE *tm);
	static const char* TimeStr(char *buf, const TDATE *tm);
	static const char* TimeStrZZ(char *buf, const TDATE *tm);
	static const char* DateStr(char *buf, const TDATE *tm);
	static const char* DtTmStr(char *buf, const TDATE *tm);
	static const char* DtTmStrK(char *buf, const TDATE *tm);
	static const char* DtTmStrZZ(char *buf, const TDATE *tm);
	static bool parseTime(const char **cmd, TDATE *Tm);
	static bool parseDate(const char **cmd, TDATE *Tm);
	static void copyDate(TDATE *dst, const TDATE *src);
	static void copyTime(TDATE *dst, const TDATE *src);
	static bool AddHour(TDATE *tm, int delHour);
	static const char* TimeLongStr(char *buf, int milisec);
	static uint16_t PackDate(const TDATE *unp);
	static void UnPackDate(TDATE *unp, uint16_t pack);
	static uint32_t PackTime(const TDATE *unp);
	static void UnPackTime(uint32_t pack, TDATE *unp);

};


#endif /* MAIN_UTILS_H_ */
