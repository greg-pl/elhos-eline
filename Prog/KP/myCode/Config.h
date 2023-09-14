/*
 * Config.h
 *
 *  Created on: Dec 7, 2020
 *      Author: Grzegorz
 */

#ifndef CONFIG_H_
#define CONFIG_H_

#include "myDef.h"
#include "IOStream.h"
#include "CfgBase.h"
#include <CfgTcpInterf.h>
#include <ErrorDef.h>

#define SIZE_DEV_NAME      32
#define SIZE_NET_ADDR      32

typedef char PathStr[SIZE_NET_ADDR];
typedef char NameStr[32];

typedef enum {
	ltCIEZAROWA = 0,   // linia z falownikami
	ltOSOBOWA = 1,     // linia bez falowników
	ltCIEZAROWA_MAHA = 2,
	ltUNKNOWN = -1,
} LiniaType;

typedef struct {
	float valFiz;      // wartośc odniesienia podawana przez użytkownika
	float valMeas;   // wartość z przetwornika
} TKalibrPt;

typedef struct {
	float InpVal_Open;      // wartość z przetwornika dla otwartego 'białego'
	float InpVal_Close;     // wartość z przetwornika dla zwartego 'białego'
} TKalibrZero;

typedef struct {
	TKalibrPt P0;
	TKalibrPt P1;
} TKalibrDt;

typedef struct {
	TKalibrZero Z0;
	TKalibrPt P1;
} TKalibrDtDblZero;

//definicja stałych dla zmiennej KalibQuqlity
#define CALIBR_BY_MEASURE  1  //kalibracja powstała w wyniku pomiaru
#define CALIBR_BY_TEXT     2  //kalibracja została poprzez wpisanie współczynników
#define CALIBR_BY_FUN      3  //kalibracja poprzez funkcję wyliczającą
#define DIG_CHANNEL_CNT       8

typedef struct {
	byte Enabled;
	byte PressBitNr;
	byte RollBitNr;
	byte AnInutNr;
	float RollDiameter;
	int RollImpCnt;
	TKalibrDtDblZero Kalibr;
	byte KalibQuqlity;
} TRollDevCfg;

#define AMOR_KALIBR_CNT 6

typedef struct {
	byte Enabled;
	byte AnInutNr;
	word DeactivTime;  //czas w milisekundach odmierzany prz przejściu ze stanu aktywnego do nieaktywnego
	float DeadZone;     // rozmiar strefy martwej, wykorzystywany do wykrycia najazdu
	TKalibrDt KalibrLn;
	TKalibrPt KalibrTab[AMOR_KALIBR_CNT];
	byte KalibQuqlity;
} TSuspensionDevCfg;

typedef struct {
	byte Enabled;
	byte TypPlyty;
	byte PressNajazdNr;
	byte PressZjazdNr;
	byte AnInutNr;
	byte InvertNajazd;
	byte InvertZjazd;
	byte Free;
	TKalibrDt Kalibr;
	float DeadZone;       // rozmiar strefy martwej, wykorzystywany gdy nie ma czujnika najazdowego
	float MaxMeasTime;  // maksymalny czas pomiaru
	float MinMeasTime;  // minimalny czas pomiaru
	float MaxMeasFlip; // maksymalna wartość przerzucenia w drugą stronę w procentach
	float DeActivtime;      // dla płyty bez czujnków najazdu i zjazdu, czas przez który, po zjeździe płyta zostaje deaktywowana
	float MaxStartZeroShift; //maksymalna wartość przsunięcia, które jest kalibrowane
	float MaxFlipTime; // maksymalna czas przelotu płyty przez zero
} TSlipSideDevCfg;

typedef struct {
	byte AnInputNr;
	word AnZero;
	float WspSkali;
} TWeightChnKalibr;

typedef struct {
	byte Enabled;
	TKalibrPt P1;
	TWeightChnKalibr chKalibr[4];
} TWeightDevCfg;

typedef struct {
	bool Enab;
	byte free[3];
	word RLow;
	word RHigh;
} TBinAsAcOne;

typedef struct {
	TBinAsAcOne inp[8];
} TBinAsAc;

typedef struct {
	ip4_addr_t host_addr;
} OtherCfg;

typedef union {
	TRollDevCfg RollDevCfg;
	byte Buf[0x60];
} TRollDevCfg_Sz;

typedef union {
	TSuspensionDevCfg SuspensionDevCfg;
	byte Buf[0x80];
} TSuspensionDevCfg_Sz;

typedef union {
	TSlipSideDevCfg SlipSideDevCfg;
	byte Buf[0x40];
} TSlipSideDevCfg_Sz;

typedef union {
	TWeightDevCfg WeightDevCfg;
	byte Buf[0x40];
} TWeightDevCfg_Sz;

typedef union {
	TBinAsAc BinAsAcCfg;
	byte Buf[0x60];
} TTBinAsAc_Sz;

typedef union {
	byte Buf[0x80];
	struct {
		TcpInterfDef tcp;
		OtherCfg otherCfg;
	};

} BaseCfg_Sz;

typedef union __PACKED {
	uint8_t buf[CFG_REC_SIZE_USER];
	struct {
		BaseCfg_Sz E;
		TRollDevCfg_Sz H[2];
		TSuspensionDevCfg_Sz S[2];
		TSlipSideDevCfg_Sz L;
		TWeightDevCfg_Sz W[2];
		TTBinAsAc_Sz B;
	};
} UserCfg;

typedef union __PACKED {
	uint8_t tab_b[CFG_REC_MAX_SIZE];
	uint32_t tab_32[CFG_REC_MAX_SIZE_4];
	struct {
		uint8_t tab_bm4[CFG_REC_MAX_SIZE - 4];
		uint16_t free;
		uint16_t Crc;
	};

	struct {
		BaseCfg P;
		HistoryCfg H;
		UserCfg R;
	};

} CfgRec;

class Config: public CfgBase, public CfgTcpInterf {
public:
	enum {
		MAX_ROLL_IMP = 50, //maksymalna ilośc impulsow z rolki na jednym obrocie
	};
private:
	virtual TStatus CheckCfg();
	virtual void prepareToSave();
protected:
	virtual void getDataInfo(CfgDataInfo *info);
public:
	CfgRec data;
	Config();
	virtual void Zero();
	virtual void Default();
	virtual int getJsonSize() {
		return 8000;
	}
public:
	virtual uint32_t getDevInfoSpecDevData();
	virtual const char* getDevSN();
	virtual const char* getDevID();
	virtual void getTcpDef(TcpCfgInterfDef *def);
	virtual void setTcpDef(const TcpCfgInterfDef *def);
};

#endif /* CONFIG_H_ */
