/*
 * TaskClass.cpp
 *
 *  Created on: Oct 8, 2020
 *      Author: Grzegorz
 */

#include "TaskClass.h"

#include "string.h"
#include "stdio.h"
#include "stdlib.h"
#include "cmsis_os.h"
#include "TaskClass.h"
#include "main.h"
#include "UMain.h"

static int inHandlerMode_(void) {
	return __get_IPSR() != 0;
}

osEvent osSignalWaitClrOnEntry(int32_t signals, uint32_t millisec) {
	osEvent ret;
	TickType_t ticks;

	ret.value.signals = 0;
	ticks = 0;
	if (millisec == osWaitForever) {
		ticks = portMAX_DELAY;
	} else if (millisec != 0) {
		ticks = millisec / portTICK_PERIOD_MS;
		if (ticks == 0) {
			ticks = 1;
		}
	}

	if (inHandlerMode_()) {
		ret.status = osErrorISR; /*Not allowed in ISR*/
	} else {
		if (xTaskNotifyWait((uint32_t) signals, (uint32_t) signals, (uint32_t*) &ret.value.signals, ticks) != pdTRUE) {
			if (ticks == 0)
				ret.status = osOK;
			else
				ret.status = osEventTimeout;
		} else if (ret.value.signals >= (int32_t) 0x80000000) {
			ret.status = osErrorValue;
		} else
			ret.status = osEventSignal;
	}
	return ret;
}

void ThreadEntryFunc(void const *argument) {
	TaskClass *task = (TaskClass*) (unsigned int) argument;
	task->RunThread();
}

TaskClass::TaskClass(const char *name, osPriority aPriority, int stacksize) {
	strncpy(mThreadName, name, sizeof(mThreadName));
	memset(&mThreadDef, 0, sizeof(mThreadDef));
	mThreadDef.name = mThreadName;
	mThreadDef.stacksize = stacksize;
	mThreadDef.tpriority = aPriority;
	mThreadDef.instances = 0;
	mThreadDef.pthread = ThreadEntryFunc;
	mRunning = false;
	mSuspend = false;
	mThreadId = NULL;
	mDebug = 0;
	mAlivePeriod = 2000;
	mAliveTick = 0;
	mLoopCnt = 0;
	mLoopCntPerSek = 0;
	maxAliveBreak = 0;
	TaskClassList::Register(this);
}

//musi być wywołane przed Start
void TaskClass::setTaskName(const char *name) {
	strncpy(mThreadName, name, sizeof(mThreadName));
}

void TaskClass::start() {
	mThreadId = osThreadCreate(&mThreadDef, (void*) this);

	if (mThreadId == NULL)
		getOutStream()->oMsgX(colRED, "osThreadCreate ERROR");
}

void TaskClass::RunThread() {
	OutStream *strm = getOutStream();
	strm->oMsgX(colGREEN, "Task %s, START", mThreadName);// (int) uxTaskGetTaskNumber(mThreadId));
	mRunning = true;
	ThreadFunc();
	strm->oMsgX(colWHITE, "Task %s, EXIT", mThreadName);
	vTaskDelete( NULL);
}

void TaskClass::ThreadFunc() {
	while (1) {
		osDelay(2000);
		getOutStream()->oMsgX(colWHITE, "Task %s", mThreadName);
	}
}

void TaskClass::every1sek() {
	mLoopCntPerSek = mLoopCnt;
	mLoopCnt = 0;
}

void TaskClass::imAlive() {
	uint32_t tt = HAL_GetTick();
	uint32_t dt = tt - mAliveTick;
	if (dt > maxAliveBreak)
		maxAliveBreak = dt;

	mAliveTick = tt;
	mLoopCnt++;
}

bool TaskClass::isAlive() {
	return (HAL_GetTick() - mAliveTick < mAlivePeriod);
}

void TaskClass::suspendMe() {
	mSuspend = true;
	osThreadSuspend(mThreadId);
	mSuspend = false;
}

void TaskClass::resumeMe() {
	osThreadResume(mThreadId);
}

void TaskClass::wakeUpMe() {
	if (mThreadId != NULL) {
		osSignalSet(mThreadId, SIGNAL_WAKEUP);
	}
}

//--------------------------------------------------------------------------
// TaskClassList
//--------------------------------------------------------------------------
TaskClass *TaskClassList::taskList[MAX_TASK_CNT];
TaskClass *TaskClassList::taskListEvery1ms[MAX_TASK_CNT];

int TaskClassList::taskCnt;
int TaskClassList::taskEver1msCnt;

void TaskClassList::Register(TaskClass *task) {
	if (taskCnt < MAX_TASK_CNT) {
		taskList[taskCnt++] = task;
	} else {
		getOutStream()->oMsgX(colRED, "MAX_TASK_CNT too small");
	}
}

void TaskClassList::every1sek() {
	for (int i = 0; i < taskCnt; i++)
		taskList[i]->every1sek();
}

void TaskClassList::every1msek() {
	for (int i = 0; i < taskEver1msCnt; i++) {
		taskListEvery1ms[i]->every1msek();
	}
}

void TaskClassList::Add1msTask(TaskClass *task) {
	taskListEvery1ms[taskEver1msCnt] = task;
	taskEver1msCnt++;
}

int printTaskInf(char *line, int max, TaskStatus_t *tsk) {
	return snprintf(line, max, "%3u|%16s|%p|%5u|%2u|%2u|%5u|",	//
			(int) tsk->xTaskNumber, //
			tsk->pcTaskName,	//
			tsk->pxStackBase, //
			tsk->usStackHighWaterMark, //
			(int) tsk->uxBasePriority, //
			(int) tsk->uxCurrentPriority, //
			(int) tsk->ulRunTimeCounter);
}

void TaskClassList::ShowList(OutStream *stream) {

	int tCnt = uxTaskGetNumberOfTasks();

	TaskStatus_t *aTaskBuf = (TaskStatus_t*) malloc(tCnt * sizeof(TaskStatus_t));
	bool *flagsBuf = (bool*) malloc(tCnt * sizeof(bool));
	int SZL = 160;
	char *line = (char*) malloc(SZL);

	if ((aTaskBuf != NULL) && (flagsBuf != NULL) && (line != NULL)) {
		tCnt = uxTaskGetSystemState(aTaskBuf, tCnt, NULL);
		memset(flagsBuf, 0, tCnt * sizeof(bool));

		//OutStream *stream = getOutStream();

		if (stream->oOpen(colWHITE)) {
			stream->oMsg("lp|name            |r|loop/s|max.br|Tnr|OsName          |StackAdr  |StPos|bP|cP|Time |");
			stream->oMsg("--+----------------+-+------+------+---+----------------+----------+-----+--+--+-----+");
			for (int i = 0; i < taskCnt; i++) {
				char ch = '.';
				if (taskList[i]->mRunning)
					ch = '+';
				if (taskList[i]->mSuspend)
					ch = 'S';
				int n = snprintf(line, SZL, "%2u|%16s|%c|%6u|%6u|", i, taskList[i]->getTaskName(), ch, (int) taskList[i]->mLoopCntPerSek,
						(int) taskList[i]->maxAliveBreak);
				taskList[i]->maxAliveBreak = 0;
				int idx = -1;
				for (int j = 0; j < tCnt; j++) {
					if (aTaskBuf[j].xHandle == taskList[i]->mThreadId) {
						idx = j;
						break;
					}
				}
				if (idx >= 0) {
					flagsBuf[idx] = true;
					n += printTaskInf(&line[n], SZL - n, &aTaskBuf[idx]);

				} else {
					n += snprintf(&line[n], SZL - n, "   |");
				}
				stream->oMsg(line);

			}
			for (int j = 0; j < tCnt; j++) {
				if (!flagsBuf[j]) {
					int n = snprintf(line, SZL,"%2u|                | |      |      |", taskCnt + j);
					n += printTaskInf(&line[n], SZL - n, &aTaskBuf[j]);
					stream->oMsg(line);
				}
			}

			stream->oMsg("--+----------------+-+------+------+---+----------------+----------+-----+--+--+-----+");
			stream->oClose();
		}

	}
	free(line);
	free(flagsBuf);
	free(aTaskBuf);
}

int TaskClassList::FindTask(TaskClass *aTask) {
	for (int i = 0; i < taskCnt; i++) {
		if (taskList[i] == aTask) {
			return i;
		}
	}
	return -1;
}

