/*
 * DevCommonCmd.h
 *
 *  Created on: 16 kwi 2021
 *      Author: Grzegorz
 */

#ifndef KPHOST_DEVCOMMONCMD_H_
#define KPHOST_DEVCOMMONCMD_H_

#include "stdint.h"
#include <SvrTargetStream.h>
#include <main.h>

class DevCommonCmd {
private:
	enum {
		UFLASH_START_SEC = FLASH_SECTOR_8,
		UFLASH_SEC_CNT = 3,
		FLASH_PROG = 0x08000000,
		UFLASH_BASE_ADR = 0x08080000,
		UFLASH_SIZE = 0x060000, //384kB
		MAX_BUF_SIZE =1024,

	};
	static uint8_t AuthBuf[0x80];
	static void sendDevInfo(SvrTargetStream *trg);
	static void sendAuthorBuf(SvrTargetStream *trg);

	static void clearUserflash(SvrTargetStream *trg);
	static void readFlashUni(SvrTargetStream *trg, uint8_t *data, int len, uint32_t baseAdr);
	static void readBaseFlash(SvrTargetStream *trg,uint8_t *data, int len);
	static void readUserflash(SvrTargetStream *trg,uint8_t *data, int len);
	static void wrtieUserflash(SvrTargetStream *trg,uint8_t *data, int len);
	static void execUpdate(SvrTargetStream *trg,uint8_t *data, int len);
	static void checkUserFlashClear(SvrTargetStream *trg);

public:
	static bool onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len);
	static void SendKeepAlive(SvrTargetStream *trg);
};

#endif /* KPHOST_DEVCOMMONCMD_H_ */
