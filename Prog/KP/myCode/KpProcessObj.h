/*
 * KpProcessObj.h
 *
 *  Created on: 24 kwi 2021
 *      Author: Grzegorz
 */

#ifndef KPPROCESSOBJ_H_
#define KPPROCESSOBJ_H_

#include "stddef.h"
#include "SvrTargetStream.h"
#include "TcpSvrTask.h"


typedef struct {
	bool activ;
	uint32_t lastSendTick;
	int sendFastCnt;
	struct {
		uint32_t lastReqTick;
		SvrTargetStream *trg;
	} svr[TcpSvrTask::CMM_CNT];

} SendTest;

class KpProcessObj {
private:
	enum {
		TEST_REQ_TM = 10000, //
		TEST_SEND_TM = 250, //
	};
	static SendTest sendTest;
	static void sendTestData();
	static void tickTestData();

public:
	static bool onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len);
	static void init();
	static void tick();

};

#endif /* KPPROCESSOBJ_H_ */
