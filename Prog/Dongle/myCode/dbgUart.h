#ifndef __DBG_UART__
#define __DBG_UART__

#include "main.h"

typedef struct {
	uint16_t Tx;
	uint16_t Rx;
	uint16_t RxLost;
	uint16_t Irq;
} DbgCnt;

#define DBG_RX_BUF_SIZE 0x10
#define DBG_TX_BUF_SIZE 0x200

typedef struct {
	char buf[DBG_RX_BUF_SIZE];
	uint32_t recTick;
	uint16_t head;
	uint16_t tail;
} DbgRxData;

typedef struct {
	char buf[DBG_TX_BUF_SIZE];
	uint16_t head;
	uint16_t tail;
	bool sending;
	bool complete;
} DbgTxData;

class DbgUart {
private:
	static DbgCnt cntRec;
	static DbgRxData rxData;
	static DbgTxData txData;

	static void IrqRXChar(uint8_t a);
	static void Senduint8_tHd(uint8_t a);
	static uint8_t PopTxData();
	static void IrqTXChar();
	static void StartSend(void);

public:
	static void IRQ(void);
	static void Init(uint32_t baudRate);
	static void WriteClear();
	static void ReadClear();
	static bool Write(const char *buf, int len);
	static bool WriteStr(const char *buf);
	static bool GetRxChar(char *ch);
	static bool GetKey(char *key);

};

#endif
