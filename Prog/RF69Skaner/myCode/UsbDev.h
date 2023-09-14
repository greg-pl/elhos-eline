#ifndef __USBDEV_H__
#define __USBDEV_H__

#include "stm32f1xx_hal.h"
#include "myDef.h"
#include "SkanerStructDef.h"
#include "usbd_cdc.h"
#include "usbd_def.h"

//Budowa ramki USB
//STX(1) Dev(1) Fun(1) Data(2*MAX_DT_SIZE) Suma(4) ETX(1) EOL(1) NL(1)
//3 + 2*MAX_DT_SIZE+4+3 = 66 bytes;

enum {
	RECIVE_BUF_SIZE = 512,  //bufor odbioru danych z PC-ta
	RECIVE_FRAME_SIZE = 80, //maksymalna d�ugosc ramki otrzymanej z PC
	SEND_BUF_SIZE = RECIVE_BUF_SIZE,
};

class RxData {
public:
	uint8_t buf[RECIVE_BUF_SIZE];
	uint16_t mHead;
	uint16_t mTail;
	bool mNewData;
	bool push(uint8_t dt);
	bool pop(uint8_t *dt);
	int getFrame(char *buf, int max);

} ;

class UsbDev {
private:
	static RxData rxData;
	// bufory do wysyłania danych
	static uint8_t txBuffer[SEND_BUF_SIZE];
	static char mBuffer[SEND_BUF_SIZE];
	static int translateFrame(uint8_t *binFrame, int binMax, char *txtFR, int len);
public:
	static void init();
	static int getFrame(uint8_t *binFrame, int binMax);
	static void OnReciveData(uint8_t *Buf, uint32_t Len);
	static bool isTransmiterRdy();
	static bool Transmit(RawData *pFrame);
};

#endif
