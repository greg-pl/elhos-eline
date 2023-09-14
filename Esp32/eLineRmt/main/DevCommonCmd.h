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

class DevCommonCmd {
private:
	static uint8_t AuthBuf[0x80];
	static void sendDevInfo(SvrTargetStream *trg);
	static void sendAuthorBuf(SvrTargetStream *trg);

public:
	static bool onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len);
	static void SendKeepAlive(SvrTargetStream *trg);
};

#endif /* KPHOST_DEVCOMMONCMD_H_ */
