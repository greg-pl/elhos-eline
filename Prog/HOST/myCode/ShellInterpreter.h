/*
 * shell.h
 *
 *  Created on: Dec 5, 2020
 *      Author: Grzegorz
 */

#ifndef SHELL_H_
#define SHELL_H_

#include "uart.h"
#include "EscTerminal.h"
#include "ping.h"
#include "BaseDevShellInterpreter.h"


//------------------------------------------------------------------------------------------------------------
class ShellInterpreter :public BaseDevShellInterpreter {
private:
	void hdMenu(OutStream *strm, const char *cmd);
protected:
	virtual const char* getMainMenuCap();
	virtual void meShowHdwState(OutStream *strm);
	virtual void meShowDevState(OutStream *strm);
	virtual const ShellItem *getChildMenu();
	virtual bool execChildFun(OutStream *strm, int idx, const char *cmd);

public:
	ShellInterpreter();
};



#endif /* SHELL_H_ */
