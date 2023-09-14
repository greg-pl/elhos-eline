/*
 * UdpScanRec.h
 *
 *  Created on: 7 kwi 2021
 *      Author: Grzegorz
 */

#ifndef MAIN_UDPSCANREC_H_
#define MAIN_UDPSCANREC_H_

#include "TaskClass.h"

#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"

class UdpScanTask: public TaskClass {
private:
	void replyUdp(int sock, struct sockaddr_in *src_addr,const char *buf, int len);
protected:
	virtual void ThreadFunc();
public:
	UdpScanTask();
};

#endif /* MAIN_UDPSCANREC_H_ */
