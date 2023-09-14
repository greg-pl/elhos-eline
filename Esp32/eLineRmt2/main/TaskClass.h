/*
 * TaskClass.h
 *
 *  Created on: 2 kwi 2021
 *      Author: Grzegorz
 */

#ifndef MAIN_TASKCLASS_H_
#define MAIN_TASKCLASS_H_

class TaskClass {
private:
	int mStackSize;
	static void TaskFun(void *pvParameters);
protected:
	virtual void taskFun()=0;
public:
	TaskClass(int stackSize);
	virtual ~TaskClass();
	void start();
};

#endif /* MAIN_TASKCLASS_H_ */
