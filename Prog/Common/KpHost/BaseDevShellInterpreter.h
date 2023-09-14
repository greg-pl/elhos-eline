/*
 * BaseDevShellInterpreter.h
 *
 *  Created on: Mar 23, 2021
 *      Author: Grzegorz
 */

#ifndef KPHOST_BASEDEVSHELLINTERPRETER_H_
#define KPHOST_BASEDEVSHELLINTERPRETER_H_

#include "BaseShellInterpreter.h"
#include "ShellItem.h"
#include "Ping.h"

class BaseDevShellInterpreter: public BaseShellInterpreter {
private:
	PingObj *pingObj;
	void ethMenu(OutStream *strm, const char *cmd);
	void netMenu(OutStream *strm, const char *cmd);

	void showTaskList(OutStream *strm);
	void showMemInfo(OutStream *strm);

	void showHdwState(OutStream *strm);
	void showDevState(OutStream *strm);
	bool execOwnCmdLine(OutStream *strm, int idx, const char *cmd);
	void showMainMenu(OutStream *strm);

protected:
	virtual void meShowHdwState(OutStream *strm);
	virtual void meShowDevState(OutStream *strm);
	virtual const char* getMainMenuCap()=0;
	virtual const ShellItem* getChildMenu() {
		return NULL;
	}
	virtual bool execChildFun(OutStream *strm, int idx, const char *cmd) {
		return false;
	}

public:
	BaseDevShellInterpreter();
	virtual void execFunKey(OutStream *strm, FunKey funKey);
	virtual void execAltChar(OutStream *strm, char altChar);
	virtual void execCmdLine(OutStream *strm, const char *cmd);
};

#endif /* KPHOST_BASEDEVSHELLINTERPRETER_H_ */
