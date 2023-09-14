/*
 * UMain.cpp
 *
 *  Created on: Mar 19, 2021
 *      Author: Grzegorz
 */

#include "string.h"
#include "stdio.h"

#include "myDef.h"
#include "main.h"
#include "SkanerStructDef.h"
#include "RFM69.h"
#include "UsbDev.h"

#include <UMain.h>

#define SEC_NOINIT  __attribute__ ((section (".noinit")))

SEC_NOINIT NIR nir;
bool mGlobError = 0;
uint8_t mDebug = 0;
VerInfo mVer;

//-------------------------------------------------------------------------------------------------------------------------
// LABEL
//-------------------------------------------------------------------------------------------------------------------------
#define SEC_LABEL   __attribute__ ((section (".label")))

SEC_LABEL char DevLabel[] = //
		"ZZZZ            "
				"                "
				"                "
				"                "
				"****************"
				"*              *"
				"*  RFM69Skaner *"
				"*              *"
				"****************";

//-------------------------------------------------------------------------------------
// loadSoftVer
//-------------------------------------------------------------------------------------

static uint16_t getDec(const char *p) {
	char ch = *p;
	if (ch >= '0' || ch <= '9')
		return ch - '0';
	else
		return 0;
}

static uint16_t getInt3(const char *p) {
	uint16_t w = getDec(p++) * 100;
	w += getDec(p++) * 10;
	w += getDec(p);
	return w;
}

static uint8_t getInt2(const char *p) {
	uint8_t w = getDec(p++) * 10;
	w += getDec(p);
	return w;
}

//0123456789012345
//Date : 20.06.11
//Time : 00:10:51
//Ver.001 Rev.203

const char Tx1[] = "Date :";
const char Tx2[] = "Time :";
const char Tx3[] = "Ver.";
const char Tx4[] = "Rev.";

uint8_t _strcmp(const char *s1, const char *s2) {
	while (*s1 && *s2) {
		if (*s1 != *s2)
			return 0;
		s1++;
		s2++;
	}
	return 1;
}

uint8_t loadSoftVer(VerInfo *ver, const char *mem) {
	if (_strcmp(Tx1, &mem[0]) && _strcmp(Tx2, &mem[16]) && _strcmp(Tx3, &mem[32]) && _strcmp(Tx4, &mem[40])) {
		ver->ver = getInt3(&mem[36]);
		ver->rev = getInt3(&mem[44]);
		ver->time.rk = getInt2(&mem[7]);
		ver->time.ms = getInt2(&mem[10]);
		ver->time.dz = getInt2(&mem[13]);
		ver->time.gd = getInt2(&mem[16 + 7]);
		ver->time.mn = getInt2(&mem[16 + 10]);
		ver->time.sc = getInt2(&mem[16 + 13]);
		ver->time.se = 0;
		ver->time.timeSource = 0;
		return 1;
	} else {
		memset(ver, 0, sizeof(VerInfo));
		return 0;
	}
}

//-------------------------------------------------------------------------------
//UART
//-------------------------------------------------------------------------------

void setLed1(uint8_t q) {
	if (q)
		HAL_GPIO_WritePin(LED1_GPIO_Port, LED1_Pin, GPIO_PIN_RESET);
	else
		HAL_GPIO_WritePin(LED1_GPIO_Port, LED1_Pin, GPIO_PIN_SET);
}

void setLed2(uint8_t q) {
	if (q)
		HAL_GPIO_WritePin(LED2_GPIO_Port, LED2_Pin, GPIO_PIN_RESET);
	else
		HAL_GPIO_WritePin(LED2_GPIO_Port, LED2_Pin, GPIO_PIN_SET);
}

void setUsbConnect(uint8_t q) {
	if (q)
		HAL_GPIO_WritePin(USB_ON_GPIO_Port, USB_ON_Pin, GPIO_PIN_RESET);
	else
		HAL_GPIO_WritePin(USB_ON_GPIO_Port, USB_ON_Pin, GPIO_PIN_SET);
}

//-------------------------------------------------------------------------------
//DBG UART
//-------------------------------------------------------------------------------
extern UART_HandleTypeDef huart1;

enum {
	UART_INBUF_SIZE = 0x10, UART_OUTBUF_SIZE = 0x1000,
};

typedef struct {
	int head;
	int tail;
	char buf[UART_INBUF_SIZE];
} UartRxRec;

typedef struct {
	volatile bool sending;
	int head;
	int tailSending;
	int tail;
	char buf[UART_OUTBUF_SIZE];
} UartTxRec;

class DbgUart {
private:
	static UartRxRec rxRec;
	static UartTxRec txRec;

	static void sendNextPart();
	static void TxCpltCallback(struct __UART_HandleTypeDef *huart);
	static void RxCpltCallback(struct __UART_HandleTypeDef *huart);
	static bool putChHd(char ch);

public:
	static void Init();
	static bool getCh(char *ch);
	static bool putCh(char ch);
	static void write(const void *dt, int size);
};

UartRxRec DbgUart::rxRec;
UartTxRec DbgUart::txRec;

void DbgUart::Init() {
	memset(&rxRec, 0, sizeof(rxRec));
	memset(&txRec, 0, sizeof(txRec));

	setvbuf(stdout, NULL, _IONBF, 0);

	huart1.Instance = USART1;
	huart1.Init.BaudRate = 115200;
	huart1.Init.WordLength = UART_WORDLENGTH_8B;
	huart1.Init.StopBits = UART_STOPBITS_1;
	huart1.Init.Parity = UART_PARITY_NONE;
	huart1.Init.Mode = UART_MODE_TX_RX;
	huart1.Init.HwFlowCtl = UART_HWCONTROL_NONE;
	huart1.Init.OverSampling = UART_OVERSAMPLING_16;

	HAL_StatusTypeDef st = HAL_UART_Init(&huart1);
	if (st == HAL_OK) {
		HAL_UART_RegisterCallback(&huart1, HAL_UART_TX_COMPLETE_CB_ID, TxCpltCallback);
		HAL_UART_RegisterCallback(&huart1, HAL_UART_RX_COMPLETE_CB_ID, RxCpltCallback);
		HAL_UART_Receive_IT(&huart1, (uint8_t*) &rxRec.buf[rxRec.head], 1);
	}
}

void DbgUart::RxCpltCallback(struct __UART_HandleTypeDef *huart) {
	if (++rxRec.head == sizeof(rxRec.buf)) {
		rxRec.head = 0;
	}
	HAL_UART_Receive_IT(&huart1, (uint8_t*) &rxRec.buf[rxRec.head], 1);
}

bool DbgUart::getCh(char *ch) {
	if (rxRec.tail != rxRec.head) {
		*ch = rxRec.buf[rxRec.tail];
		if (++rxRec.tail == sizeof(rxRec.buf)) {
			rxRec.tail = 0;
		}
		return true;
	} else {
		return false;
	}
}

void DbgUart::TxCpltCallback(struct __UART_HandleTypeDef *huart) {
	txRec.sending = false;
	txRec.tail = txRec.tailSending;

	if (txRec.head != txRec.tail) {
		sendNextPart();
	}
}

void DbgUart::sendNextPart() {
	if (!txRec.sending) {

		int sz;
		if (txRec.head > txRec.tail) {

			//bufor nie zostal przewinięty
			txRec.tailSending = txRec.head;
			sz = txRec.head - txRec.tail;
		} else {
			//bufor do końca
			sz = sizeof(txRec.buf) - txRec.tail;
			txRec.tailSending = 0;
		}
		HAL_StatusTypeDef st = HAL_UART_Transmit_IT(&huart1, (uint8_t*) &txRec.buf[txRec.tail], sz);
		if (st == HAL_OK) {
			txRec.sending = true;
		}
	}
}

bool DbgUart::putChHd(char ch) {
	int h = txRec.head;
	if (++h == sizeof(txRec.buf))
		h = 0;
	if (h != txRec.tail) {
		txRec.buf[txRec.head] = ch;
		txRec.head = h;
		return true;
	} else
		return false;

}

bool DbgUart::putCh(char ch) {
	putChHd(ch);
	sendNextPart();
}

void DbgUart::write(const void *dt, int size) {
	char *pch = (char*) dt;
	for (int i = 0; i < size; i++)
		putChHd(*pch++);
	sendNextPart();
}

extern "C" int __io_putchar(int ch) {
	DbgUart::putCh(ch);
	return 1;
}

extern "C" int _write(int file, char *ptr, int len) {
	DbgUart::write(ptr, len);
	return len;
}

//-------------------------------------------------------------------------------
//Shell
//-------------------------------------------------------------------------------

void tickLed1() {
	static uint8_t mem = 0;

	uint32_t tt = HAL_GetTick();

	uint32_t t1 = tt % 1000;
	bool q = (t1 < 100);
	if (mem != q) {
		mem = q;
		if (mem) {
			setLed1(1);
		} else {
			setLed1(0);
		}
	}
}

int ledBottomMode;

void setBottomLed(int ledNr, bool state) {
	state = !state;
	switch (ledNr) {
	case 0:
		HAL_GPIO_WritePin(L_PC_GPIO_Port, L_PC_Pin, (GPIO_PinState) state);
		break;
	case 1:
		HAL_GPIO_WritePin(L_CPU1_GPIO_Port, L_CPU1_Pin, (GPIO_PinState) state);
		break;
	case 2:
		HAL_GPIO_WritePin(L_CPU2_GPIO_Port, L_CPU2_Pin, (GPIO_PinState) state);
		break;
	case 3:
		HAL_GPIO_WritePin(L_CPU3_GPIO_Port, L_CPU3_Pin, (GPIO_PinState) state);
		break;
	case 4:
		HAL_GPIO_WritePin(L_CPU4_GPIO_Port, L_CPU4_Pin, (GPIO_PinState) state);
		break;
	}
}

void tickledSpod() {
	static int tt;
	static uint8_t ph;
	const int phTime[] = { 100, 100, 500, 500, 500, 500 };

	int t1 = HAL_GetTick();
	if (t1 - tt > phTime[ledBottomMode]) {
		tt = t1;

		int mxPh = 2;
		switch (ledBottomMode) {
		case 0:
			//wędrujące led
			for (int i = 0; i < 5; i++) {
				setBottomLed(i, i == ph);
			}
			mxPh = 5;
			break;
		case 1:
			//wędrujące led - odwortny kierunek
			for (int i = 0; i < 5; i++) {
				setBottomLed(4 - i, i == ph);
			}
			mxPh = 5;
			break;
		case 2:
			setBottomLed(0, ph == 0);
			setBottomLed(1, ph == 1);
			setBottomLed(2, ph == 2);
			setBottomLed(3, ph == 1);
			setBottomLed(4, ph == 0);
			mxPh = 3;
			break;
		case 3:
			setBottomLed(0, ph == 0);
			setBottomLed(1, 0);
			setBottomLed(2, ph == 1);
			setBottomLed(3, 0);
			setBottomLed(4, ph == 0);
			mxPh = 2;
			break;
		}

		if (++ph >= mxPh)
			ph = 0;

	}
}

uint8_t HAL_GetMick() {
	int m = SysTick->VAL;
	int c = SysTick->LOAD;
	return 100 * (c - m) / c;
}

void getPrecTime(uint32_t *tick, uint8_t *mick) {
	while (1) {
		uint32_t t1 = HAL_GetTick();
		*mick = HAL_GetMick();
		uint32_t t2 = HAL_GetTick();
		if (t1 == t2) {
			*tick = t1;
			break;
		}
	}

}

//---------------------------------------------------------------------------
// DataFifo
//---------------------------------------------------------------------------

class DataFifo {
private:
	enum {
		FIFO_SIZE = 64,
	};
	int Head;
	int Tail;
	RawData Mem[FIFO_SIZE];
public:
	void init();
	bool push(const RawData *dt);
	bool pop(RawData *dt);
};

void DataFifo::init() {
	Head = 0;
	Tail = 0;
}

bool DataFifo::push(const RawData *dt) {
	int h = Head;
	if (++h == FIFO_SIZE)
		h = 0;
	if (h != Tail) {
		Mem[Head] = *dt;
		Head = h;
		return true;
	} else
		return false;
}

bool DataFifo::pop(RawData *dt) {
	if (Tail != Head) {
		*dt = Mem[Tail];
		if (++Tail == FIFO_SIZE)
			Tail = 0;
		return true;
	} else
		return false;
}

DataFifo dataFifo;
//---------------------------------------------------------------------------
// Radio
//---------------------------------------------------------------------------
int recFrameCnt;

RFMCfg DefaultCfg = { 0, //int ChannelFreq;
		bd300000, //uint8_t BaudRate;
		31, //uint8_t TxPower;
		paMode1, //PAMode
		};

void InitRawData(RawData *D) {
	memset(D, 0, sizeof(RawData));
	getPrecTime(&D->tick, &D->mick);
	D->frameNr = recFrameCnt++;

}

void OnDataRecivedProc(uint8_t senderNr, uint8_t len, uint8_t RSSI_Hd, uint8_t *dt) {
	RawData D;

	InitRawData(&D);

	D.len = len;
	if (len > 32) {
		len = 32;
	}
	memcpy(D.data, dt, len);

	D.RSSI_Hd = RSSI_Hd;
	D.sender = senderNr;
	dataFifo.push(&D);
	if (mDebug > 3)
		printf("\r\nFrRAD: len=%u", len);
}

extern "C" void RfmInit() {
	//RFM69::setOnReciveEvent(&OnDataRecivedProc);
	RFM69::Init(&DefaultCfg);
}

enum {
	RADIO_FIFO_DEEP = 40
};

typedef struct {
	uint8_t buf[32];
} RADIO_REC;

RADIO_REC RadioFifoMem[RADIO_FIFO_DEEP];
typedef struct {
	uint8_t head;
	uint8_t tail;
} Radio_Fifo;

Radio_Fifo radFifo;

extern "C" bool sendRadioProc(const RADIO_REC *rRec) {
	uint8_t nextHead = radFifo.head;
	if (++nextHead == RADIO_FIFO_DEEP)
		nextHead = 0;
	if (nextHead != radFifo.tail) {
		RadioFifoMem[radFifo.head] = *rRec;
		radFifo.head = nextHead;
		return true;
	} else {
		printf("RadioFifoMem is full\r\n");
		return false;
	}
}

extern "C" int radioSendPacket(const RADIO_REC *rRec, bool canRepeat) {
	//setLed2(1);
	int st = RFM69::sendPacket(0, (const uint8_t*) rRec, (uint8_t) sizeof(RADIO_REC));
	//setLed2(0);
	return st;
}

//---------------------------------------------------------------------------
// Shell
//---------------------------------------------------------------------------
enum ShelType {
	shMAIN, shRFM
};

ShelType shelType = shMAIN;

RADIO_REC RadioRec;

/*
 extern "C" uint32_t get_data_size();
 extern "C" uint32_t get_heep_used();
 extern "C" uint32_t get_heep_free();
 */
void ShellMain(char key) {

	switch (key) {
	case 'g':
		if (++mDebug == 5)
			mDebug = 0;
		printf("Debug=%u\r\n", mDebug);
		break;
	case 'D':
		shelType = shRFM;
		break;

	case 'm':
		/*
		 uDbg->printf("DataSize=%u\r\n", get_data_size());
		 uDbg->printf("HeapUsed=%u\r\n", get_heep_used());
		 uDbg->printf("HeepFree=%u\r\n", get_heep_free());

		 */
		break;
	case 'U':
		printf("Usb disconnect\r\n");
		setUsbConnect(0);
		break;
	case 'u':
		printf("Usb connect\r\n");
		setUsbConnect(1);
		break;
	case '1': {
		printf("Push 6 packets\r\n");
		RawData dt;

		InitRawData(&dt);
		dt.data[0] = 1;
		dataFifo.push(&dt);
		HAL_Delay(5);

		InitRawData(&dt);
		dt.data[0] = 2;
		dataFifo.push(&dt);
		HAL_Delay(5);

		InitRawData(&dt);
		dt.data[0] = 3;
		dataFifo.push(&dt);
		for (volatile int i = 0; i < 2000; i++) {

		}

		InitRawData(&dt);
		dt.data[0] = 4;
		dataFifo.push(&dt);

		InitRawData(&dt);
		dt.data[0] = 5;
		dataFifo.push(&dt);
		for (volatile int i = 0; i < 200; i++) {

		}

		InitRawData(&dt);
		dt.data[0] = 6;
		dataFifo.push(&dt);

		printf("Send data 6; delay 5,2\r\n");
	}
		break;
	case '2': {
		printf("Push 2 packets - 20 bytes\r\n");
		RawData dt;

		InitRawData(&dt);
		dt.len = 20;
		dataFifo.push(&dt);
		InitRawData(&dt);
		dt.len = 20;
		dataFifo.push(&dt);

	}
		break;

	default:
		printf("\r\nSz-Skaner\r\nHDW:%u, %u.%03u \r\n------------------\r\n", 1, mVer.ver, mVer.rev);

		printf("D > RFM Menu\r\n");
		printf("g - debugLevel\r\n");
		printf("m - pamiec info\r\n");
		printf("u/U - connect/disconnect USB\r\n");
		printf("1 - send test data 6x6\r\n");
		printf("2 - send test data 2x20\r\n");

		break;

	}
}
void Shell(char key) {
	if (key == 0xff) {
		return;
	}
	printf("%c\r\n", key);
	switch (shelType) {
	case shRFM:
		if (RFM69::shell(key))
			shelType = shMAIN;
		break;
	default:
		ShellMain(key);
		break;
	}
	printf(">");
}

#define PC_MSG_LEN 40
enum {
	nuRADIO_CFG = 1, //
	nuRADIO_DATA, //
	nuRED_PULSE, //
};

typedef struct {
	union {
		struct {
			uint8_t ledBottomMode;
		};
		uint8_t buf[8];
	};
	RFMCfg Radio;
} PcCfg;

void reciveFromPC() {
	uint8_t pcBuf[PC_MSG_LEN];

	int len = UsbDev::getFrame(pcBuf, sizeof(pcBuf));
	if (len > 1) {
		switch (pcBuf[0]) {
		case nuRADIO_CFG: {
			printf("Konfiguracja, n=%d\r\n", len);

			PcCfg pcCfg;
			memcpy(&pcCfg, &pcBuf[1], sizeof(pcCfg));

			ledBottomMode = pcCfg.ledBottomMode;
			RFM69::Init(&pcCfg.Radio);
			setLed2(1);
			HAL_Delay(50);
			setLed2(0);
		}
			break;
		case nuRADIO_DATA: {
			uint8_t slotNr = pcBuf[1];
			len -= 2;
			printf("Dane do wysłania, n=%d\r\n", len);
			RFM69::sendPacket(slotNr, &pcBuf[2], len);
		}
			break;
		case nuRED_PULSE:
			printf("Led pulse\r\n");
			setLed2(1);
			HAL_Delay(100);
			setLed2(0);
			break;
		}

		// wysłanie potwierdzenia do PC-ta
		RawData D;
		InitRawData(&D);
		D.len = 1;
		D.data[0] = pcBuf[0];
		D.RSSI_Hd = 0;
		D.sender = 15;
		dataFifo.push(&D);
	}
}

void ReadRadioData() {
	RawData D;

	InitRawData(&D);

	int len = RFM69::recVar.DataLen;
	D.len = len;
	if (len > 32) {
		len = 32;
	}
	memcpy(D.data, RFM69::recVar.DataBuf, len);

	D.RSSI_Hd = RFM69::recVar.RSSI;
	D.sender = RFM69::recVar.SenderID;
	dataFifo.push(&D);
	if (mDebug > 3)
		printf("\r\nFrRAD: len=%u", len);

}

extern "C" void uMain(void) {

	DbgUart::Init();

	loadSoftVer(&mVer, &DevLabel[0x10]);

	SPI_1::Init();
	//MX_SPI2_Init();
	UsbDev::init();
	dataFifo.init();

	bool startOK = true;

	for (int i = 0; i < 6; i++) {
		HAL_Delay(50);
		setBottomLed(i, true);
		setLed2(1);
		HAL_Delay(50);
		setLed2(0);
		setBottomLed(i, false);
	}

	printf("\r\n\n\nRFM69-Skaner\r\n-----------------\r\n>");
	printf("ver:%u.%03u\r\n", mVer.ver, mVer.rev);
	printf("Options:0x%02X 0x%02X\r\n", //
			(int) HAL_FLASHEx_OBGetUserData(OB_DATA_ADDRESS_DATA0), //
			(int) HAL_FLASHEx_OBGetUserData(OB_DATA_ADDRESS_DATA1));

	RfmInit();
	if (startOK)
		setLed2(0);
	else
		setLed2(1);

	setUsbConnect(1);

	uint32_t led2Tm = 0;
	while (1) {
		tickLed1();
		tickledSpod();

		if (led2Tm != 0) {
			if (HAL_GetTick() - led2Tm > 50) {
				led2Tm = 0;
				setLed2(0);
			}
		}

		char key;
		if (DbgUart::getCh(&key)) {
			Shell(key);
		}
		RFM69::tick();
		if (RFM69::isNewFrame()) {
			setLed2(1);
			led2Tm = HAL_GetTick();
			ReadRadioData();
		}

		if (UsbDev::isTransmiterRdy()) {
			RawData dt;
			if (dataFifo.pop(&dt)) {
				if (mDebug > 3)
					printf("\r\nToUSB: nr=%u L=%u", dt.frameNr, dt.len);
				UsbDev::Transmit(&dt);
			}
		}
		reciveFromPC();

	}

}

