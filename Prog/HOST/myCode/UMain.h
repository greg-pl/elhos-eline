/*
 * UMain.h
 *
 *  Created on: Mar 8, 2021
 *      Author: Grzegorz
 */

#ifndef UMAIN_H_
#define UMAIN_H_

#include "cmsis_os.h"

#include "myDef.h"
#include "BaseDev.h"
#include "IOStream.h"

enum {
#include "DevTypes.inn"
};

#define DEV_NAME "eLineHOST"
#define DEV_TYPE devHOST

#ifdef __cplusplus
extern "C" {
#endif

enum {
	SIGNAL_MDB_RXCHAR = 0x01, //
	SIGNAL_KEYLOG_RXPKT = 0x02, //
};

extern void uMainCont();

extern void reboot(int tm);
extern void delayReconfigNet(int time);
extern void setLcdScrNr(int nr);
extern void setLcdTime(int time);
extern uint32_t getPackTime();
extern void showLcdBigMsg(const char *txt);

extern OutStream* getOutStream();
extern uint16_t getRandom16(void);
extern void sendPcMsg(uint8_t devNr, uint8_t code, const void *dt, int dt_sz);
extern void sendPcMsgNow(uint8_t devNr, uint8_t code, const void *dt, int dt_sz);


#ifdef __cplusplus
}
#endif

#ifdef __cplusplus

#include <Config.h>

extern Config *config;
#endif

#endif /* UMAIN_H_ */
