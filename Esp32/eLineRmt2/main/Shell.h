/*
 * Shell.h
 *
 *  Created on: 2 kwi 2021
 *      Author: Grzegorz
 */

#ifndef MAIN_SHELL_H_
#define MAIN_SHELL_H_

#include "TaskClass.h"

class Shell : public TaskClass{
private:
	void initialize_console(void);
	void menu(char ch);

protected:
	void taskFun();
public:
	Shell();
};

#endif /* MAIN_SHELL_H_ */
