/*
 * utils.cpp
 *
 *  Created on: 5 maj 2021
 *      Author: Grzegorz
 */
#include "string.h"
#include "stdio.h"
#include "math.h"

#include "utils.h"
#include "Token.h"

extern "C" uint32_t swap32(uint32_t inp) {
	uint32_t res;
	uint8_t *x = (uint8_t*) &inp;
	uint8_t *y = (uint8_t*) &res;
	y[0] = x[3];
	y[1] = x[2];
	y[2] = x[1];
	y[3] = x[0];
	return res;
}

extern "C" void putWord(uint8_t *ptr, uint16_t w) {
	ptr[0] = w & 0xff;
	ptr[1] = w >> 8;
}

extern "C" uint32_t getDWord(uint8_t *ptr) {
	uint32_t res;

	memcpy(&res, ptr, 4);
	return res;
}

float getFloat(uint8_t *ptr) {
	float res;

	memcpy(&res, ptr, 4);
	return res;

}

extern "C" const char* YN(bool q) {
	if (q)
		return "YES";
	else
		return "NO";
}
extern "C" const char* HL(bool q) {
	if (q)
		return "HIGH";
	else
		return "LOW";

}
extern "C" const char* OnOff(bool q) {
	if (q)
		return "ON";
	else
		return "OFF";
}

extern "C" const char* ErrOk(bool q) {
	if (q)
		return "ERR";
	else
		return "OK";
}

extern "C" const char* OkErr(bool q) {
	if (q)
		return "OK";
	else
		return "ERR";
}

extern "C" const char* FalseTrue(bool q) {
	if (q)
		return "true";
	else
		return "false";
}


//-------------------------------------------------------------------------------------
// TimeTools
//-------------------------------------------------------------------------------------

bool TimeTools::CheckTime(const TDATE *tm) {
	if (tm->se >= 100)
		return false;
	if (tm->sc >= 60)
		return false;
	if (tm->mn >= 60)
		return false;
	if (tm->gd >= 24)
		return false;
	return true;
}

static uint8_t tabMs[12] = {
		31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

bool TimeTools::CheckDate(const TDATE *tm) {
	if (tm->dz == 0)
		return false;
	if (tm->ms == 0 || tm->ms > 12)
		return false;
	if (tm->rk > 100)
		return false;
	if (tm->dz > tabMs[tm->ms - 1])
		return false;
	if ((tm->ms == 2) && ((tm->rk % 4) != 0) && (tm->dz > 28))
		return false;
	return true;
}

bool TimeTools::CheckDtTm(const TDATE *tm) {
	return CheckTime(tm) && CheckDate(tm);
}

const char* TimeTools::TimeStrZZ(char *buf, const TDATE *tm) {
	if (CheckTime(tm)) {
		sprintf(buf, "%02u:%02u:%02u,%02u", tm->gd, tm->mn, tm->sc, tm->se);
	} else {
		strcpy(buf, "??:??:??,??");
	}
	return buf;
}

const char* TimeTools::TimeStr(char *buf, const TDATE *tm) {
	if (CheckTime(tm)) {
		sprintf(buf, "%02u:%02u:%02u", tm->gd, tm->mn, tm->sc);
	} else {
		strcpy(buf, "??:??:??");
	}
	return buf;
}

const char* TimeTools::DateStr(char *buf, const TDATE *tm) {
	if (CheckDate(tm)) {
		sprintf(buf, "%04u.%02u.%02u", 2000 + tm->rk, tm->ms, tm->dz);
	} else {
		strcpy(buf, "????.??.??");
	}
	return buf;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wformat-truncation"


//buf- 20 czar
const char* TimeTools::DtTmStr(char *buf, const TDATE *tm) {
	if (CheckDtTm(tm)) {
		snprintf(buf, DT_TM_SIZE, "%04u.%02u.%02u %02u:%02u:%02u", 2000 + tm->rk, tm->ms, tm->dz, tm->gd, tm->mn, tm->sc);
	} else {
		strcpy(buf, "????.??.?? ??:??:??");
	}
	return buf;
}

const char* TimeTools::DtTmStrK(char *buf, const TDATE *tm) {
	if (CheckDtTm(tm)) {
		snprintf(buf, DT_TM_SIZE, "%02u.%02u.%02u %02u:%02u:%02u", tm->rk, tm->ms, tm->dz, tm->gd, tm->mn, tm->sc);
	} else {
		strcpy(buf, "????.??.?? ??:??:??");
	}
	return buf;
}

const char* TimeTools::DtTmStrZZ(char *buf, const TDATE *tm) {
	if (CheckDtTm(tm)) {
		snprintf(buf, DT_TM_ZZ_SIZE, "%04u.%02u.%02u %02u:%02u:%02u,%02u", 2000 + tm->rk, tm->ms, tm->dz, tm->gd, tm->mn, tm->sc, tm->se);
	} else {
		strcpy(buf, "????.??.?? ??:??:??");
	}
	return buf;
}

#pragma GCC diagnostic pop

bool TimeTools::parseTime(const char **cmd, TDATE *Tm) {
	int gd, mn, sc;
	bool q1 = Token::getAsInt(cmd, ":", &gd);
	bool q2 = Token::getAsInt(cmd, ":", &mn);
	bool q3 = Token::getAsInt(cmd, ":", &sc);
	if (q1 && q2 && q3) {
		Tm->gd = gd;
		Tm->mn = mn;
		Tm->sc = sc;
		return CheckTime(Tm);
	}
	return false;
}

bool TimeTools::parseDate(const char **cmd, TDATE *Tm) {
	int rk, ms, dz;
	bool q1 = Token::getAsInt(cmd, ".", &rk);
	bool q2 = Token::getAsInt(cmd, ".", &ms);
	bool q3 = Token::getAsInt(cmd, ".", &dz);
	if (q1 && q2 && q3) {
		if (rk > 2000) {
			Tm->rk = rk - 2000;
			Tm->ms = ms;
			Tm->dz = dz;
			return CheckDate(Tm);
		}
	}
	return false;
}
void TimeTools::copyDate(TDATE *dst, const TDATE *src) {
	dst->rk = src->rk;
	dst->ms = src->ms;
	dst->dz = src->dz;
}
void TimeTools::copyTime(TDATE *dst, const TDATE *src) {
	dst->gd = src->gd;
	dst->mn = src->mn;
	dst->sc = src->sc;

}

//wersja bardzo uproszczona
bool TimeTools::AddHour(TDATE *tm, int delHour) {
	if (delHour == 0)
		return true;
	int hr = tm->gd + delHour;
	if (hr < 0) {
		hr += 24;
		tm->dz--;
		if (tm->dz > 0) { //jeœli zmiana miesi¹ca to siê poddaje
			tm->gd = hr;
			return true;
		}

	} else if (hr >= 24) {
		hr -= 24;
		tm->dz++;
		if (tm->dz <= 28) { //jeœli koniec miesi¹ca to siê poddaje
			tm->gd = hr;
			return true;
		}
	} else {
		tm->gd = hr;
		return true;
	}
	return false;
}

//max 20znaków
const char* TimeTools::TimeLongStr(char *buf, int milisec) {
	float sec = (float) milisec / 1000.0;
	if (sec < 60)
		snprintf(buf, 20, "%.1f[s]", sec);
	else {
		float min = trunc(sec / 60);
		sec -= 60 * min;

		snprintf(buf, 20, "%dm%ds", (int) min, (int) sec);
	}
	return buf;

}

typedef union {
	struct {
		uint16_t dz :5;
		uint16_t ms :4;
		uint16_t rk :7;
	} BIT;
	struct {
		uint8_t b0;
		uint8_t b1;
	} BYTES;
	uint16_t PACK;
} TPACKDATE;

uint16_t TimeTools::PackDate(const TDATE *unp) {
	TPACKDATE Tm;

	Tm.BIT.dz = unp->dz;
	Tm.BIT.ms = unp->ms;
	Tm.BIT.rk = (2000 + unp->rk) - 1980;
	return (Tm.PACK);
}

void TimeTools::UnPackDate(TDATE *unp, uint16_t pack) {
	TPACKDATE Tm;
	int y;

	Tm.PACK = pack;
	unp->sc = 0;
	unp->mn = 0;
	unp->gd = 0;
	unp->dz = Tm.BIT.dz;
	unp->ms = Tm.BIT.ms;
	y = (1980 + Tm.BIT.rk) - 2000;
	if (y < 0)
		y = 0;
	unp->rk = y;
}

typedef union {
	struct {
		uint32_t sc :5;
		uint32_t mn :6;
		uint32_t gd :5;
		uint32_t dz :5;
		uint32_t ms :4;
		uint32_t rk :7;
	} BIT;
	struct {
		uint8_t b0;
		uint8_t b1;
		uint8_t b2;
		uint8_t b3;
	} BYTES;
	uint32_t PACK;
} TPACKTIME;

uint32_t TimeTools::PackTime(const TDATE *unp) {
	TPACKTIME Tm;

	Tm.BIT.sc = unp->sc / 2;
	Tm.BIT.mn = unp->mn;
	Tm.BIT.gd = unp->gd;
	Tm.BIT.dz = unp->dz;
	Tm.BIT.ms = unp->ms;
	Tm.BIT.rk = (2000 + unp->rk) - 1980;
	return Tm.PACK;
}

void TimeTools::UnPackTime(uint32_t pack, TDATE *unp) {
	TPACKTIME Tm;

	Tm.PACK = pack;
	unp->sc = 2 * Tm.BIT.sc;
	unp->mn = Tm.BIT.mn;
	unp->gd = Tm.BIT.gd;
	unp->dz = Tm.BIT.dz;
	unp->ms = Tm.BIT.ms;
	int y = (1980 + Tm.BIT.rk) - 2000;
	if (y < 0)
		y = 0;
	unp->rk = y;
}
