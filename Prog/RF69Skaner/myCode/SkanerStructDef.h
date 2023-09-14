#ifndef __STRUCTDEF_H__
#define __STRUCTDEF_H__

//#include "GeomTypes.h"

#define MAX_RAW_DATA_LEN 32

typedef struct {
	uint32_t tick;
	uint8_t mick;  //cz�ci milisekundy z rozdzielczo�ci� 10[us]
	uint8_t sender;
	uint8_t RSSI_Hd;
	uint8_t len;   // d�ugo�c danych w polu dane[], dane otrzymane z radia
	int frameNr;
	uint8_t data[MAX_RAW_DATA_LEN];
} RawData; //44



#endif

