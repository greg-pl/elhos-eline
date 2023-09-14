/*
 * TcpSvrTask.cpp
 *
 *  Created on: 7 kwi 2021
 *      Author: Grzegorz
 */

#include "esp_event.h"
#include "esp_log.h"

#include "UMain.h"
#include "Token.h"
#include "MyConfig.h"
#include "utils.h"
#include <DevCommonCmd.h>


#include "TcpSvrTask.h"

static const char *TAG = "TCP_SVR";

TcpCmmTask::TcpCmmTask(int nr) :
		TaskClass::TaskClass("TcpCmm", 4096) {
	mMyNr = nr;
	mSock = 0;
	memset(&txState, 0, sizeof(txState));
	memset(&mState, 0, sizeof(mState));
	zeroState();
	mState.working = false;
	mState.workTick = 0;
	txState.smf.snd_mux = xSemaphoreCreateMutex();
	base64Tool = new Base64Tool();
}

bool TcpCmmTask::lock(int id) {

	bool q = (xSemaphoreTake(txState.smf.snd_mux, portMAX_DELAY) == pdTRUE);
	if (q) {
		txState.smf.lockID = id;
		txState.smf.lockTask = uxTaskGetTaskNumber(xTaskGetCurrentTaskHandle());
	}
	return q;

}

void TcpCmmTask::unlock() {
	txState.smf.lockID = 0;
	txState.smf.lockTask = 0;
	xSemaphoreGive(txState.smf.snd_mux);
}

void TcpCmmTask::startCmm(int sock, struct sockaddr_in *svr_addr) {
	mSock = sock;
	m_svr_addr = *svr_addr;
	mState.working = true;
	mState.workTick = esp_log_timestamp();
	resumeMe();
}

void TcpCmmTask::sendBuf_(const void *dt, int len) {
	mStatistic.phase = 0x10221;
	const uint8_t *buf = (const uint8_t*) dt;
	int ptr = 0;
	int len1 = len;
	while (len > 0) {
		mStatistic.phase = 0x10222;
		int n = send(mSock, &buf[ptr], len, 0);
		mStatistic.phase = 0x10223;
		if (n < 0) {
			ESP_LOGE(TAG, "%s: Error occurred during sending: errno %d", getTaskName(), errno);
			break;
		} else {
			if (mDebug > MSG_DATA)
				ESP_LOGI(TAG, "%s: Sended %u/%u", getTaskName(), n, len1);
		}
		len -= n;
		mStatistic.phase = 0x10224;
	}
}

void TcpCmmTask::sendBinBuf_() {
	mStatistic.phase = 0x10211;
	int n = base64Tool->Encode(&tx_buffer[1], bin_tx_buf, txState.binPtr);
	mStatistic.phase = 0x10302;
	tx_buffer[0] = STX;
	tx_buffer[1 + n] = ETX;
	mStatistic.phase = 0x10212;
	sendBuf_(tx_buffer, n + 2);
	mStatistic.phase = 0x10213;
	txState.binPtr = 0;
	txState.firstTick = 0;
	txState.addTick = 0;
	txState.sendTick = esp_log_timestamp();
}

void TcpCmmTask::sendBinBuf() {
	mStatistic.phase = 0x10201;
	if (lock(1)) {
		mStatistic.phase = 0x10202;
		sendBinBuf_();
		mStatistic.phase = 0x10203;
		unlock();
		mStatistic.phase = 0x10204;

	}
}

void TcpCmmTask::addToSend2(uint8_t devNr, uint8_t code, const void *dt1, int dt1_sz, const void *dt2, int dt2_sz) {
	if ((dt1_sz + dt2_sz) < BUF_BIN_SIZE - (int) sizeof(KObjHead)) {

		if (lock(2)) {
			int sz = sizeof(KObjHead) + (dt1_sz + dt2_sz);

			if (txState.binPtr + sz > BUF_BIN_SIZE) {
				sendBinBuf_();
			}

			txState.addTick = esp_log_timestamp();
			if (txState.binPtr == 0) {
				txState.firstTick = txState.addTick;
			}

			putWord(&bin_tx_buf[txState.binPtr], sz);
			bin_tx_buf[txState.binPtr + 2] = devNr;
			bin_tx_buf[txState.binPtr + 3] = code;
			if (dt1_sz > 0 && dt1 != NULL) {
				memcpy(&bin_tx_buf[txState.binPtr + 4], dt1, dt1_sz);
			}
			if (dt2_sz > 0 && dt2 != NULL) {
				memcpy(&bin_tx_buf[txState.binPtr + 4 + dt1_sz], dt2, dt2_sz);
			}

			txState.binPtr += sz;
		}
		unlock();
	} else {
		ESP_LOGE(TAG, "%s:addToSend Data too big dt_sz=%d", getTaskName(), dt1_sz + dt2_sz);
	}

}

void TcpCmmTask::addToSend(uint8_t devNr, uint8_t code, const void *dt, int dt_sz) {
	addToSend2(devNr, code, dt, dt_sz, NULL, 0);
}

int TcpCmmTask::getIdx() {
	return mMyNr;
}

void TcpCmmTask::sendNow() {
	txState.sndNow = true;
}

const char* TcpCmmTask::getStrmName() {
	return getTaskName();
}

bool TcpCmmTask::isAnyToSend() {
	bool q = false;
	if (lock(3)) {
		if (txState.binPtr > 0) {
			uint32_t tt = esp_log_timestamp();
			q = txState.sndNow;
			q |= (tt - txState.firstTick > TM_DATA_MAX_IN_BUF);
			q |= (tt - txState.addTick > TM_DATA_JOIN);
		}
		unlock();
	}
	return q;
}

void TcpCmmTask::showKObj(KObj *kObj) {
	int dt_sz = kObj->objSize - sizeof(KObjHead);
	char txt[80];
	switch (dt_sz) {
	case 1:
		snprintf(txt, sizeof(txt), "B:%u", *(uint8_t*) (&kObj->data));
		break;
	case 4:
		snprintf(txt, sizeof(txt), "I:%u", *(int*) (&kObj->data));
		break;
	default:
		snprintf(txt, sizeof(txt), "dt_sz=%u", dt_sz);
		break;
	}
	ESP_LOGI(TAG, "%s: Dev=%d, Code=%d <%s>", getTaskName(), kObj->dstDev, kObj->cmmCode, txt);
}
/*
extern "C"  __WEAK   bool Layer2ProcessObj(SvrTargetStream *trg, uint8_t dstDev, uint8_t cmd, uint8_t *data, int len) {
	return false;
}
*/

extern "C" bool Layer2ProcessObj(SvrTargetStream *trg, uint8_t dstDev, uint8_t cmd, uint8_t *data, int len);

void TcpCmmTask::proceesObj(KObj *kObj) {
	bool q = false;
	int dt_sz = kObj->objSize - sizeof(KObjHead);
	if (kObj->dstDev == dsdDEV_COMMON) {
		q = DevCommonCmd::onReciveCmd(this, kObj->cmmCode, kObj->data, dt_sz);
	}
	if (!q) {
		q = Layer2ProcessObj(this, kObj->dstDev, kObj->cmmCode, kObj->data, dt_sz);
	}

	if (!q) {
		showKObj(kObj);
	}

}

bool TcpCmmTask::proceesMsg(int len) {
	mStatistic.sumaRec += len;
	//todo dorobiæ zabezpieczenie, w przypadku kiedy dwa pakiety w jeen paczcce TCP !!!!!
	if (rx_buffer[0] == STX && rx_buffer[len - 1] == ETX) {
		int bn = base64Tool->Decode(bin_rx_buf, &rx_buffer[1], len - 2);
		if (bn > 0) {
			if (mDebug > MSG_INF)
				ESP_LOGI(TAG, "%s: Rec len=%u bn=%u", getTaskName(), len, bn);
			int ptr = 0;
			while (ptr < bn) {
				KObj *kObj = (KObj*) &bin_rx_buf[ptr];
				if (mDebug > MSG_DATA)
					ESP_LOGI(TAG, "%s: KObj dDev=%u code=%u", getTaskName(), kObj->dstDev, kObj->cmmCode);
				proceesObj(kObj);
				int n = kObj->objSize;
				ptr += n;
			}
		} else {
			mStatistic.errTyp1Cnt++;
			TcpSvrTask::getGlobState()->errTyp1Cnt++;
			ESP_LOGE(TAG, "%s: RecError len=%u Base64Err", getTaskName(), len);
		}
	} else {
		if (rx_buffer[0] == STX && len < BUF_SIZE - 6) {
			ESP_LOGI(TAG, "%s: Rest=%u", getTaskName(), len);
			return true;
		} else {
			ESP_LOGE(TAG, "%s: RecError len=%u no STX-ETX", getTaskName(), len);
			mStatistic.errTyp2Cnt++;
			TcpSvrTask::getGlobState()->errTyp2Cnt++;

		}
	}
	return false;

//sendBuf_(tx_buffer, n);

}

void TcpCmmTask::zeroState() {
	memset(&mStatistic, 0, sizeof(mStatistic));
	txState.binPtr = 0;
	txState.sndNow = false;
	txState.addTick = 0;
	txState.firstTick = 0;
}

void TcpCmmTask::ThreadFunc() {
	char txt[40];

	while (1) {
		mStatistic.phase = 0x10000;
		suspendMe();
		mStatistic.phase = 0x10001;
		mStatistic.phase = 0x10002;

		inet_ntoa_r(m_svr_addr.sin_addr.s_addr, txt, sizeof(txt) - 1);
		ESP_LOGI(TAG,"%s: Start connection %s:%u", getTaskName(), txt, m_svr_addr.sin_port);

		snprintf(txt, sizeof(txt), "START:%u", mMyNr + 1);
		showLcdBigMsg(txt);
		mStatistic.phase = 0x10003;

		struct timeval tm;
		tm.tv_sec = 1;
		tm.tv_usec = 0;
		int err = setsockopt(mSock, SOL_SOCKET, SO_RCVTIMEO, &tm, sizeof(tm));
		if (err < 0) {
			ESP_LOGE(TAG, "%s: Socket unable to set socket option: errno %d", getTaskName(), errno);
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
					int len = recv(mSock, &rx_buffer[rdPtr], sizeof(rx_buffer) - rdPtr - 1, 0);
					mStatistic.phase = 0x30005;
					rx_buffer[rdPtr + len] = 0;
					if (len > 0) {
						mState.workTick = esp_log_timestamp();
						mStatistic.phase = 0x10104;
						if (!proceesMsg(rdPtr + len)) {
							rdPtr = 0;
						} else {
							rdPtr += len;
						}

						mStatistic.phase = 0x10105;
					} else {
						rdPtr = 0;
						mState.working = false;
						printf("%s: Remote closing 2", getTaskName());
					}
				}
				mStatistic.phase = 0x10106;
				if (FD_ISSET(mSock, &erds)) {
					mState.working = false;
					printf("%s: Remote closing 1", getTaskName());
				}
			}
			if (esp_log_timestamp() - txState.sendTick > TM_KEEP_ALIVE) {
				mStatistic.phase = 0x10107;
				DevCommonCmd::SendKeepAlive(this);
			}
			mStatistic.phase = 0x10108;

			if (isAnyToSend()) {
				mStatistic.phase = 0x10109;
				sendBinBuf();
			}
			mStatistic.phase = 0x1010A;

			if (esp_log_timestamp() - mState.workTick > TM_NO_CMM) {
				mState.working = false;
				printf("%s: TimeOut connection", getTaskName());

			}
		}
		mStatistic.phase = 0x1000A;
		shutdown(mSock, 0);
		close(mSock);
		mStatistic.phase = 0x1000B;
		snprintf(txt, sizeof(txt), "STOP:%u", mMyNr + 1);
		showLcdBigMsg(txt);
		mStatistic.phase = 0x1000C;
	}
}
void TcpCmmTask::showState() {
	if (mState.working) {
		char txt[20];
		inet_ntoa_r(m_svr_addr.sin_addr.s_addr, txt, sizeof(txt) - 1);
		printf("  SVR:%s:%u", txt, m_svr_addr.sin_port);
		printf("  LoopCnt:%u", mLoopCnt);
		printf("  SumaRec:%u", mStatistic.sumaRec);
		printf("  Phase  :0x%06x", mStatistic.phase);
		printf("  Smf    :%u (TaskID=%u)", txState.smf.lockID, txState.smf.lockTask);

		printf("  ErrTyp1Cnt:%u", mStatistic.errTyp1Cnt);
		printf("  ErrTyp2Cnt:%u", mStatistic.errTyp2Cnt);

	}
//printf("  Semafor:%p\n", snd_mux);
}

#if 0


TcpCmmTask::TcpCmmTask(int nr) :
		TaskClass::TaskClass("TcpCmm", 4096) {
	mMyNr = nr;
	mSock = 0;
	mWorking = false;
	mWorkTick = 0;
	snd_mux = xSemaphoreCreateMutex();
}

bool TcpCmmTask::lock() {
	return (xSemaphoreTake(snd_mux, portMAX_DELAY) == pdTRUE);
}

void TcpCmmTask::unlock() {
	xSemaphoreGive(snd_mux);
}

void TcpCmmTask::startCmm(int sock, struct sockaddr_in *svr_addr) {
	mSock = sock;
	m_svr_addr = *svr_addr;
	mWorking = true;
	mWorkTick = esp_log_timestamp();
	resumeMe();
}

void TcpCmmTask::sendBuf(const void *dt, int len) {
	if (lock()) {
		const uint8_t *buf = (const uint8_t*) dt;
		int ptr = 0;
		while (len > 0) {
			int n = send(mSock, &buf[ptr], len, 0);
			if (n < 0) {
				ESP_LOGE(getTaskName(), "Error occurred during sending: errno %d", errno);
			}
			len -= n;
		}
		unlock();
	}
}

void TcpCmmTask::proceedMsg(int len) {
	Token::remooveEOL(rx_buffer);
	int n = snprintf(tx_buffer, sizeof(tx_buffer), "Len=%u <%s>\n", len, rx_buffer);
	sendBuf(tx_buffer, n);




}

void TcpCmmTask::taskFun() {
	char txt[40];

	while (1) {
		suspendMe();

		inet_ntoa_r(m_svr_addr.sin_addr.s_addr, txt, sizeof(txt) - 1);
		ESP_LOGI(getTaskName(), "Start connection %s:%u", txt, m_svr_addr.sin_port);

		snprintf(txt, sizeof(txt), "START:%u", mMyNr + 1);
		showLcdBigMsg(txt);

		struct timeval tm;
		tm.tv_sec = 1;
		tm.tv_usec = 0;
		int err = setsockopt(mSock, SOL_SOCKET, SO_RCVTIMEO, &tm, sizeof(tm));
		if (err < 0) {
			ESP_LOGE(getTaskName(), "Socket unable to set socket option: errno %d", errno);
		}

		mLoopCnt = 0;
		while (mWorking) {
			mLoopCnt++;

			struct timeval tv;

			tv.tv_usec = 0;
			tv.tv_sec = 1;

			fd_set rfds;
			fd_set erds;

			FD_ZERO(&rfds);
			FD_ZERO(&erds);
			FD_SET(mSock, &rfds);
			FD_SET(mSock, &erds);

			int recVal = select(mSock + 1, &rfds, NULL, &erds, &tv);
			if (recVal > 0) {
/*
				if (mShowFD-- > 0) {
					printf("mSock=%d\n",mSock);
					printf("rdfs: 0x%08X 0x%08X\n", (int)rfds.fds_bits[0], (int)rfds.fds_bits[1]);
					printf("erfs: 0x%08X 0x%08X\n", (int)erds.fds_bits[0], (int)erds.fds_bits[1]);
				}
*/
				if (FD_ISSET(mSock, &rfds)) {
					int len = recv(mSock, rx_buffer, sizeof(rx_buffer) - 1, 0);
					rx_buffer[len] = 0;
					if (len > 0) {
						mWorkTick = esp_log_timestamp();
						proceedMsg(len);
					} else {
						mWorking = false;
						ESP_LOGI(getTaskName(), "Remote closing 2");
					}
				}
				if (FD_ISSET(mSock, &erds)) {
					mWorking = false;
					ESP_LOGI(getTaskName(), "Remote closing");
				}
			}
			if (esp_log_timestamp() - mWorkTick > TM_NO_CMM) {
				mWorking = false;
				shutdown(mSock, 0);
				close(mSock);
				ESP_LOGI(getTaskName(), "TimeOut connection");
			}
		}
		shutdown(mSock, 0);
		close(mSock);
		snprintf(txt, sizeof(txt), "STOP:%u", mMyNr + 1);
		showLcdBigMsg(txt);
	}
}
void TcpCmmTask::showState() {
	if (mWorking) {
		char txt[20];
		inet_ntoa_r(m_svr_addr.sin_addr.s_addr, txt, sizeof(txt) - 1);
		printf("  SVR:%s:%u\n", txt, m_svr_addr.sin_port);
		printf("  LoopCnt:%u\n", mLoopCnt);

	} else {
		printf("  Free\n");
	}
	//printf("  Semafor:%p\n", snd_mux);
}
#endif
//----------------------------------------------------------------------------------------------
//  TcpSvrTask
//----------------------------------------------------------------------------------------------
TcpSvrTask *TcpSvrTask::me;

TcpSvrTask::TcpSvrTask() :
		TaskClass::TaskClass("TcpSvr", 4096) {
	me =this;
	for (int i = 0; i < CMM_CNT; i++) {
		mCmmTab[i] = new TcpCmmTask(i);
		char name[8];
		snprintf(name, sizeof(name), "CMM_%u", i + 1);
		mCmmTab[i]->setTaskName(name);
	}
}

void TcpSvrTask::start() {

	for (int i = 0; i < CMM_CNT; i++) {
		mCmmTab[i]->start();
	}
	TaskClass::start();
}

int TcpSvrTask::findUnoccupatedCmm() {
	int idx = -1;
	for (int i = 0; i < CMM_CNT; i++) {
		if (!mCmmTab[i]->isWorking()) {
			idx = i;
			break;
		}
	}
	return idx;
}

void TcpSvrTask::addToSendNow(uint8_t devNr, uint8_t code, const void *dt, int dt_sz) {
	for (int i = 0; i < CMM_CNT; i++) {
		if (mCmmTab[i]->isWorking()) {
			mCmmTab[i]->addToSend(devNr, code, dt, dt_sz);
			mCmmTab[i]->sendNow();
		}
	}
}

void TcpSvrTask::addToSend(uint8_t devNr, uint8_t code, const void *dt, int dt_sz) {
	for (int i = 0; i < CMM_CNT; i++) {
		if (mCmmTab[i]->isWorking()) {
			mCmmTab[i]->addToSend(devNr, code, dt, dt_sz);
		}
	}
}

void TcpSvrTask::addToSend(uint8_t devNr, uint8_t code, const char *txt) {
	addToSend(devNr, code, (uint8_t*) txt, strlen(txt));
}


void TcpSvrTask::ThreadFunc() {
	xEventGroupWaitBits(main_ev_group, MN_BIT_NET_RDY, pdFALSE, pdFALSE, portMAX_DELAY);
	printf("TcpSvrTask\n");

	int err = 0;

	struct sockaddr_in6 dest_addr;
	struct sockaddr_in *dest_addr_ip4 = (struct sockaddr_in*) &dest_addr;
	dest_addr_ip4->sin_addr.s_addr = htonl(INADDR_ANY);
	dest_addr_ip4->sin_family = AF_INET;
	dest_addr_ip4->sin_port = htons(PORT);

	int listen_sock = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
	if (listen_sock < 0) {
		ESP_LOGE(TAG, "Unable to create socket: errno %d", errno);
		goto CLEAN_UP_1;
	}

	err = bind(listen_sock, (struct sockaddr*) &dest_addr, sizeof(dest_addr));
	if (err != 0) {
		ESP_LOGE(TAG, "Socket unable to bind: errno %d", errno);
		goto CLEAN_UP_2;
	}
	ESP_LOGI(TAG, "Socket bound, port %d", PORT);

	err = listen(listen_sock, 1);
	if (err != 0) {
		ESP_LOGE(TAG, "Error occurred during listen: errno %d", errno);
		goto CLEAN_UP_2;
	}
	while (1) {
		ESP_LOGI(TAG, "Socket listening");

		struct sockaddr_in source_addr; // Large enough for both IPv4 or IPv6
		uint addr_len = sizeof(source_addr);
		int sock = accept(listen_sock, (struct sockaddr*) &source_addr, &addr_len);
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

bool TcpSvrTask::menu(char ch) {
	switch (ch) {
	case 's':
		for (int i = 0; i < CMM_CNT; i++) {
			printf("SVR_%u\n", i);
			mCmmTab[i]->showState();
		}
		break;
	case 27:
		return true;
	default:
		printf("____CmmSvr menu____\n"
				"s - show state\n"
				"a,b - send All\n"

		);
	}
	return false;
}

