/*
 * TaskClass.cpp
 *
 *  Created on: 2 kwi 2021
 *      Author: Grzegorz
 */

#include "stddef.h"
#include "string.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#include "TaskClass.h"

TaskClass::TaskClass(const char *taskName, int stackSize) {
	mStackSize = stackSize;
	strlcpy(mTaskName, taskName, sizeof(mTaskName));
	mTaskHandle = NULL;
	mLoopCnt =0;
	mDebug =0;
}

void TaskClass::setTaskName(const char *name) {
	strlcpy(mTaskName, name, sizeof(mTaskName));
}

TaskClass::~TaskClass() {

}

void TaskClass::TaskFun(void *pvParameters) {
	TaskClass *task = (TaskClass*) pvParameters;
	task->ThreadFunc();
}

void TaskClass::start() {
	xTaskCreate(TaskFun, mTaskName, mStackSize, this, 5, &mTaskHandle);
}

void TaskClass::suspendMe() {
	vTaskSuspend(mTaskHandle);
}
void TaskClass::resumeMe() {
	vTaskResume(mTaskHandle);

}

