/*
 * SensorProcessObj.h
 *
 *  Created on: 8 maj 2021
 *      Author: Grzegorz
 */

#ifndef MAIN_SENSORPROCESSOBJ_H_
#define MAIN_SENSORPROCESSOBJ_H_

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

} SendRec;

class SensorProcessObj {

	enum {
		DATA_REQ_TM = 10000, // 10[s]
		SEND_DT_TM = 100, //100[ms]
	};
	static SendRec sendRec;
	static void sendData();
	static void tickSendData();
	static void execKalibr(SvrTargetStream *trg, uint8_t kalibNr, float valFiz);


public:
	static bool onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len);
	static void init();
	static void tick();
	static bool isSendingMeas();

};

#endif /* MAIN_SENSORPROCESSOBJ_H_ */
