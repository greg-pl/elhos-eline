/*
 * MsgStream.h
 *
 *  Created on: Dec 11, 2020
 *      Author: Grzegorz
 */

#ifndef MSGSTREAM_H_
#define MSGSTREAM_H_

#include "stdarg.h"
typedef enum {
	colWHITE = 0, colRED, colGREEN, colBLUE, colMAGENTA, colYELLOW, colCYAN,
} TermColor;


class OutStream {
public:
	virtual ~OutStream(){

	}
	void oMsgX(TermColor color, const char *pFormat, ...);
	void oMsg(const char *pFormat, ...);

	virtual void oWrX(TermColor color, const char *buf)=0; //oDumpBuf
	virtual void oFormatX(TermColor color, const char *pFormat, va_list ap)=0;
	virtual void oFormat(const char *pFormat, va_list ap)=0;

	virtual bool oOpen(TermColor color)= 0;
	virtual void oClose()= 0;
	virtual void oWr(const char *txt)=0;
};

class SignaledClass {
public:
	virtual void setSignal()=0;
	virtual ~SignaledClass(){

	}
};


#endif /* MSGSTREAM_H_ */
