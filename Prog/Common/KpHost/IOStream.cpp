/*
 * IOStream.cpp
 *
 *  Created on: Jun 14, 2021
 *      Author: Grzegorz
 */

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "myDef.h"

#include "IOStream.h"
#include "utils.h"

OutStream::OutStream() :
		OutHdStream::OutHdStream() {

}

//extern "C" byte getCurrentLanguage();

int OutStream::LangFiltr(int len) {
	//return UniLangFiltr(outBuf,len);
	return len;
}

void OutStream::oFormat(TermColor color, const char *pFormat, va_list ap) {
	if (oOpen(color)) {
		int len = vsnprintf(outBuf, sizeof(outBuf), pFormat, ap);
		len = LangFiltr(len);
		putOut(outBuf, len);
		putStr("\r\n");
		oClose();
	}
}

void OutStream::oMsgX(TermColor color, const char *pFormat, ...) {
	va_list ap;
	va_start(ap, pFormat);
	oFormat(color, pFormat, ap);
	va_end(ap);
}

bool OutStream::oOpen(TermColor color) {
	bool q = openOutMutex(OutHdStream::STD_TIME);
	if (q) {
		putStr(TERM_CLEAR_LINE);
		putStr(EscTerminal::getColorStr(color));
	}
	return q;
}

void OutStream::oSetColor(TermColor color){
	putStr(EscTerminal::getColorStr(color));
}


void OutStream::oClose() {
	escTermShowLineNoMx();
	closeOutMutex();
}

void OutStream::oWr(const char *txt) {
	int len = strlen(txt);
	putOut(txt, len);
	putStr("\r\n");
}

void OutStream::oMsg(const char *pFormat, ...) {
	va_list ap;
	va_start(ap, pFormat);
	int len = vsnprintf(outBuf, sizeof(outBuf), pFormat, ap);
	va_end(ap);
	len = LangFiltr(len);
	putOut(outBuf, len);
	putStr("\r\n");
}

void OutStream::oBufX(TermColor color, const void *buf, int len) {
	if (oOpen(color)) {
		putOut(buf, len);
		oClose();
	}

}

void OutStream::oWrX(TermColor color, const char *buf) {
	if (oOpen(color)) {
		int len = strlen(buf);
		putOut(buf, len);
		oClose();
	}
}
