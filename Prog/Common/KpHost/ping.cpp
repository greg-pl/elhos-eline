/*
 * ping.cpp
 *
 *  Created on: Mar 9, 2021
 *      Author: Grzegorz
 */

#include <ping.h>

#include "sockets.h"
#include "icmp.h"
#include "raw.h"

PingObj *PingObj::me;

void PingObj::prepare_echo(struct icmp_echo_hdr *iecho, u16_t len) {
	int i;
	int data_len = len - sizeof(struct icmp_echo_hdr);

	ICMPH_TYPE_SET(iecho, ICMP_ECHO);
	ICMPH_CODE_SET(iecho, 0);
	iecho->chksum = 0;
	iecho->id = PING_ID;
	iecho->seqno = htons(++mSeqNum);

	/* fill the additional data buffer with some data */
	for (i = 0; i < data_len; i++) {
		((char*) iecho)[sizeof(struct icmp_echo_hdr) + i] = (char) i;
	}

	//iecho->chksum = inet_chksum(iecho, len);
}

u8_t PingObj::funRecive(void *arg, struct raw_pcb *pcb, struct pbuf *p, const ip_addr_t *addr) {

	if (pbuf_header(p, -PBUF_IP_HLEN) == 0) {
		struct icmp_echo_hdr *iecho = (struct icmp_echo_hdr*) p->payload;

		if (me != NULL) {
			if ((iecho->id == PING_ID) && (iecho->seqno == htons(me->mSeqNum))) {
				/* do some ping result processing */
				me->mWorking = false;
				me->mOk = true;
				me->mRecTick = HAL_GetTick();
			}
			pbuf_free(p);
			return 1; /* eat the packet */
		} else {
			if (iecho->id == PING_ID) {
				pbuf_free(p);
				return 1; /* eat the packet */
			}
		}
	}
	return 0; /* don't eat the packet */
}

void PingObj::funTimeout(void *arg) {
	if (me != NULL) {
		me->mWorking = false;
		me->mOk = false;
		me->mRecTick = HAL_GetTick();
		sys_timeout(PING_DELAY, funTimeout, me->mPcb);
	}

	//struct raw_pcb *pcb = (struct raw_pcb*) arg;
	//ping_send(pcb, &mDstAddr);
	//sys_timeout(PING_DELAY, ping_timeout, pcb);
}

PingObj::PingObj(void) {
	me = this;
}

void PingObj::init(void) {
	mPcb = raw_new(IP_PROTO_ICMP);
	raw_recv(mPcb, funRecive, NULL);
	raw_bind(mPcb, IP_ADDR_ANY);
	sys_timeout(PING_DELAY, funTimeout, mPcb);
}

void PingObj::done(void) {
	raw_remove(mPcb);
}

void PingObj::ping_send(struct raw_pcb *raw, ip_addr_t *addr) {
	struct pbuf *p;
	struct icmp_echo_hdr *iecho;
	size_t ping_size = sizeof(struct icmp_echo_hdr) + PING_DATA_SIZE;

	p = pbuf_alloc(PBUF_IP, (u16_t) ping_size, PBUF_RAM);
	if (!p) {
		return;
	}
	if ((p->len == p->tot_len) && (p->next == NULL)) {
		mDstAddr = *addr;
		iecho = (struct icmp_echo_hdr*) p->payload;

		prepare_echo(iecho, (u16_t) ping_size);

		raw_sendto(raw, p, &mDstAddr);
		mSendTime = HAL_GetTick();
		mWorking = true;
	}
	pbuf_free(p);
}


void PingObj::ping(OutStream *msgStrem, ip4_addr_t *addr, int cnt) {

	mMsgStrem = msgStrem;
	init();
	int k = 0;
	int sumT = 0;
	for (int i = 0; i < cnt; i++) {
		ping_send(mPcb, addr);
		uint32_t tt = HAL_GetTick();
		while (HAL_GetTick() - tt < PING_TIMEOUT) {
			osDelay(1);
			if (!mWorking) {
				if (mOk) {
					k++;
					sumT += (mRecTick - mSendTime);
					mMsgStrem->oMsg("%u.OK",i);
				} else
					mMsgStrem->oMsg("%u.Err",i);
				break;
			}
		}
	}
	mMsgStrem->oMsg("Ping sended %d recived %d, t=%.1f[ms]\r\n", cnt, k, (float) sumT / k);
	done();
}
