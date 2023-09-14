/*
 * TaskClass.cpp
 *
 *  Created on: 2 kwi 2021
 *      Author: Grzegorz
 */

#include "stddef.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#include "TaskClass.h"

TaskClass::TaskClass(int stackSize) {
	mStackSize = stackSize;
	// TODO Auto-generated constructor stub

}

TaskClass::~TaskClass() {
	// TODO Auto-generated destructor stub
}

void TaskClass::TaskFun(void *pvParameters) {
	TaskClass *task = (TaskClass*)pvParameters;
	task->taskFun();
}

void TaskClass::start() {
	xTaskCreate(TaskFun, "main_task", mStackSize , this, 5, NULL);
}
