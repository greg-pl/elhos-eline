/*
 * ShellTaskA.h
 *
 *  Created on: Mar 23, 2021
 *      Author: Grzegorz
 */

#ifndef KPHOST_SHELLTASK_H_
#define KPHOST_SHELLTASK_H_

#include "TaskClass.h"
#include "EscTerminal.h"
#include "IOStream.h"


class UartShellConnection;

class ShellTask: public TaskClass, public OutStream {
public:
	enum {
		SIGNAL_CHAR = 0x01, //
		SIGNAL_MSG = 0x02, //
	};
private:
	UartShellConnection *myConnection;
	EscTerminal *term;

	char outBuf[200];  //dostęp do bufora tylko po otwarciu semafora
	bool flgSendAny;
	int mFullTxCnt;  // licznik gdy przepełniony bufor TX

protected:
	//TaskClass
	virtual void ThreadFunc();

protected:
	//OutStream
	virtual void putOut(const void *mem, int len);
public:
	ShellTask(int PortNr);
};

#endif /* KPHOST_SHELLTASK_H_ */
