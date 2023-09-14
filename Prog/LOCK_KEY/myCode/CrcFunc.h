#ifndef __CRCFUNC_MODULE__
#define __CRCFUNC_MODULE__

#include "stdint.h"

extern void CrcSet(uint8_t *p, int cnt);
extern uint16_t CrcBild(const uint8_t *p, int cnt);
extern uint16_t CrcProceed(uint16_t Crc, uint8_t inp);
extern uint8_t CrcCheck(const uint8_t *p, int cnt);


#endif
