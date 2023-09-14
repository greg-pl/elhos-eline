/*
 * KeyLogDef.c
 *
 *  Created on: Mar 14, 2021
 *      Author: Grzegorz
 */

#include "KeyLogDef.h"
#include "string.h"

extern uint16_t getRandom16(void);
extern uint16_t getPackDate();

//funkcja wykonywana przez pytającego
void KeyLogQueryBuild(TKeyLogQueryIn *in, uint8_t recNr) {
	for (int i = 0; i < 4; i++) {
		in->tabK1[i] = getRandom16();
	}
	for (int i = 0; i < 6; i++) {
		in->tabK2[i] = getRandom16();
	}
	in->RecNrMx = recNr + REC_NR_OUT_IN;
	in->Zero = 0;
	in->time = getPackDate();
}

//funkcja wykonywana przez odpowiadajacego
void KeyLogQueryReply(TKeyLogQueryOut *out, const TKeyLogQueryIn *in, uint8_t recNr, uint8_t onV) {
	out->tabK1[0] = in->tabK2[0] - in->tabK2[3] + 14567;
	out->tabK1[1] = in->tabK2[1] + in->tabK1[2] * 2;
	out->tabK1[2] = in->tabK2[2] ^ in->tabK1[0];
	out->tabK1[3] = in->tabK2[3] + in->tabK2[0];
	out->tabK1[4] = in->tabK2[4] - in->tabK1[2];
	out->tabK1[5] = in->tabK2[5] - in->tabK2[0] +  in->tabK2[4];
	out->tabK1[6] = in->tabK2[5] + (in->tabK1[1] ^ in->tabK1[2]);

	out->tabK2[0] = in->tabK1[0] +20040 +in->tabK1[3];
	out->tabK2[1] = in->tabK1[1] - in->tabK2[3];
	out->tabK2[2] = in->tabK1[2] + in->tabK2[2];
	out->tabK2[3] = in->tabK1[3] + in->tabK2[4] + in->tabK2[5] + in->tabK2[3];

	out->RecNrMx = recNr + REC_NR_OUT_ADD;
	if (onV)
		out->Activ = ACTIV_ON;
	else
		out->Activ = ACTIV_OFF;
}

//funkcja wykonywana przez pytającego
uint8_t KeyLogCheckQueryReply(const TKeyLogQueryOut *out, const TKeyLogQueryIn *in) {
	TKeyLogQueryOut myOut;

	uint8_t recNr = out->RecNrMx - REC_NR_OUT_ADD;
	uint8_t onV = (out->Activ == ACTIV_ON);

	KeyLogQueryReply(&myOut, in, recNr, onV);
	if (memcmp(out, &myOut, sizeof(myOut)) == 0) {
		if (out->Activ == ACTIV_ON)
			return keyACTIV;
		else
			return keyNO_ACTIV;
	} else {
		return keyBAD_RPL;
	}
}

