/*
 * MyConfig.cpp
 *
 *  Created on: 1 kwi 2021
 *      Author: Grzegorz
 */
#include <string.h>
#include <sys/param.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "esp_netif.h"
#include "esp_log.h"


#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include <lwip/netdb.h>
#include <MyConfig.h>
#include "Cpx.h"

enum {
#include "SensorDev.itm"
};

extern "C" OutStream* getOutStream();

static const char *TAG = "Cfg";


#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmissing-field-initializers"

const CpxDescr KalibrPtDscr[] = { //
		{ ctype : cpxFLOAT, id:cfgX_xValFiz, ofs: offsetof(TKalibrPt, valFiz), Name : "ValFiz", size: sizeof(TKalibrPt::valFiz) }, //
				{ ctype : cpxFLOAT, id:cfgX_xValMeas, ofs: offsetof(TKalibrPt, valMeas), Name : "ValMeas", size: sizeof(TKalibrPt::valMeas) }, //
				{ ctype : cpxNULL } };

const CpxChildInfo KalibrDtChild = { itemCnt : 1, itemSize : sizeof(TKalibrPt), defs : KalibrPtDscr };
const CpxDescr KalibrDtDscr[] = { //
		{ ctype : cpxCHILD, id:cfgX_yP0, ofs: offsetof(TKalibrDt, P0), Name : "P0", size:0, exPtr: &KalibrDtChild }, //
				{ ctype : cpxCHILD, id:cfgX_yP1, ofs: offsetof(TKalibrDt, P1), Name : "P1", size:0, exPtr: &KalibrDtChild }, //
				{ ctype : cpxNULL } };

const CpxChildInfo KalibrChild = { itemCnt : 1, itemSize : sizeof(TKalibrDt), defs : KalibrDtDscr, flags:flagSHOWBR };

const CpxDescr ConfigDscr[] = { //
		{ ctype : cpxBYTE, id:cfgA_DEVTYPE, ofs: offsetof(CfgData, devType), Name : "DevType", size:sizeof(CfgData::devType) }, //

				{ ctype : cpxSTR, id:cfgA_SN, ofs: offsetof(CfgData, serNumTxt), Name : "SerNum", size:sizeof(CfgData::serNumTxt) }, //
				{ ctype : cpxSTR, id:cfgA_DevID, ofs: offsetof(CfgData, devID), Name : "devID", size:sizeof(CfgData::devID) }, //

				{ ctype : cpxCHILD, id:cfgA_pKalibrInp, ofs: offsetof(CfgData, kalibrInp), Name : "KalibrInp", size:0, exPtr: &KalibrChild }, //
				{ ctype : cpxCHILD, id:cfgA_pKalibrVBat, ofs: offsetof(CfgData, kalibrVBat), Name : "KalibrVBat", size:0, exPtr: &KalibrChild }, //
				{ ctype : cpxCHILD, id:cfgA_pKalibrV12, ofs: offsetof(CfgData, kalibrV12), Name : "KalibrV12", size:0, exPtr: &KalibrChild }, //
				{ ctype : cpxCHILD, id:cfgA_pKalibrI12, ofs: offsetof(CfgData, kalibrI12), Name : "KalibrI12", size:0, exPtr: &KalibrChild }, //

				{ ctype : cpxNULL, id:0, ofs:0, Name:"eof", size:0, exPtr:NULL }

		};
#pragma GCC diagnostic pop

MyConfig::MyConfig() {
	mUsbNameStr[0] = 0;
}

MyConfig::~MyConfig() {

}

void MyConfig::wrFloat(nvs_handle_t handle, const char *name, float f) {
	uint32_t *pw = (uint32_t*) &f;
	uint32_t w = *pw;

	nvs_set_u32(handle, name, w);
}

void MyConfig::wrKalibr(nvs_handle_t handle, const char *key, TKalibrPt *pt) {
	char mkey[20];

	snprintf(mkey, sizeof(mkey), "%s_Fiz", key);
	wrFloat(handle, mkey, pt->valFiz);
	snprintf(mkey, sizeof(mkey), "%s_Meas", key);
	wrFloat(handle, mkey, pt->valMeas);
}

void MyConfig::wrDblKalibr(nvs_handle_t handle, const char *key, TKalibrDt *dblPt) {
	char mkey[20];

	snprintf(mkey, sizeof(mkey), "%s_P0", key);
	wrKalibr(handle, mkey, &dblPt->P0);
	snprintf(mkey, sizeof(mkey), "%s_P1", key);
	wrKalibr(handle, mkey, &dblPt->P1);
}

esp_err_t MyConfig::rdFloat(nvs_handle_t handle, const char *name, float *f) {
	uint32_t w;
	esp_err_t err = nvs_get_u32(handle, name, &w);
	if (err == ESP_OK) {
		*f = *(float*) &w;
	}
	return err;
}

esp_err_t MyConfig::rdKalibr(nvs_handle_t handle, const char *key, TKalibrPt *pt) {
	char mkey[20];

	snprintf(mkey, sizeof(mkey), "%s_Fiz", key);
	esp_err_t err1 = rdFloat(handle, mkey, &pt->valFiz);
	snprintf(mkey, sizeof(mkey), "%s_Meas", key);
	esp_err_t err2 = rdFloat(handle, mkey, &pt->valMeas);
	if (err1 == ESP_OK)
		err1 = err2;
	return err1;
}

esp_err_t MyConfig::rdDblKalibr(nvs_handle_t handle, const char *key, TKalibrDt *dblPt) {
	char mkey[20];

	snprintf(mkey, sizeof(mkey), "%s_P0", key);
	esp_err_t err1 = rdKalibr(handle, mkey, &dblPt->P0);
	snprintf(mkey, sizeof(mkey), "%s_P1", key);
	esp_err_t err2 = rdKalibr(handle, mkey, &dblPt->P1);
	if (err1 == ESP_OK)
		err1 = err2;
	return err1;
}

void MyConfig::init() {
	esp_err_t ret = nvs_flash_init();
	if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
		ESP_ERROR_CHECK(nvs_flash_erase());
		ret = nvs_flash_init();
	}
	nvs_handle_t handle;

	loadDefault();

	ret = nvs_open("sLINE", NVS_READONLY, &handle);
	if (ret == ESP_OK) {
		size_t len = sizeof(cfg.WifiSSID);
		nvs_get_str(handle, "WifiSSID", cfg.WifiSSID, &len);
		len = sizeof(cfg.WifiPassword);
		nvs_get_str(handle, "WifiPassword", cfg.WifiPassword, &len);
		if (nvs_get_i16(handle, "WifiAuthMode", &cfg.WifiAuthMode) != ESP_OK)
			cfg.WifiAuthMode = 3; //WIFI_AUTH_WPA2_PSK

		len = sizeof(cfg.devID);
		nvs_get_str(handle, "devID", cfg.devID, &len);

		len = sizeof(cfg.serNumTxt);
		nvs_get_str(handle, "SerNameTxt", cfg.serNumTxt, &len);

		int8_t typ = devUNKNOWN;
		nvs_get_i8(handle, "DevType", &typ);
		if (typ != devSENS_N && typ != devSENS_P)
			typ = devUNKNOWN;
		cfg.devType = typ;


		rdDblKalibr(handle, "KlbInp", &cfg.kalibrInp);
		rdDblKalibr(handle, "KlbVBat", &cfg.kalibrVBat);
		rdDblKalibr(handle, "KlbI12", &cfg.kalibrI12);
		rdDblKalibr(handle, "KlbV12", &cfg.kalibrV12);


		nvs_close(handle);
	} else {
		defaultCfg();
		ESP_LOGE(TAG,"CfgDefault");
	}

}

void MyConfig::loadDefault() {
	strcpy(cfg.WifiSSID, "KANIA-A");
	strcpy(cfg.WifiPassword, "mikemia7");
	cfg.WifiAuthMode = 1;  //WIFI_AUTH_WEP
	cfg.devType = devSENS_N;
	strcpy(cfg.serNumTxt, "A00001");

	uint8_t mac[6];
	esp_efuse_mac_get_default(mac);

	int serNum = mac[4] << 8 | mac[5];
	snprintf(cfg.devID, sizeof(cfg.devID), "SENS_%u", serNum);

	cfg.kalibrInp.P0.valFiz = 0;
	cfg.kalibrInp.P0.valMeas = 0;
	cfg.kalibrInp.P1.valFiz = 100;
	cfg.kalibrInp.P1.valMeas = 50.0; //50% zakresu

	cfg.kalibrVBat.P0.valFiz = 0;
	cfg.kalibrVBat.P0.valMeas = 0;
	cfg.kalibrVBat.P1.valFiz = 3;
	cfg.kalibrVBat.P1.valMeas = 50.0; //50% zakresu

	cfg.kalibrV12.P0.valFiz = 0;
	cfg.kalibrV12.P0.valMeas = 0;
	cfg.kalibrV12.P1.valFiz = 6;
	cfg.kalibrV12.P1.valMeas = 50.0; //50% zakresu

	cfg.kalibrI12.P0.valFiz = 0;
	cfg.kalibrI12.P0.valMeas = 0;
	cfg.kalibrI12.P1.valFiz = 0.2;
	cfg.kalibrI12.P1.valMeas = 50.0; //50% zakresu
}

void MyConfig::defaultCfg() {
	loadDefault();
	write();
}

extern "C" void afterNewCfg();


void MyConfig::write() {
	nvs_handle_t handle;
	esp_err_t ret = nvs_open("sLINE", NVS_READWRITE, &handle);
	if (ret == ESP_OK) {
		nvs_set_str(handle, "WifiSSID", cfg.WifiSSID);
		nvs_set_str(handle, "WifiPassword", cfg.WifiPassword);
		nvs_set_i16(handle, "WifiAuthMode", cfg.WifiAuthMode);
		nvs_set_str(handle, "devID", cfg.devID);
		nvs_set_i8(handle, "DevType", cfg.devType);

		wrDblKalibr(handle, "KlbInp", &cfg.kalibrInp);
		wrDblKalibr(handle, "KlbVBat", &cfg.kalibrVBat);
		wrDblKalibr(handle, "KlbV12", &cfg.kalibrV12);
		wrDblKalibr(handle, "KlbI12", &cfg.kalibrI12);

		nvs_close(handle);

		afterNewCfg();
	}
}

const char* MyConfig::getUSBName() {
	uint8_t mac[6];
	esp_efuse_mac_get_default(mac);
	int serNum = mac[4] << 8 | mac[5];
	snprintf(mUsbNameStr, sizeof(mUsbNameStr), "eLine-%05d", serNum);
	return mUsbNameStr;
}

const char* MyConfig::getDevTypeName() {
	switch (cfg.devType) {
	default:
	case devUNKNOWN:
		return "eLineSENS_?";
	case devSENS_N:
		return "eLineSENS_F";
	case devSENS_P:
		return "eLineSENS_P";
	}
}

const char* MyConfig::getDevTypeStr(uint8_t typ) {
	switch (typ) {
	default:
	case devUNKNOWN:
		return "nie zdefiniowany";
	case devSENS_N:
		return "Nacisk";
	case devSENS_P:
		return "Cisnienie";
	}

}

CxBuf* MyConfig::getCxBufWithCfgBin() {
	int sz = 0x200;
	CxBuf *buf = new CxBuf(sz, 0x100);
	Cpx cpx;

	cpx.init(ConfigDscr, &cfg);
	cpx.buildBinCfg(buf);
	return buf;
}

TStatus MyConfig::setFromKeyBin(const uint8_t *dt, int len) {
	Cpx cpx;

	cpx.init(ConfigDscr, &cfg);

	TStatus st = cpx.InsertChanges(getOutStream(), dt, len);
	if (st == stOK)
		write();
	return st;

}
void MyConfig::getHistMemInfo(MemInfo *memInfo) {

}
const char* MyConfig::getSerialNum() {
	return cfg.serNumTxt;

}
TStatus MyConfig::setSerialNum(const void *dt, int len) {

	if (len > (int) sizeof(cfg.serNumTxt) - 1)
		len = sizeof(cfg.serNumTxt) - 1;
	memcpy(cfg.serNumTxt, dt, len);
	cfg.serNumTxt[len] = 0;
	write();
	return stOK;

}

TKalibrDt* MyConfig::getKalibr(int klbrCh) {
	switch (klbrCh) {
	case 0:
		return &cfg.kalibrInp;
	case 1:
		return &cfg.kalibrVBat;
	case 2:
		return &cfg.kalibrV12;
	case 3:
		return &cfg.kalibrI12;
	default:
		return NULL;
	}
}

void MyConfig::showCfg() {
	printf("PRODUCER\n");
	printf("DevType:%s\n", getDevTypeStr(cfg.devType));
	printf("USER\n");
	printf("devID:%s\n", cfg.devID);
	printf("WifiSSID:%s\n", cfg.WifiSSID);
	printf("WifiPassword:%s\n", cfg.WifiPassword);
	printf("WifiAuthMode:%d\n", cfg.WifiAuthMode);
}

bool MyConfig::menu(char ch) {
	switch (ch) {
	case 's':
		showCfg();
		break;
	case 'h': {
		Cpx cpx;

		cpx.init(ConfigDscr, &cfg);
		cpx.list(getOutStream());
	}
		break;
	case 't': {
		Cpx cpx;

		cpx.init(ConfigDscr, &cfg);
		cpx.showDef(getOutStream());
	}
		break;

	case 'D':

		printf("Load default\n");
		defaultCfg();
		break;
	case '1':
		strcpy(cfg.WifiSSID, "KANIA-A");
		strcpy(cfg.WifiPassword, "mikemia7");
		cfg.WifiAuthMode = 3;  //WIFI_AUTH_WPA2_PSK
		cfg.WifiAuthMode = 1;  //WIFI_AUTH_WEP
		write();
		break;
	case '2':
		strcpy(cfg.WifiSSID, "GK-ZenFone6");
		strcpy(cfg.WifiPassword, "mikemia7");
		cfg.WifiAuthMode = 3;  //WIFI_AUTH_WPA2_PSK
		write();
		break;

	case 27:
		return true;
	default:
		printf("____Config menu____\n"
				"s - show cfg\n"
				"h - show cfg by CPX\n"
				"t - pokaz definicje\n"
				"D - load defaults\n"
				"1 - set AP: KANIA-A\n"
				"2 - set AP: GK-Zenfone6\n");
	}
	return false;
}
