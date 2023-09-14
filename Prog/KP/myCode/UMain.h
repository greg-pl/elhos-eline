/*
 * UMain.h
 *
 *  Created on: Mar 22, 2021
 *      Author: Grzegorz
 */

#ifndef UMAIN_H_
#define UMAIN_H_

#include "_ansi.h"

#include "cmsis_os.h"
#include "myDef.h"
#include "IOStream.h"
#include "BaseDev.h"

enum {
#include "DevTypes.inn"
};

#define DEV_NAME "eLineKP"
#define DEV_TYPE devKP


_BEGIN_STD_C

#ifdef __cplusplus
extern "C" {
#endif



#ifdef __cplusplus
}
#endif



extern OutStream *getOutStream();
//extern void uMainCont();
extern void reboot(int tm);
extern void delayReconfigNet(int time);
extern void SpiStartMeasure();
extern void showLcdBigMsg(const char *txt);

extern uint16_t getRandom16(void);
extern void sendPcMsg(uint8_t devNr, uint8_t code, const void *dt, int dt_sz);
extern void sendPcMsgNow(uint8_t devNr, uint8_t code, const void *dt, int dt_sz);




#ifdef __cplusplus

#include <Config.h>
extern Config *config;

_END_STD_C

#endif



#endif /* UMAIN_H_ */
