/*
 * TcpSvrTask.cpp
 *
 *  Created on: 7 kwi 2021
 *      Author: Grzegorz
 */

#include "UMain.h"
#include "Token.h"
#include "ShellItem.h"
#include "TcpSvrTask.h"
#include "utils.h"
#include <DevCommonCmd.h>

enum {
#include  "DevCommon.ctg"
};

TcpCmmTask::TcpCmmTask(int nr, int stackSize, int rxBufSize, int txBufSize) :
		TaskClass::TaskClass("CMM", osPriorityNormal, 1024) {
	mMyNr = nr;
	memset(&txRec, 0, sizeof(txRec));
	memset(&rxRec, 0, sizeof(rxRec));
	memset(&mState, 0, sizeof(mState));

	rxRec.size = rxBufSize;
	rxRec.buf = (char*) malloc(rxBufSize);
	rxRec.len = 0;

	txRec.size = txBufSize;
	txRec.buf = (char*) malloc(txBufSize);
	txRec.len = 0;

	if (txRec.buf == NULL || rxRec.buf == NULL) {
		getOutStream()->oMsgX(colRED, "No memory");
		abort();
	}
	mSock = 0;
	zeroState();
	mState.working = false;
	mState.workTick = 0;
	txRec.smf.snd_mux = xSemaphoreCreateMutex();
}

TcpCmmTask::~TcpCmmTask() {
	free(txRec.buf);
	free(rxRec.buf);
}

void TcpCmmTask::terminate() {
	mState.working = false;
}


void TcpCmmTask::setDef(const TCmmDef *aDef) {
	mDef = *aDef;
}

bool TcpCmmTask::lock(int id) {

	bool q = (xSemaphoreTake(txRec.smf.snd_mux, portMAX_DELAY) == pdTRUE);
	if (q) {
		txRec.smf.lockID = id;
		txRec.smf.lockTask = uxTaskGetTaskNumber(osThreadGetId());
	}
	return q;

}

void TcpCmmTask::unlock() {
	txRec.smf.lockID = 0;
	txRec.smf.lockTask = 0;
	xSemaphoreGive(txRec.smf.snd_mux);
}

void TcpCmmTask::startCmm(int sock, struct sockaddr_in *svr_addr) {
	mSock = sock;
	m_svr_addr = *svr_addr;
	mState.working = true;
	mState.workTick = HAL_GetTick();
	resumeMe();
}

bool TcpCmmTask::sendBuf_(const void *dt, int len) {
	mStatistic.phase = 0x10221;
	const uint8_t *buf = (const uint8_t*) dt;
	int ptr = 0;
	int len1 = len;
	bool res = true;
	while (len > 0) {
		mStatistic.phase = 0x10222;
		int n = send(mSock, &buf[ptr], len, 0);
		mStatistic.phase = 0x10223;
		if (n < 0) {
			getOutStream()->oMsgX(colRED, "%s: Error occurred during sending: errno %d", getTaskName(), errno);
			res = false;
			break;
		} else {
			if (mDebug > MSG_DATA)
				getOutStream()->oMsgX(colCYAN, "%s: Sended %u/%u", getTaskName(), n, len1);
		}
		len -= n;
		mStatistic.phase = 0x10224;
	}
	return res;
}

bool TcpCmmTask::sendBuf() {
	bool res = false;
	mStatistic.phase = 0x10201;
	if (lock(1)) {
		mStatistic.phase = 0x10202;
		res = sendBuf_(txRec.buf, txRec.len);
		mStatistic.phase = 0x10203;
		txRec.len = 0;
		unlock();
		mStatistic.phase = 0x10204;
	}
	return res;
}

void TcpCmmTask::addToSend(const void *ptr, int len) {
	if (lock(2)) {
		const char *dt = (const char*) ptr;

		while (len > 0) {
			int sz = txRec.size - txRec.len;
			int len1 = len;
			if (len1 > sz)
				len1 = sz;
			memcpy(&txRec.buf[txRec.len], dt, len1);
			txRec.addTick = HAL_GetTick();
			if (txRec.len == 0) {
				txRec.firstTick = txRec.addTick;
			}

			txRec.len += len1;
			sendBuf_(txRec.buf, txRec.len);
			txRec.len = 0;

			dt += len1;
			len -= len1;
		}
		unlock();
	} else {
		getOutStream()->oMsgX(colRED, "%s: AddToSend: Brak dostępu do semafora", getTaskName());
	}
}

char* TcpCmmTask::getSndBuf() {
	return txRec.buf;
}

bool TcpCmmTask::sendFromOwnBuf_(int len) {
	txRec.len = len;
	return  sendBuf_(txRec.buf, txRec.len);
}

int TcpCmmTask::getMyNr() {
	return mMyNr;
}


void TcpCmmTask::zeroState() {
	memset(&mStatistic, 0, sizeof(mStatistic));
	txRec.addTick = 0;
	txRec.firstTick = 0;
}

void TcpCmmTask::ThreadFunc() {
	char txt[40];

	while (1) {
		mStatistic.phase = 0x10000;
		beforeSleep();
		suspendMe();
		mStatistic.phase = 0x10001;
		afterWakeUp();

		mStatistic.phase = 0x10002;

		inet_ntoa_r(m_svr_addr.sin_addr.s_addr, txt, sizeof(txt) - 1);
		getOutStream()->oMsgX(colWHITE, "%s: Start connection %s:%u", getTaskName(), txt, m_svr_addr.sin_port);

		mStatistic.phase = 0x10003;

		struct timeval tm;
		tm.tv_sec = 1;
		tm.tv_usec = 0;
		int err = setsockopt(mSock, SOL_SOCKET, SO_RCVTIMEO, &tm, sizeof(tm));
		if (err < 0) {
			getOutStream()->oMsgX(colRED, "%s: Socket unable to set socket option: errno %d", getTaskName(), errno);
		}
		mStatistic.phase = 0x10004;

		zeroState();
		mLoopCnt = 0;
		int rdPtr = 0;
		while (mState.working) {
			mStatistic.phase = 0x10101;
			mLoopCnt++;

			struct timeval tv;

			tv.tv_usec = 50000;  //50[ms]
			tv.tv_sec = 0;

			fd_set rfds;
			fd_set erds;

			FD_ZERO(&rfds);
			FD_ZERO(&erds);
			FD_SET(mSock, &rfds);
			FD_SET(mSock, &erds);
			mStatistic.phase = 0x10102;

			int recVal = select(mSock + 1, &rfds, NULL, &erds, &tv);
			mStatistic.phase = 0x30003;
			if (recVal > 0) {
				if (FD_ISSET(mSock, &rfds)) {
					mStatistic.phase = 0x10103;
					int len = recv(mSock, &rxRec.buf[rdPtr], rxRec.size - rxRec.len - 1, 0);
					mStatistic.phase = 0x30005;
					if (len > 0) {
						mState.workTick = HAL_GetTick();
						mStatistic.phase = 0x10104;
						rxRec.len += len;
						rxRec.buf[rdPtr + len] = 0;

						int getLen = onDataRecive(rxRec.buf, rxRec.len);
						if (getLen == 0) {
							//nic nie zostało pobrane - niekompletne dane
						} else if (getLen >= rxRec.len || getLen < 0) {
							//wszystko zostało pobrane
							rxRec.len = 0;
						} else if (getLen > 0) {
							//z bufora zostala pobrana część
							// przesunięcie pozostałości na początek bufora
							int sz = rxRec.len - getLen;
							for (int i = 0; i < sz; i++) {
								rxRec.buf[i] = rxRec.buf[i + getLen];
							}
							rxRec.len = sz;

						}

						mStatistic.phase = 0x10105;
					} else {
						rxRec.len = 0;
						mState.working = false;
						getOutStream()->oMsgX(colWHITE, "%s: Remote closing 2", getTaskName());
					}
				}
				mStatistic.phase = 0x10106;
				if (FD_ISSET(mSock, &erds)) {
					mState.working = false;
					getOutStream()->oMsgX(colWHITE, "%s: Remote closing 1", getTaskName());
				}
			}
			if (mDef.tmKeepAlive > 0) {

				if (HAL_GetTick() - txRec.sendTick > mDef.tmKeepAlive) {
					mStatistic.phase = 0x10107;
					SendKeepAlive();
				}
			}
			mStatistic.phase = 0x10108;
			onLoopProc();

			mStatistic.phase = 0x1010A;

			if (HAL_GetTick() - mState.workTick > mDef.tmToAutoClose) {
				mState.working = false;
				getOutStream()->oMsgX(colWHITE, "%s: TimeOut connection", getTaskName());

			}
		}
		mStatistic.phase = 0x1000A;
		shutdown(mSock, 0);
		close(mSock);
		mStatistic.phase = 0x1000B;
		onDisConnecting();
		mStatistic.phase = 0x1000C;
	}
}
void TcpCmmTask::showState(OutStream *strm) {
	strm->oMsg(getTaskName());
	if (mState.working) {
		char txt[20];
		inet_ntoa_r(m_svr_addr.sin_addr.s_addr, txt, sizeof(txt) - 1);
		strm->oMsg("  SVR:%s:%u", txt, m_svr_addr.sin_port);
		strm->oMsg("  LoopCnt:%u", mLoopCnt);
		strm->oMsg("  Phase  :0x%06x", mStatistic.phase);
		strm->oMsg("  Smf    :%u (TaskID=%u)", txRec.smf.lockID, txRec.smf.lockTask);

	} else {
		strm->oMsg("  Free");
	}
//printf("  Semafor:%p\n", snd_mux);
}

//----------------------------------------------------------------------------------------------
//  TcpSvrTask
//----------------------------------------------------------------------------------------------
TcpSvrTask *TcpSvrTask::me;

TcpSvrTask::TcpSvrTask(const TcpSvrDev *def) :
		TaskClass::TaskClass(def->svrTaskName, osPriorityNormal, 512) {
	me = this;
	memset(&globSvrState, 0, sizeof(globSvrState));
	mDef.listenPort = def->mPort;
	mDef.svrCnt = def->svrCnt;
	mCmmTab = (TcpCmmTask**) malloc(mDef.svrCnt * sizeof(void*));

	for (int i = 0; i < mDef.svrCnt; i++) {
		mCmmTab[i] = def->getClientTask(i); //new TcpCmmTask(i, 1024, 1024);
		char name[8];
		snprintf(name, sizeof(name), "%s_%u", def->cmmTaskName, i + 1);
		mCmmTab[i]->setTaskName(name);
		mCmmTab[i]->setDef(&def->cmmDef);
	}
}

void TcpSvrTask::start() {

	for (int i = 0; i < mDef.svrCnt; i++) {
		mCmmTab[i]->start();
	}
	TaskClass::start();
}

TcpCmmTask* TcpSvrTask::getCmmTask(int idx) {
	if (idx < mDef.svrCnt)
		return mCmmTab[idx];
	else
		return NULL;
}

int TcpSvrTask::findUnoccupatedCmm() {
	int idx = -1;
	for (int i = 0; i < mDef.svrCnt; i++) {
		if (!mCmmTab[i]->isWorking()) {
			idx = i;
			break;
		}
	}
	return idx;
}

void TcpSvrTask::ThreadFunc() {
	OutStream *strm = getOutStream();

	xEventGroupWaitBits(sysEvents, EVENT_NETIF_OK, false, false, portMAX_DELAY);
	strm->oMsgX(colGREEN, "TcpSvrTask");

	int err = 0;

	struct sockaddr_in dest_addr;
//struct sockaddr_in *dest_addr_ip4 = (struct sockaddr_in*) &dest_addr;
	dest_addr.sin_addr.s_addr = htonl(INADDR_ANY);
	dest_addr.sin_family = AF_INET;
	dest_addr.sin_port = htons(mDef.listenPort);

	int listen_sock = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
	if (listen_sock < 0) {
		strm->oMsgX(colRED, "Unable to create socket: errno %d", errno);
		goto CLEAN_UP_1;
	}

	err = bind(listen_sock, (struct sockaddr* ) &dest_addr, sizeof(dest_addr));
	if (err != 0) {
		strm->oMsgX(colRED, "Socket unable to bind: errno %d", errno);
		goto CLEAN_UP_2;
	}
	strm->oMsgX(colWHITE, "Socket bound, port %d", mDef.listenPort);

	err = listen(listen_sock, 1);
	if (err != 0) {
		strm->oMsgX(colRED, "Error occurred during listen: errno %d", errno);
		goto CLEAN_UP_2;
	}
	while (1) {
		strm->oMsgX(colWHITE, "Socket listening");
		struct sockaddr_in source_addr; // Large enough for both IPv4 or IPv6
		socklen_t addr_len = sizeof(source_addr);
		int sock = accept(listen_sock, (struct sockaddr* ) &source_addr, &addr_len);
		if (sock >= 0) {
			int idx = findUnoccupatedCmm();
			if (idx >= 0) {
				mCmmTab[idx]->startCmm(sock, &source_addr);
			} else {
				shutdown(sock, 0);
				close(sock);
			}

		}
	}

	CLEAN_UP_2: //
	close(listen_sock);
	CLEAN_UP_1: //
	vTaskDelete(NULL);
}

bool TcpSvrTask::isAnyWorking() {
	bool q = false;
	for (int i = 0; i < mDef.svrCnt; i++) {
		if (mCmmTab[i]->isWorking()) {
			q = true;
			break;
		}
	}
	return q;
}

const ShellItem menuSVR[] = { //
		{ "s", "stan" }, //
		{ "dbg", "poziom logów dla danego tasku (nr_svr level)" }, //

		{ "send1", "Testowa komenda 1" }, //
		{ "send2", "Testowa komenda 2" }, //

		{ NULL, NULL } };

void TcpSvrTask::shell(OutStream *strm, const char *cmd) {
	char tok[20];
	int idx = -1;

	if (Token::get(&cmd, tok, sizeof(tok)))
		idx = findCmd(menuSVR, tok);
	switch (idx) {
	case 0: //s
		if (strm->oOpen(colWHITE)) {
			strm->oMsg("GlobErrTyp1Cnt : %u", globSvrState.errTyp1Cnt);
			strm->oMsg("GlobErrTyp2Cnt : %u", globSvrState.errTyp2Cnt);
			for (int i = 0; i < mDef.svrCnt; i++) {
				mCmmTab[i]->showState(strm);
			}
			strm->oClose();
		}
		break;
	case 1: { //dbg
		int nrSvr;
		int dbg;
		if (Token::getAsInt(&cmd, &nrSvr)) {
			if (Token::getAsInt(&cmd, &dbg)) {
				if (nrSvr >= 1 && nrSvr <= mDef.svrCnt) {
					mCmmTab[nrSvr - 1]->setDebug(dbg);
				} else if (nrSvr == 0) {
					mDebug = dbg;
				}

			}
		}

	}
		break;
	case 2:
		break;
	case 3:
		break;

	default:
		showHelp(strm, "Svr Menu", menuSVR);
		break;
	};
}

