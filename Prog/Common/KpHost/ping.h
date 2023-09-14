/*
 * ping.h
 *
 *  Created on: Mar 9, 2021
 *      Author: Grzegorz
 */

#ifndef PING_H_
#define PING_H_

#include "lwip.h"
#include "IOStream.h"

class PingObj {
private:
	static PingObj *me;
	enum {
		PING_DELAY = 1000, //
		PING_TIMEOUT = 1100, //
		PING_DATA_SIZE = 32, //
		PING_ID = 0xAFAF, //
	};

	struct raw_pcb *mPcb;
	u16_t mSeqNum;
	bool mWorking;
	bool mOk;
	u32_t mSendTime;
	u32_t mRecTick;
	ip_addr_t mDstAddr;
	OutStream *mMsgStrem;

	static u8_t funRecive(void *arg, struct raw_pcb *pcb, struct pbuf *p, const ip_addr_t *addr);
	static void funTimeout(void *arg);
	void ping_send(struct raw_pcb *raw, ip_addr_t *addr);
	void prepare_echo(struct icmp_echo_hdr *iecho, u16_t len);

public:
	PingObj(void);
	void init(void);
	void done(void);
	void ping(OutStream *msgStrem, ip4_addr_t *addr, int cnt);

};

#endif /* PING_H_ */
