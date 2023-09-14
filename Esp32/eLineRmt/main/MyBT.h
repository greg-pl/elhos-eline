/*
 * MyBT.h
 *
 *  Created on: 6 kwi 2021
 *      Author: Grzegorz
 */

#ifndef MYBT_H_
#define MYBT_H_

#include "esp_bt.h"
#include "esp_bt_main.h"
#include "esp_gap_bt_api.h"
#include "esp_bt_device.h"
#include "esp_spp_api.h"

typedef enum {
	iniBtOK, //
	iniControlerInit, //
	iniControlerEnable, //
	iniBlueroidInit, //
	iniBlueroidEnable, //
	iniRegGapCallback, //
	iniRegSppCallback, //
	iniSppInit, //

} InitPhase;

class MyBT {
private:
	static InitPhase mInitPhase;
	static bool mConnected;
	static bool mSendMeas;
	static uint32_t mHandle;
	static char inpBuf[300];
	static char outBuf[300];

	static bool mSending;
	static int mSendingTick;
	static int mDebug;


	static void esp_bt_gap_cb(esp_bt_gap_cb_event_t event, esp_bt_gap_cb_param_t *param);
	static void esp_spp_cb(esp_spp_cb_event_t event, esp_spp_cb_param_t *param);

	static void onDataRecived(uint8_t *,int len);
	static void writeBT(const char *dt, int len);
	static void writeStrBT(const char *dt);

public:
	static int mTmp1;
	static void init();
	static bool menu(char ch);
	static bool isConnected() {
		return mConnected;
	}
};

#endif /* MYBT_H_ */
