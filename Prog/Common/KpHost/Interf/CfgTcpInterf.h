/*
 * CfgTcpInterf.h
 *
 *  Created on: 23 mar 2021
 *      Author: Grzegorz
 */

#ifndef KPHOST_CFGTCPINTERF_H_
#define KPHOST_CFGTCPINTERF_H_



typedef struct {
	uint8_t dhcp;
	ip4_addr_t ip;
	ip4_addr_t mask;
	ip4_addr_t gw;
} TcpCfgInterfDef;

class CfgTcpInterf {
public:
	virtual const char *getDevSN()=0;
	virtual const char *getDevID()=0;
	virtual void getTcpDef(TcpCfgInterfDef *def)=0;
	virtual void setTcpDef(const TcpCfgInterfDef *def)=0;


};

extern "C" CfgTcpInterf *getCfgTcpInterf();

#endif /* KPHOST_CFGTCPINTERF_H_ */
