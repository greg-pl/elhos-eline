/*
 * BaseShellInterpreter.h
 *
 *  Created on: Mar 23, 2021
 *      Author: Grzegorz
 */

#ifndef KPHOST_INTERF_BASESHELLINTERPRETER_H_
#define KPHOST_INTERF_BASESHELLINTERPRETER_H_

#include "IOStream.h"
#include <EscTerminal.h>

class BaseShellInterpreter{
public:
	virtual void execFunKey(OutStream *strm, FunKey funKey)=0;
	virtual void execCmdLine(OutStream *strm, const char *cmd)=0;
	virtual void execAltChar(OutStream *strm, char altChar)=0;
};


#endif /* KPHOST_INTERF_BASESHELLINTERPRETER_H_ */
