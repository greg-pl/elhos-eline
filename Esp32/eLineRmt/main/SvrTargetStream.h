/*
 * SvrTargetStream.h
 *
 *  Created on: 16 kwi 2021
 *      Author: Grzegorz
 */

#ifndef KPHOST_INTERF_SVRTARGETSTREAM_H_
#define KPHOST_INTERF_SVRTARGETSTREAM_H_

#include "stdint.h"

class SvrTargetStream {
public:
	virtual void addToSend(uint8_t devNr, uint8_t code, const void *dt, int dt_sz)=0;
	virtual void addToSend2(uint8_t devNr, uint8_t code, const void *dt1, int dt1_sz, const void *dt2, int dt2_sz)=0;

	virtual void sendNow()=0;
	virtual const char *getStrmName()=0;
	virtual int getIdx()=0;

};

#endif /* KPHOST_INTERF_SVRTARGETSTREAM_H_ */
