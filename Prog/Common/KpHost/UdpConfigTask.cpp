/*
 * UdpConfigTask.cpp
 *
 *  Created on: 18 lut 2021
 *      Author: Grzegorz
 */

#include <string.h>

#include <UdpConfigTask.h>
#include "cmsis_os.h"
#include "lwip/udp.h"

#include "uMain.h"

#include "CfgTcpInterf.h"

UdpConfigTask *UdpConfigTask::me;

UdpConfigTask::UdpConfigTask() :
		TaskClass("UdpConfigTask", osPriorityNormal, 512) {
	me = this;
}

void UdpConfigTask::setRecTxt(const void *buf, int len, const ip_addr_t *addr, u16_t port) {
	int n = sizeof(udpRecData.buf) - 1;
	n = (len < n) ? len : n;
	memcpy(udpRecData.buf, buf, n);
	udpRecData.buf[n] = 0;
	udpRecData.len = len;
	udpRecData.addr = *addr;
	udpRecData.port = port;
	udpRecData.flag = true;
	osSignalSet(getThreadId(), SIGNAL_CONFIG_RECV);
}

extern "C" void udpConfig_recv_fn(void *arg, struct udp_pcb *pcb, struct pbuf *p, const ip_addr_t *addr, u16_t port) {
	if (UdpConfigTask::me != NULL) {
		UdpConfigTask::me->setRecTxt(p->payload, p->len, addr, port);
	}
	pbuf_free(p);
}

void UdpConfigTask::ThreadFunc() {
	OutStream *strm = getOutStream();

	strm->oMsgX(colGREEN,"UdpConfigTask-wait");
	xEventGroupWaitBits(sysEvents, EVENT_NETIF_OK, false, false, portMAX_DELAY);
	strm->oMsgX(colGREEN,"UdpConfigTask-run");

	mUdpPcb = udp_new_ip_type(IPADDR_TYPE_ANY);
	ip_addr_t addr2;
	addr2.addr = IPADDR_ANY;

	err_t ret = udp_bind(mUdpPcb, &addr2, CONFIG_PORT);
	if (ret != ERR_OK) {
		udp_remove(mUdpPcb);
		return;
	}

	udp_recv(mUdpPcb, udpConfig_recv_fn, NULL);

	udpRecData.flag = false;
	while (1) {
		imAlive();
		osEvent ev;
		ev = osSignalWaitClrOnEntry(SIGNAL_CONFIG_RECV, 200);

		if (udpRecData.flag) {
			udpRecData.flag = false;
			doUdpConfig();
		}
	}

}




void UdpConfigTask::doUdpConfig() {
	OutStream *strm = getOutStream();
	char txt[20];

	ipaddr_ntoa_r(&udpRecData.addr, txt, sizeof(txt));
	strm->oMsgX(colYELLOW,"UdpConfig from: %s,%d", txt,udpRecData.port);
	strm->oMsgX(colYELLOW, udpRecData.buf);



	char *rest = udpRecData.buf;
	char *token;
	token = strtok_r(rest, " ", &rest);  //numer seryjny
	CfgTcpInterf *cfgIfc = getCfgTcpInterf();

	bool nrSerOK = (strcmp(cfgIfc->getDevSN(), token) == 0);
	token = strtok_r(rest, " ", &rest);
	int len = 0;

	switch (token[0]) {
	case '1': {
		//Wyszukiwanie
		char bb1[20];
		char bb2[20];
		char bb3[20];
		NetState netState;
		getNetIfState(&netState);

		ipaddr_ntoa_r(&netState.CurrIP, bb1, sizeof(bb1));
		ipaddr_ntoa_r(&netState.CurrMask, bb2, sizeof(bb2));
		ipaddr_ntoa_r(&netState.CurrGate, bb3, sizeof(bb3));

		//04424 0   192.168.0.171   255.255.255.0     192.168.0.2 R-248
		len = snprintf(mSndBuf, sizeof(mSndBuf), "%s %u %15s %15s %15s %s", cfgIfc->getDevSN(), netState.DhcpOn, bb1, bb2, bb3, cfgIfc->getDevID());
		strm->oMsgX(colYELLOW,"Udp_Hello");
	}
		break;
	case '5': {
		//konfiguracja sieci
		bool q = nrSerOK;
		TcpCfgInterfDef tcpDef;

		token = strtok_r(rest, " ", &rest);
		tcpDef.dhcp= (token[0] == '1');
		token = strtok_r(rest, " ", &rest);
		q &= ipaddr_aton(token, &tcpDef.ip);
		token = strtok_r(rest, " ", &rest);
		q &= ipaddr_aton(token, &tcpDef.mask);
		token = strtok_r(rest, " ", &rest);
		q &= ipaddr_aton(token, &tcpDef.gw);
		if (q) {
			cfgIfc->setTcpDef(&tcpDef);
		}
		strm->oMsgX(colYELLOW,"ReconfigNet=%d", q);
	}
		break;
	case '6':
		//komendy użytkownika
		token = strtok_r(rest, " ", &rest);
		if (stricmp(token, "FIND") == 0) {
			len = snprintf(mSndBuf, sizeof(mSndBuf), "%s 6 INTRO %s %s", cfgIfc->getDevSN(), DEV_NAME, cfgIfc->getDevID());
			strm->oMsgX(colYELLOW,"Udp: Find");
		} else if (stricmp(token, "REBOOT") == 0) {
			if (nrSerOK) {
				reboot(1000);
				len = snprintf(mSndBuf, sizeof(mSndBuf), "%s REBOOTING", cfgIfc->getDevSN());
			}
			strm->oMsgX(colYELLOW,"Udp: Reboot, SnOK=%u", nrSerOK);
		} else if (stricmp(token, "REJ_START") == 0) {
			if (nrSerOK) {
				len = snprintf(mSndBuf, sizeof(mSndBuf), "%s REJ_STARTED", cfgIfc->getDevSN());
			}
			strm->oMsgX(colYELLOW,"Udp: Rej_Start, SnOK=%u", nrSerOK);
		}
		break;
	}

	if (len != 0) {
		struct pbuf *p = pbuf_alloc(PBUF_TRANSPORT, len, PBUF_ROM);
		p->payload = (void*) (int) mSndBuf;
		err_t err = udp_sendto(mUdpPcb, p, &udpRecData.addr, udpRecData.port); // CONFIG_PORT);
		pbuf_free(p);
		strm->oMsgX(colYELLOW,"ReplSt=%d", err);
	}
}

