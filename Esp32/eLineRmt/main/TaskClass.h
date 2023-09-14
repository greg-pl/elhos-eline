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
	char mTaskName[32];
	TaskHandle_t mTaskHandle;
	static void TaskFun(void *pvParameters);
protected:
	int mLoopCnt;
	int mDebug;
	virtual void ThreadFunc()=0;
public:
	TaskClass(const char *taskName, int stackSize);
	virtual ~TaskClass();
	void start();
	TaskHandle_t getTaskHandle() {
		return mTaskHandle;
	}
	void suspendMe();
	void resumeMe();
	void setTaskName(const char *name);
	const char *getTaskName(){
		return mTaskName;
	}
};

#endif /* MAIN_TASKCLASS_H_ */
