/*
 * Pilot.h
 *
 *  Created on: Mar 20, 2021
 *      Author: Grzegorz
 */

#ifndef PILOT_H_
#define PILOT_H_

#include "main.h"
#include "IOStream.h"
#include "RFM69.h"

class Pilot {
private:
	enum {
		TIME_TO_SETUP_CH = 10000,
	};
	static int mDebug;
	static uint16_t mLastpKeySendCnt;
	static uint8_t mCommandNr;
	static uint32_t mSetupChannelTick;
	static bool mRecivedFlag;
	static uint32_t mRecivedTick;

	static void buildKeyText(char *txt, int max, uint16_t key);
	static void execRadioRec(RadioRecord *radioRec);
	static void initRFM();
	static void sendQuery(uint8_t cmd);
	static void setLedRadio();

public:
	static void sendQueryGetInfo();
	static void sendQuerySetupChn();
	static void sendQueryClrCnt(uint32_t time);
	static void sendQueryGoSleep();

	static void Init();
	static void tick();
	static void execCmd(uint8_t cmd, uint32_t tm);

	static void shell(OutStream *strm, const char *cmd);
};

#endif /* PILOT_H_ */
