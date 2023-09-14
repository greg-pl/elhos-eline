/*
 * UdpConfigTask.h
 *
 *  Created on: 18 lut 2021
 *      Author: Grzegorz
 */

#ifndef UDPCONFIGTASK_H_
#define UDPCONFIGTASK_H_

#include <TaskClass.h>
#include "lwip.h"

class UdpConfigTask: public TaskClass {
private:
	enum {
		SIGNAL_CONFIG_RECV = 0x02, //
		CONFIG_PORT = 8001,
	};
	struct udp_pcb *mUdpPcb;
	struct {
		char buf[200];
		int len;
		ip_addr_t addr;
		u16_t port;
		volatile bool flag;
	} udpRecData;
	char mSndBuf[100];
	void doUdpConfig();

protected:
	virtual void ThreadFunc();
public:
	static UdpConfigTask *me;
	UdpConfigTask();
	void setRecTxt(const void *buf, int len, const ip_addr_t *addr, u16_t port);

};

#endif /* UDPCONFIGTASK_H_ */
