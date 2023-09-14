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



typedef union {
	byte Buf[0x80];
	struct {
		TcpInterfDef tcp;
		int lcdScrNr;
		int lcdSwitchTime;
	};
} BaseCfg_Sz;

typedef union {
	byte Buf[0x40];
	struct {
		LiniaType liniaType;
		uint8_t falownikType;
		int radioChannel; //0..15
		int radioTxPower; // 0..31
		float falowFreqLow; //częstotliwość falownika dla 2.5[km/h]
		float falowFreqHigh; //częstotliwość falownika dla 5.0[km/h]
		float falowFreqSupport; //częstotliwość falownika przy wspomaganiu wyjazdu
		uint8_t pilotBeep; // czy ma robić beep
	};
} HostCfg_Sz;

typedef union {
	byte Buf[0x40];
	struct {
		bool emerPilotOFF; // awaryjne wyłączanie pilotem
		bool emerRolerOffAfterBeamUp; // awaryjne wyłączanie rolek po podniesieniu belek
		bool emerRolerOffAfterPCLost; // awaryjne wyłączanie rolek po utracie połaczenia z PC
		bool emerInverterOFFAfterConnLost; // awaryjne wyłączanie falowników po zaniku komunikacji z nimi
		float delayRolerOffAfterBeamUp; // opóżnienie wyłaczenia rolek po podniesieniu belek
		float delayRolerOffAfterPCLost; // opóźnienie awaryjnego wyłączania rolek po utracie połaczenia z PC
		float delayInverterOFFAfterConnLost; // opóźnienie awaryjnego wyłączania falowników po zaniku komunikacji z nimi
	};
} EmergCfg_Sz;

typedef union  {
	uint8_t buf[CFG_REC_SIZE_USER];
	struct {
		BaseCfg_Sz B;
		HostCfg_Sz H;
		EmergCfg_Sz E;
	};
} UserCfg;

typedef union  {
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
public:
	virtual uint32_t getDevInfoSpecDevData();
	virtual const char* getDevSN();
	virtual const char* getDevID();
	virtual void getTcpDef(TcpCfgInterfDef *def);
	virtual void setTcpDef(const TcpCfgInterfDef *def);
};

#endif /* CONFIG_H_ */
