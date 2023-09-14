/*
 * Telnet.cpp
 *
 *  Created on: Jun 14, 2021
 *      Author: Grzegorz
 */

#include <Telnet.h>
#include <BaseDev.h>
#include <UMain.h>

extern "C" BaseShellInterpreter* getShellInterpreter();

//----------------------------------------------------------------------------------------------
//  TelnetTcpTask
//----------------------------------------------------------------------------------------------
TelnetTcpTask::TelnetTcpTask(int nr) :
		TcpCmmTask::TcpCmmTask(nr, 512, 0x80, 0x400), OutStream::OutStream() {
	term = new EscTerminal(this);
	mDebug = MSG_ERR;
	phase = phEntUserName;
	userId = uuNoLogged;
}

TcpCmmTask* TelnetTcpTask::createMe(int nr) {
	TelnetTcpTask *item = new TelnetTcpTask(nr);

	return (TcpCmmTask*) item;
}

//TermStream
void TelnetTcpTask::putOut(const void *mem, int len) {
	if (isWorking()) {
		addToSend((char*) mem, len);
	}
}

TelnetTcpTask::UserId TelnetTcpTask::checkUser(const char *userName, const char *passwd) {
	if (strcmp(userName, "admin") == 0 && strcmp(passwd, "0972") == 0) {
		return uuAdmin;
	}
	if (strcmp(userName, "operator") == 0 && strcmp(passwd, "0966") == 0) {
		return uuOper;
	}
	return uuNoLogged;
}

void TelnetTcpTask::afterWakeUp() {
	oOpen(colYELLOW);
	oMsg("%s Welcome", DEV_NAME);
	oMsg("-----------------------");
	oClose();
	term->setPrompt("User name:");
	phase = phEntUserName;
}

void TelnetTcpTask::closeTerm() {
	terminate();
}

int TelnetTcpTask::onDataRecive(char *buf, int len) {
	if (mDebug >= MSG_INFO) {
		int n = snprintf(outBuf, sizeof(outBuf), "%s: Recived %u bt: ", getTaskName(), len);

		if (mDebug >= MSG_DATA) {
			for (int i = 0; i < len; i++) {
				if (sizeof(outBuf) - n - 1 < 2)
					break;
				n += snprintf(&outBuf[n], sizeof(outBuf) - n - 1, "%02X ", buf[i]);
			}
		}
		getOutStream()->oMsgX(colWHITE, outBuf);
	}

	for (int i = 0; i < len; i++) {
		char key = buf[i];

		TermAct act = term->inpChar(key);
		switch (phase) {
		case phEntUserName:
			if (act == actLINE) {
				if (strlen(term->mCmd) > 0) {
					strlcpy(userName, term->mCmd, sizeof(userName));
					term->setPrompt("Password:");
					phase = phEntPassword;
				} else {
					term->setPrompt("User name:");
				}
			}
			break;
		case phEntPassword:
			if (act == actLINE) {

				userId = checkUser(userName, term->mCmd);
				if (userId != uuNoLogged) {
					phase = phLogged;
					term->setStdPrompt();
					oMsgX(colWHITE, "Logged.");
				} else {
					phase = phEntUserName;
					term->setPrompt("User name:");
				}
			}
			break;
		case phLogged:
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
			break;
		}
	}

	return len;
}

//----------------------------------------------------------------------------------------------
//  TelnetSvrTask
//----------------------------------------------------------------------------------------------

TcpSvrDev TelnetTcpSvrDef = { //
		mPort: 23, //
		svrCnt :2, //
		svrTaskName : "TEL_SVR", //
		cmmTaskName : "TEL", //
		getClientTask : &TelnetTcpTask::createMe, //

		cmmDef : { //
				tmToAutoClose : 600 * 1000, // czas do rozłaczenia sesji z powodu braku aktywności
				tmKeepAlive :0, // czas co który musi być coś wysłane
				tmMaxTimeInBuf :500, // maksymalny czas w buforze
				tmDataJoin : 100, //TM_DATA_JOIN = 100, // 250[ms] - czas sklejania danych
				}

		};

TelnetSvrTask::TelnetSvrTask() :
		TcpSvrTask::TcpSvrTask(&TelnetTcpSvrDef) {

}
