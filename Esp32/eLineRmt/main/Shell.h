/*
 * Shell.h
 *
 *  Created on: 2 kwi 2021
 *      Author: Grzegorz
 */

#ifndef MAIN_SHELL_H_
#define MAIN_SHELL_H_

#include "TaskClass.h"
#include "IOStream.h"

class Shell : public TaskClass ,  public OutStream {

private:
	char menuNr;
	char outBuf[200];
	void initialize_console(void);
	void mainMenu(char ch);
	void menu(char ch);
	void chipInfo();
	void tasksInfo();

protected:
	virtual void oWrX(TermColor color, const char *buf); //oDumpBuf
	virtual void oFormatX(TermColor color, const char *pFormat, va_list ap);
	virtual void oFormat(const char *pFormat, va_list ap);

	virtual bool oOpen(TermColor color);
	virtual void oClose();
	virtual void oWr(const char *txt);

protected:
	void ThreadFunc();
public:
	Shell();
};

extern "C" const char *ipToStr(char *buf, esp_ip4_addr_t ip);

#endif /* MAIN_SHELL_H_ */
