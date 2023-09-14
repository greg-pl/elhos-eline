/*
 * IOStream.cpp
 *
 *  Created on: 5 maj 2021
 *      Author: Grzegorz
 */


#include <stdarg.h>
#include <stdio.h>


#include "IOStream.h"


void OutStream::oMsgX(TermColor color, const char *pFormat, ...) {
	va_list ap;
	va_start(ap, pFormat);
	oFormatX(color, pFormat, ap);
	va_end(ap);
}

void OutStream::oMsg(const char *pFormat, ...) {
	va_list ap;
	va_start(ap, pFormat);
	oFormat(pFormat, ap);
}
