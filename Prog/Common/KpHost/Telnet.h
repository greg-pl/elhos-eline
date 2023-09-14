/*
 * Telnet.h
 *
 *  Created on: Jun 14, 2021
 *      Author: Grzegorz
 */

#ifndef TELNET_H_
#define TELNET_H_

#include "TcpSvrTask.h"
#include "EscTerminal.h"
#include "ShellTask.h"
#include "IOStream.h"
#include "BaseShellInterpreter.h"

class TelnetTcpTask: public TcpCmmTask, public OutStream {
private:
	typedef enum {
		uuNoLogged=0, //
		uuOper, //
		uuAdmin
	} UserId;

	typedef enum {
		phEntUserName, //
		phEntPassword, //
		phLogged,
	} TelPhase;
	EscTerminal *term;
	char outBuf[200];  //dostęp do bufora tylko po otwarciu semafora
	bool flgSendAny;
	char userName[20];
	TelPhase phase;
	UserId userId;

	UserId checkUser(const char *userName, const char *passwd);

protected:
	virtual int onDataRecive(char *buf, int len);
	virtual void afterWakeUp();
	virtual void closeTerm();
public:
	//TermStream
	virtual void putOut(const void *mem, int len);

public:
	TelnetTcpTask(int nr);
	static TcpCmmTask* createMe(int nr);
};

class TelnetSvrTask: public TcpSvrTask {
public:
	TelnetSvrTask();
};

#endif /* TELNET_H_ */
