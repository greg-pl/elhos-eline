/*
 * ShellTaskA.cpp
 *
 *  Created on: Mar 23, 2021
 *      Author: Grzegorz
 */

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "stdarg.h"

#include <EscTerminal.h>
#include <UMain.h>
#include "uart.h"
#include "RxTxBuf.h"

#include <ShellTask.h>
#include <BaseDev.h>
#include "BaseShellInterpreter.h"

extern "C" BaseShellInterpreter* getShellInterpreter();



//-----------------------------------------------------------------------------
// ShellConnection
//-----------------------------------------------------------------------------
class UartShellConnection {
protected:
	enum {
		TX_BUF_SIZE = 2048,  //bufor do nadawania
		RX_BUF_SIZE = 64,  //
	};
	osThreadId mThreadId;
	RxTxBuf *txBuf;
	struct {
		char buf[64];
		int head;
		int tail;
	} rxRec;

	virtual bool isConnSending() =0;
	virtual void sendBuf(const void *ptr, int len)=0;
	void startSendNextPart();
public:
	UartShellConnection();
	void setThreadId(osThreadId threadId) {
		mThreadId = threadId;
	}
	virtual HAL_StatusTypeDef Init()=0;
	bool writeData(Portion *portion);
	bool getChar(char *ch);
};


UartShellConnection::UartShellConnection() {
	mThreadId = NULL;
	txBuf = new RxTxBuf(TX_BUF_SIZE);
	memset(&rxRec, 0, sizeof(rxRec));

}
void UartShellConnection::startSendNextPart() {
	const char *ptr;
	int cnt;

	bool q = txBuf->lockLinearRegion(&ptr, &cnt, TX_BUF_SIZE / 2);
	if (q) {
		sendBuf(ptr, cnt);
	}
}

bool UartShellConnection::writeData(Portion *portion) {
	if (portion->len <= 0)
		return true;
	bool q = txBuf->addBuf(portion);
	if (!isConnSending()) {
		startSendNextPart();
	}
	return q;
}

bool UartShellConnection::getChar(char *ch) {
	if (rxRec.head != rxRec.tail) {
		int t = rxRec.tail;
		*ch = rxRec.buf[t];
		if (++t >= (int) sizeof(rxRec.buf))
			t = 0;
		rxRec.tail = t;
		return true;
	}
	return false;
}




//-------------------------------------------------------------------------------------------------------------------------
// UartConnection
//-------------------------------------------------------------------------------------------------------------------------


class UartConnection: public TUart, public UartShellConnection {
	friend class ShellTask;
private:
	char rxChar;
protected:
	//TUart
	virtual void TxCpltCallback();
	virtual void RxCpltCallback();
	virtual void ErrorCallback();
protected:
	//ShellConnection
	virtual bool isConnSending();
	virtual void sendBuf(const void *ptr, int len);
public:
	UartConnection(int PortNr);
	virtual HAL_StatusTypeDef Init();
};


UartConnection::UartConnection(int PortNr) :
		TUart::TUart(PortNr, 7), UartShellConnection::UartShellConnection() {

}

bool UartConnection::isConnSending() {
	return isSending();
}

void UartConnection::sendBuf(const void *ptr, int len) {
	TUart::writeBuf(ptr, len);
}

void UartConnection::TxCpltCallback() {
	TUart::TxCpltCallback();
	txBuf->unlockRegion();

	startSendNextPart();
}

void UartConnection::RxCpltCallback() {
	rxRec.buf[rxRec.head] = rxChar;
	if (++rxRec.head >= (int) sizeof(rxRec.buf))
		rxRec.head = 0;
	if (mThreadId != NULL) {
		osSignalSet(mThreadId, ShellTask::SIGNAL_CHAR);
	}
	HAL_UART_Receive_IT(&mHuart, (uint8_t*) &rxChar, 1);
}

void UartConnection::ErrorCallback() {

}

HAL_StatusTypeDef UartConnection::Init() {
	HAL_StatusTypeDef st = TUart::Init(115200);
	if (st == HAL_OK) {
		HAL_UART_Receive_IT(&mHuart, (uint8_t*) &rxChar, 1);
	}
	return st;
}

//-------------------------------------------------------------------------------------------------------------------------
// USBConnection
//-------------------------------------------------------------------------------------------------------------------------
class USBConnection: public UartShellConnection {
	friend class ShellTask;
protected:
	//ShellConnection
	virtual bool isConnSending();
	virtual void sendBuf(const void *ptr, int len);

public:
	static USBConnection *Me;
	void inpDataFun(uint8_t *Buf, uint32_t Len);
	void transmitCplt();
public:
	USBConnection();
	virtual HAL_StatusTypeDef Init();
};


USBConnection *USBConnection::Me = NULL;
extern "C" uint8_t CDC_Transmit_FS(uint8_t *Buf, uint16_t Len);
extern "C" uint8_t CDC_IsSending(void);

extern "C" void CDC_UserRecivedData(uint8_t *Buf, uint32_t Len) {
	if (USBConnection::Me != NULL) {
		USBConnection::Me->inpDataFun(Buf, Len);
	}
}

extern "C" void CDC_UserTransmitCplt(void) {
	if (USBConnection::Me != NULL) {
		USBConnection::Me->transmitCplt();
	}
}

USBConnection::USBConnection() {
	Me = this;
	rxRec.head = 0;
	rxRec.tail = 0;
}

HAL_StatusTypeDef USBConnection::Init() {
	return HAL_OK;
}

bool USBConnection::isConnSending() {
	return CDC_IsSending();
}

void USBConnection::sendBuf(const void *ptr, int len) {
	CDC_Transmit_FS((uint8_t*) ptr, len);
}

void USBConnection::transmitCplt() {
	startSendNextPart();
}

void USBConnection::inpDataFun(uint8_t *Buf, uint32_t Len) {
	if (Len > 0) {
		for (uint32_t i = 0; i < Len; i++) {
			rxRec.buf[rxRec.head] = Buf[i];
			if (++rxRec.head >= (int) sizeof(rxRec.buf))
				rxRec.head = 0;
		}
		if (mThreadId != NULL) {
			osSignalSet(mThreadId, ShellTask::SIGNAL_CHAR);
		}
	}

}

//-------------------------------------------------------------------------------------------------------------------------
// ShellTask
//-------------------------------------------------------------------------------------------------------------------------

ShellTask::ShellTask(int PortNr) :
		TaskClass::TaskClass("Shell", osPriorityNormal, 1024) {

	mFullTxCnt = 0;

	//myConnection = new USBConnection();
	myConnection = new UartConnection(PortNr);
	myConnection->Init();
	term = new EscTerminal(this);
}

void ShellTask::putOut(const void *mem, int len) {
	flgSendAny = true;

	Portion portion;
	portion.len = len;
	portion.dt = (const char*) mem;

	while (1) {
		bool q = myConnection->writeData(&portion);
		if (q) {
			break;
		} else {
			mFullTxCnt++;
		}
		osDelay(5); // blokowanie tasku wysyłającego
	}
}


void ShellTask::ThreadFunc() {

	myConnection->setThreadId(getThreadId());
	putStr(TERM_CLEAR_SCR);
	oMsgX(colCYAN, "Welcome. start=%d\r\nUżywaj PuTTY jako terminala !!!", nir.startCnt);

	xEventGroupSetBits(sysEvents, EVENT_TERM_RDY);

	// odczeakanie az DefaultTask utworzy resztę urządzeń logicznych

	xEventGroupWaitBits(sysEvents, EVENT_CREATE_DEVICES, false, false, 1000000);
	oMsgX(colCYAN, "Ready");

	while (1) {
		osEvent ev = osSignalWait(SIGNAL_CHAR | SIGNAL_MSG, 1000);
		if (ev.status == osEventSignal) {
			int code = ev.value.v;

			if (code == SIGNAL_CHAR) {
				char key;
				while (myConnection->getChar(&key)) {
					TermAct act = term->inpChar(key);
					switch (act) {
					case actNOTHING:
						break;
					case actLINE:
						flgSendAny = false;
						getShellInterpreter()->execCmdLine(this, term->mCmd);
						if (!flgSendAny)
							term->showLineMx();
						break;
					case actALTCHAR:
						getShellInterpreter()->execAltChar(this, term->mAltChar);
						break;
					case actFUNKEY:
						getShellInterpreter()->execFunKey(this, term->mFunKey);
						break;
					}
				}
			} else if (code == SIGNAL_MSG) {

			}
		}
	}
}


