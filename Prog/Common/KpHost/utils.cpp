/*
 * utils.cpp
 *
 *  Created on: Dec 5, 2020
 *      Author: Grzegorz
 */
#include "string.h"
#include "stdlib.h"
#include "stdio.h"
#include "math.h"

#include "stm32f4xx_hal.h"

#include "utils.h"
#include "main.h"
#include "myDef.h"
#include <Token.h>
#include <CxString.h>

extern "C" const char* ST3Str(ST3 val) {
	switch (val) {
	case posFREE:
		return "FREE";
	case posGND:
		return "GND";
	case posVCC:
		return "VCC";
	default:
		return "???";
	}
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

extern "C" TermColor getStatusColor(TStatus st) {
	if (st == stOK)
		return colGREEN;
	else
		return colRED;
}

extern "C" const char* getStatusStr(TStatus st) {
	switch (st) {
	case stOK:
		return "OK";
	case stError:
		return "Error";
	case stBusy:
		return "Busy";
	case stTimeOut:
		return "TimeOut";
		//zdefiniowane w programie
	case stCrcError:
		return "CrcError";
	case stCompareErr:
		return "CompareError";
	case stNoSemafor:
		return "SemaforBusy";
	case stDataErr:
		return "DataError";

	default:
		return "Unknown";
	}
}

extern "C" const char* getTmSrcName(uint8_t tmSrc) {
	switch (tmSrc) {
	case tmSrcMANUAL:
		return "srcMANUAL";
	case tmSrcNTP:
		return "srcNTP";
	case tmSrcGPS:
		return "srcGPS";
	case tmFirmVer:
		return "srcFIRMWARE";
	default:
		return "srcUNKNOWN";
	}
}

extern "C" bool strbcmp(const char *buf, const char *wz) {
	int n = strlen(wz);
	return (strncmp(buf, wz, n) == 0);
}

extern "C" bool strbcmp2(const char *buf, const char *wz, const char **rest) {
	int n = strlen(wz);
	bool q = (strncmp(buf, wz, n) == 0);
	if (q) {
		*rest = &buf[n];
	}
	return q;
}

//-------------------------------------------------------------------------------------
// loadSoftVer
//-------------------------------------------------------------------------------------

static uint16_t getDec(const char *p) {
	char ch = *p;
	if (ch >= '0' || ch <= '9')
		return ch - '0';
	else
		return 0;
}

static uint16_t getInt3(const char *p) {
	uint16_t w = getDec(p++) * 100;
	w += getDec(p++) * 10;
	w += getDec(p);
	return w;
}

static uint8_t getInt2(const char *p) {
	uint8_t w = getDec(p++) * 10;
	w += getDec(p);
	return w;
}

//0123456789012345
//Date : 20.06.11
//Time : 00:10:51
//Ver.001 Rev.203

const char Tx1[] = "Date :";
const char Tx2[] = "Time :";
const char Tx3[] = "Ver.";
const char Tx4[] = "Rev.";

bool _strcmp(const char *s1, const char *s2) {
	while (*s1 && *s2) {
		if (*s1 != *s2)
			return false;
		s1++;
		s2++;
	}
	return true;
}

bool loadSoftVer(VerInfo *ver, const char *mem) {
	if (_strcmp(Tx1, &mem[0]) && _strcmp(Tx2, &mem[16]) && _strcmp(Tx3, &mem[32]) && _strcmp(Tx4, &mem[40])) {
		ver->ver = getInt3(&mem[36]);
		ver->rev = getInt3(&mem[44]);
		ver->time.rk = getInt2(&mem[7]);
		ver->time.ms = getInt2(&mem[10]);
		ver->time.dz = getInt2(&mem[13]);
		ver->time.gd = getInt2(&mem[16 + 7]);
		ver->time.mn = getInt2(&mem[16 + 10]);
		ver->time.sc = getInt2(&mem[16 + 13]);
		ver->time.se = 0;
		ver->time.timeSource = tmFirmVer;
		return true;
	} else {
		memset(ver, 0, sizeof(VerInfo));
		return false;
	}
}

const char* binStr(char *buf, uint32_t v, int n) {
	int k = 0;
	for (int i = 0; i < n; i++) {
		char ch = '0';
		int bitNr = n - 1 - i;
		if (((bitNr % 4) == 3) && (i != 0)) {
			buf[k++] = '_';
		}

		uint32_t m = (1 << bitNr);
		if ((v & m) != 0)
			ch = '1';
		buf[k++] = ch;
	}
	buf[k] = 0;

	return buf;

}

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

extern "C" void memDump(OutStream *strm, uint32_t adr, uint8_t *ptr, int cnt) {
	if (strm->oOpen(colWHITE)) {
		CxString *str = new CxString(120);
		int i = 0;
		while (i < cnt) {
			int x = i & 0x0f;

			if (x == 0)
				str->addFormat("%08X: ", adr);
			str->addFormat("%02X ", *ptr);
			if (x == 7)
				str->add(' ');
			if (x == 15) {
				strm->oWr(str->p());
				str->clear();
			}
			adr++;
			ptr++;
			i++;
		}
		if (str->len() > 0)
			strm->oWr(str->p());
		strm->oClose();
	}
}

//-------------------------------------------------------------------------------------

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
		if (tm->dz > 0) { //jeśli zmiana miesiąca to się poddaje
			tm->gd = hr;
			return true;
		}

	} else if (hr >= 24) {
		hr -= 24;
		tm->dz++;
		if (tm->dz <= 28) { //jeśli koniec miesiąca to się poddaje
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

#if (USE_RTC)

//-------------------------------------------------------------------------------------
// Rtc
//-------------------------------------------------------------------------------------

RTC_HandleTypeDef Rtc::hrtc;
HAL_StatusTypeDef Rtc::mRtcStatus;

void Rtc::Init() {
	HAL_PWR_EnableBkUpAccess();

	memset(&hrtc, 0, sizeof(hrtc));
	hrtc.Instance = RTC;
	hrtc.Init.HourFormat = RTC_HOURFORMAT_24;
	hrtc.Init.AsynchPrediv = 32 - 1;
	hrtc.Init.SynchPrediv = 1024 - 1;
	hrtc.Init.OutPut = RTC_OUTPUT_DISABLE;
	hrtc.Init.OutPutPolarity = RTC_OUTPUT_POLARITY_HIGH;
	hrtc.Init.OutPutType = RTC_OUTPUT_TYPE_OPENDRAIN;
	mRtcStatus = HAL_RTC_Init(&hrtc);
	HAL_PWR_DisableBkUpAccess();
}

uint8_t Rtc::getSetne(RTC_TimeTypeDef *sTime) {
	uint32_t b = sTime->SecondFraction + 1;
	float m = 100.0 * (b - sTime->SubSeconds) / b;
	if (m < 0)
		return 0;
	else if (m > 99)
		return 99;
	else
		return (uint8_t) m;
}

bool Rtc::ReadOnlyTime(TDATE *tm) {
	RTC_TimeTypeDef sTime;
	HAL_StatusTypeDef s1 = HAL_RTC_GetTime(&hrtc, &sTime, RTC_FORMAT_BIN);
	if (s1 == HAL_OK) {
		tm->rk = 0;
		tm->ms = 0;
		tm->dz = 0;
		tm->gd = sTime.Hours;
		tm->mn = sTime.Minutes;
		tm->sc = sTime.Seconds;
		tm->se = getSetne(&sTime);
		return true;
	} else
		return false;
}

bool Rtc::ReadTime(TDATE *tm) {
	RTC_TimeTypeDef sTime;
	RTC_DateTypeDef sDate;
	HAL_StatusTypeDef s1 = HAL_RTC_GetTime(&hrtc, &sTime, RTC_FORMAT_BIN);
	HAL_StatusTypeDef s2 = HAL_RTC_GetDate(&hrtc, &sDate, RTC_FORMAT_BIN);
	if (s1 == HAL_OK && s2 == HAL_OK) {
		tm->rk = sDate.Year;
		tm->ms = sDate.Month;
		tm->dz = sDate.Date;
		tm->gd = sTime.Hours;
		tm->mn = sTime.Minutes;
		tm->sc = sTime.Seconds;
		tm->se = getSetne(&sTime);
		return true;
	} else
		return false;
}

bool Rtc::SetDate(const TDATE *tm) {
	RTC_DateTypeDef sDate;

	sDate.WeekDay = RTC_WEEKDAY_MONDAY;
	sDate.Year = tm->rk;
	sDate.Month = tm->ms;
	sDate.Date = tm->dz;

	HAL_PWR_EnableBkUpAccess();
	HAL_StatusTypeDef s2 = HAL_RTC_SetDate(&hrtc, &sDate, RTC_FORMAT_BIN);
	HAL_PWR_DisableBkUpAccess();
	return (s2 == HAL_OK);
}

bool Rtc::SetTime(const TDATE *tm) {
	RTC_TimeTypeDef sTime;

	sTime.Hours = tm->gd;
	sTime.Minutes = tm->mn;
	sTime.Seconds = tm->sc;
	sTime.SubSeconds = 0;
	sTime.TimeFormat = RTC_HOURFORMAT_24;
	sTime.DayLightSaving = RTC_DAYLIGHTSAVING_NONE;
	sTime.StoreOperation = RTC_STOREOPERATION_RESET;

	HAL_PWR_EnableBkUpAccess();
	HAL_StatusTypeDef s1 = HAL_RTC_SetTime(&hrtc, &sTime, RTC_FORMAT_BIN);
	HAL_PWR_DisableBkUpAccess();
	return (s1 == HAL_OK);
}

bool Rtc::SetDtTm(const TDATE *tm) {
	return SetTime(tm) && SetDate(tm);
}

//-------------------------------------------------------------------------------------
// DtFilter
//-------------------------------------------------------------------------------------

void DtFilter::init(float afactor) {
	mFactor = afactor;
	mEmpty = true;
	mState = NAN;
	mNanCnt = 0;
}
void DtFilter::inp(float val) {
	if (!isnanf(val)) {

		if (!mEmpty) {
			mState = mFactor * mState + (1 - mFactor) * val;
		} else {
			mEmpty = false;
			mState = val;
		}
	} else {
		if (!mEmpty) {
			mNanCnt++;
			if (mNanCnt >= 5) {
				mEmpty = true;
				mState = NAN;
			}
		}
	}
}

float DtFilter::get() {
	return mState;

}

#endif

//-----------------------------------------------------------------------------
// TCrc
//-----------------------------------------------------------------------------
uint32_t GlobTime::usek;
uint8_t GlobTime::day;
uint8_t GlobTime::month;
uint8_t GlobTime::year;

const uint8_t DayTab[12] = {
		31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
const uint8_t DayTabP[12] = {
		31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

void GlobTime::incUSek() {
	if (++usek == USEK_PER_DAY) {
		usek = 0;
		day++;
		const uint8_t *dTab = DayTab;
		if ((year & 0x03) == 0)
			dTab = DayTabP;

		if (day >= dTab[month - 1]) {
			day = 1;
			month++;
			if (month >= 13) {
				month = 1;
				year++;
			}
		}
	}
}

void GlobTime::init() {
	usek = 9 * USEK_PER_HOUR;
	day = 22;
	month = 4;
	year = 21;
}

void GlobTime::setTm(const TDATE *aTm) {
	uint32_t tmp;
	tmp = aTm->se * 10;
	tmp += aTm->sc * 1000;
	tmp += aTm->mn * 60 * 1000;
	tmp += aTm->gd * 60 * 60 * 1000;
	usek = tmp;
	day = aTm->dz;
	month = aTm->ms;
	year = aTm->rk;
}

void GlobTime::getTm(TDATE *pTm) {
	pTm->dz = day;
	pTm->ms = month;
	pTm->rk = year;
	uint32_t tmp = usek;
	tmp /= 10;
	pTm->se = tmp % 100;
	tmp /= 100;
	pTm->sc = tmp % 60;
	tmp /= 60;
	pTm->mn = tmp % 60;
	tmp /= 60;
	pTm->gd = tmp;
}

//-------------------------------------------------------------------
// TDigiFiltr
//-------------------------------------------------------------------
DigiFiltrTm::DigiFiltrTm(int aFiltrTmUp, int aFiltrTmDn) {
	mFiltrTmUp = aFiltrTmUp;
	mFiltrTmDn = aFiltrTmDn;
	mVal = false;
	mTimer = 0;
	FLastTickCnt = HAL_GetTick();
}

DigiFiltrTm::DigiFiltrTm(int aFiltrTm) {
	mFiltrTmUp = aFiltrTm;
	mFiltrTmDn = aFiltrTm;
	mVal = false;
	mTimer = 0;
	FLastTickCnt = HAL_GetTick();
}

void DigiFiltrTm::setTimes(int aFiltrTmUp, int aFiltrTmDn) {
	mFiltrTmUp = aFiltrTmUp;
	mFiltrTmDn = aFiltrTmDn;
	mTimer = 0;
}

void DigiFiltrTm::input(bool x) {

	uint32_t TT = HAL_GetTick();
	if (TT == FLastTickCnt)
		return;

	FLastTickCnt =TT;

	FLastTickCnt = TT;
	if (x != mVal) {
		if (mTimer == 0) {
			mTimer = TT;
		} else {
			bool q;
			if (!mVal)
				q = (TT - mTimer > mFiltrTmUp);
			else
				q = (TT - mTimer > mFiltrTmDn);

			if (q) {
				mVal = x;
				mTimer = 0;
			}
		}
	} else
		mTimer = 0;
}

//-----------------------------------------------------------------------------
// TCrc
//-----------------------------------------------------------------------------

static const uint16_t CrcTab[256] = {
		0x0000, 0xC0C1, 0xC181, 0x0140, 0xC301, 0x03C0, 0x0280, 0xC241, 0xC601, 0x06C0, 0x0780, 0xC741, 0x0500, 0xC5C1, 0xC481, 0x0440, 0xCC01, 0x0CC0, 0x0D80, 0xCD41, 0x0F00, 0xCFC1, 0xCE81, 0x0E40,
		0x0A00, 0xCAC1, 0xCB81, 0x0B40, 0xC901, 0x09C0, 0x0880, 0xC841, 0xD801, 0x18C0, 0x1980, 0xD941, 0x1B00, 0xDBC1, 0xDA81, 0x1A40, 0x1E00, 0xDEC1, 0xDF81, 0x1F40, 0xDD01, 0x1DC0, 0x1C80, 0xDC41,
		0x1400, 0xD4C1, 0xD581, 0x1540, 0xD701, 0x17C0, 0x1680, 0xD641, 0xD201, 0x12C0, 0x1380, 0xD341, 0x1100, 0xD1C1, 0xD081, 0x1040, 0xF001, 0x30C0, 0x3180, 0xF141, 0x3300, 0xF3C1, 0xF281, 0x3240,
		0x3600, 0xF6C1, 0xF781, 0x3740, 0xF501, 0x35C0, 0x3480, 0xF441, 0x3C00, 0xFCC1, 0xFD81, 0x3D40, 0xFF01, 0x3FC0, 0x3E80, 0xFE41, 0xFA01, 0x3AC0, 0x3B80, 0xFB41, 0x3900, 0xF9C1, 0xF881, 0x3840,
		0x2800, 0xE8C1, 0xE981, 0x2940, 0xEB01, 0x2BC0, 0x2A80, 0xEA41, 0xEE01, 0x2EC0, 0x2F80, 0xEF41, 0x2D00, 0xEDC1, 0xEC81, 0x2C40, 0xE401, 0x24C0, 0x2580, 0xE541, 0x2700, 0xE7C1, 0xE681, 0x2640,
		0x2200, 0xE2C1, 0xE381, 0x2340, 0xE101, 0x21C0, 0x2080, 0xE041, 0xA001, 0x60C0, 0x6180, 0xA141, 0x6300, 0xA3C1, 0xA281, 0x6240, 0x6600, 0xA6C1, 0xA781, 0x6740, 0xA501, 0x65C0, 0x6480, 0xA441,
		0x6C00, 0xACC1, 0xAD81, 0x6D40, 0xAF01, 0x6FC0, 0x6E80, 0xAE41, 0xAA01, 0x6AC0, 0x6B80, 0xAB41, 0x6900, 0xA9C1, 0xA881, 0x6840, 0x7800, 0xB8C1, 0xB981, 0x7940, 0xBB01, 0x7BC0, 0x7A80, 0xBA41,
		0xBE01, 0x7EC0, 0x7F80, 0xBF41, 0x7D00, 0xBDC1, 0xBC81, 0x7C40, 0xB401, 0x74C0, 0x7580, 0xB541, 0x7700, 0xB7C1, 0xB681, 0x7640, 0x7200, 0xB2C1, 0xB381, 0x7340, 0xB101, 0x71C0, 0x7080, 0xB041,
		0x5000, 0x90C1, 0x9181, 0x5140, 0x9301, 0x53C0, 0x5280, 0x9241, 0x9601, 0x56C0, 0x5780, 0x9741, 0x5500, 0x95C1, 0x9481, 0x5440, 0x9C01, 0x5CC0, 0x5D80, 0x9D41, 0x5F00, 0x9FC1, 0x9E81, 0x5E40,
		0x5A00, 0x9AC1, 0x9B81, 0x5B40, 0x9901, 0x59C0, 0x5880, 0x9841, 0x8801, 0x48C0, 0x4980, 0x8941, 0x4B00, 0x8BC1, 0x8A81, 0x4A40, 0x4E00, 0x8EC1, 0x8F81, 0x4F40, 0x8D01, 0x4DC0, 0x4C80, 0x8C41,
		0x4400, 0x84C1, 0x8581, 0x4540, 0x8701, 0x47C0, 0x4680, 0x8641, 0x8201, 0x42C0, 0x4380, 0x8341, 0x4100, 0x81C1, 0x8081, 0x4040 };

uint16_t TCrc::Proceed(uint16_t Crc, uint8_t inp) {
	return (CrcTab[(Crc ^ inp) & 0xff] ^ (Crc >> 8));
}

uint16_t TCrc::Build(const uint8_t *p, int cnt) {
	uint16_t crc;

	crc = 0xffff;
	while (cnt) {
		crc = Proceed(crc, *p++);
		cnt--;
	}
	return (crc);
}

bool TCrc::Check(const uint8_t *p, int cnt) {
	return (Build(p, cnt) == 0);
}

void TCrc::Set(uint8_t *p, int cnt) {
	uint16_t crc;

	crc = Build(p, cnt);
	p += cnt;
	*p++ = crc & 0xff;
	*p = crc >> 8;
}
