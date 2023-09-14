/*
 * MyConfig.h
 *
 *  Created on: 1 kwi 2021
 *      Author: Grzegorz
 */

#ifndef MAIN_MYCONFIG_H_
#define MAIN_MYCONFIG_H_

#include "stddef.h"
#include "stdint.h"
#include "utils.h"
#include "CxBuf.h"
#include "ErrorDef.h"
#include "nvs.h"
#include "nvs_flash.h"

#define CFG_HIST_CNT    32
#define SIZE_SERIAL_NR  12
#define SIZE_DEV_NAME   32

typedef struct {
	float valFiz;      // wartoœc odniesienia podawana przez u¿ytkownika
	float valMeas;   // wartoœæ z przetwornika
} TKalibrPt;

typedef struct {
	TKalibrPt P0;
	TKalibrPt P1;
} TKalibrDt;

typedef struct {
	uint8_t devType;
	char serNumTxt[SIZE_SERIAL_NR];
	char devID[SIZE_DEV_NAME];

	char WifiSSID[32];
	char WifiPassword[32];
	int16_t WifiAuthMode;
	TKalibrDt kalibrInp;
	TKalibrDt kalibrVBat;
	TKalibrDt kalibrV12;
	TKalibrDt kalibrI12;
} CfgData;

class MyConfig {
private:
	void showCfg();
	char mUsbNameStr[30];
	void loadDefault();
	static void wrFloat(nvs_handle_t handle, const char *name, float f);

	static void wrKalibr(nvs_handle_t handle, const char *key, TKalibrPt *pt);
	static void wrDblKalibr(nvs_handle_t handle, const char *key, TKalibrDt *dblPt);

	static esp_err_t rdFloat(nvs_handle_t handle, const char *name, float *f);
	static esp_err_t rdKalibr(nvs_handle_t handle, const char *key, TKalibrPt *pt);
	static esp_err_t rdDblKalibr(nvs_handle_t handle, const char *key, TKalibrDt *dblPt);

public:
	CfgData cfg;
	MyConfig();
	virtual ~MyConfig();
	void init();
	void defaultCfg();
	void write();
	bool menu(char ch);
	const char* getDevTypeName();
	const char* getDevTypeStr(uint8_t typ);
	const char* getUSBName();
	uint32_t getDevInfoSpecDevData() {
		return 0;
	}

	CxBuf* getCxBufWithCfgBin();
	TStatus setFromKeyBin(const uint8_t *dt, int len);
	void getHistMemInfo(MemInfo *memInfo);
	const char* getSerialNum();
	TStatus setSerialNum(const void *dt, int len);
	TKalibrDt* getKalibr(int klbrCh);

};

#endif /* MAIN_MYCONFIG_H_ */
