/*
 * HostProcessObj.h
 *
 *  Created on: 18 kwi 2021
 *      Author: Grzegorz
 */

#ifndef HOSTPROCESSOBJ_H_
#define HOSTPROCESSOBJ_H_

#include "stdint.h"
#include "SvrTargetStream.h"

typedef struct {
	SvrTargetStream *trg;
	uint8_t code;
	uint32_t startTick;
} DelayedItem;

class HostProcessObj {
private:
	enum {
		DELAYED_CNT = 16,
	};
	static DelayedItem delayedTab[DELAYED_CNT];
	static void addDelayedTask(SvrTargetStream *trg, uint8_t code);

public:
	static bool onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len);

	static void init();
	static void tick();
};

#endif /* HOSTPROCESSOBJ_H_ */
