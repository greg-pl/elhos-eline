/*
 * UdpScanRec.cpp
 *
 *  Created on: 7 kwi 2021
 *      Author: Grzegorz
 */

#include "esp_event.h"
#include "esp_log.h"

#include "UdpScanTask.h"
#include "UMain.h"
#include "Token.h"
#include "MyConfig.h"
#include "UMain.h"
#include "Shell.h"

extern MyConfig *myConfig;

#define PORT 8001

static const char *TAG = "UDP_SCAN";

UdpScanTask::UdpScanTask() :
		TaskClass::TaskClass("UdpScan", 4096) {

}


void UdpScanTask::replyUdp(int sock, struct sockaddr_in *src_addr, const char *buf, int len) {
	char replay[200];
	replay[0] = 0;

	if (len > 0) {
		const char *ptr = buf;
		char serNum[SIZE_SERIAL_NR];

		Token::get(&ptr, serNum, sizeof(serNum));
		bool nrSerOK = (strcmp(myConfig->cfg.serNumTxt, serNum) == 0);

		int fun;
		if (Token::getAsInt(&ptr, &fun)) {
			switch (fun) {
			case 1: {
				char bb1[20];
				char bb2[20];
				char bb3[20];

				ipToStr(bb1, devState.wifinetInfo.ip);
				ipToStr(bb2, devState.wifinetInfo.netmask);
				ipToStr(bb3, devState.wifinetInfo.gw);

				snprintf(replay, sizeof(replay), "%s 0 %15s %15s %15s %s", myConfig->cfg.serNumTxt, bb1, bb2, bb3, myConfig->cfg.devID);
				ESP_LOGI(TAG, "Hello");
			}
				break;
			case 6: {
				char cmd[20];
				Token::get(&ptr, cmd, sizeof(cmd));
				if (strcmp(cmd, "FIND") == 0) {
					snprintf(replay, sizeof(replay), "%s 6 INTRO %s %s", myConfig->cfg.serNumTxt, myConfig->getDevTypeName(), myConfig->cfg.devID);
					ESP_LOGI(TAG, "Find");
					showLcdBigMsg("NET_PING");
				} else if (strcmp(cmd, "REBOOT") == 0) {
					if (nrSerOK) {
						ESP_LOGI(TAG, "Reboot");
						snprintf(replay, sizeof(replay), "%s 6 REBOOTING", myConfig->cfg.serNumTxt);
						restartMe(1000);
					} else {
						ESP_LOGI(TAG, "Reboot not ME");
					}
				}
			}
				break;

			}

		}
	}
	if (replay[0]) {
		//wysy³anie odpowiedzi
		struct sockaddr_in dest_addr;
		dest_addr.sin_addr.s_addr = src_addr->sin_addr.s_addr;
		dest_addr.sin_family = AF_INET;
		dest_addr.sin_port = src_addr->sin_port;

		int err = sendto(sock, replay, strlen(replay), 0, (struct sockaddr*) &dest_addr, sizeof(dest_addr));
		if (err < 0) {
			ESP_LOGE(TAG, "Error occurred during sending: errno %d", errno);
		} else {
			ESP_LOGI(TAG, "Message sent");
		}
	}
}

void UdpScanTask::ThreadFunc() {

	char rx_buffer[128];

	xEventGroupWaitBits(main_ev_group, MN_BIT_NET_RDY, pdFALSE, pdFALSE, portMAX_DELAY);
	printf("UdpScanTask\n");

	int sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
	if (sock < 0) {
		ESP_LOGE(TAG, "Unable to create socket: errno %d", errno);
	}
	ESP_LOGI(TAG, "Socket created, port:%d", PORT);

	struct sockaddr_in dest_addr;
	dest_addr.sin_addr.s_addr = htonl(INADDR_ANY);
	dest_addr.sin_family = AF_INET;
	dest_addr.sin_port = htons(PORT);

	int err = bind(sock, (struct sockaddr*) &dest_addr, sizeof(dest_addr));
	if (err < 0) {
		ESP_LOGE(TAG, "Socket unable to bind: errno %d", errno);
	}

	struct timeval tm;
	tm.tv_sec = 0;
	tm.tv_usec = 1000 * 500;
	err = setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &tm, sizeof(tm));
	if (err < 0) {
		ESP_LOGE(TAG, "Socket unable to set socket option: errno %d", errno);
	}

	while (1) {
		struct sockaddr_in source_addr;
		socklen_t socklen = sizeof(source_addr);
		int len = recvfrom(sock, rx_buffer, sizeof(rx_buffer) - 1, 0, (struct sockaddr*) &source_addr, &socklen);

		if (len > 0) {
// Data received
			rx_buffer[len] = 0; // Null-terminate whatever we received and treat like a string

			ip4_addr_t ip4addr;
			ip4addr.addr = source_addr.sin_addr.s_addr;
			char ip_txt[20];
			inet_ntoa_r(ip4addr, ip_txt, sizeof(ip_txt));

			ESP_LOGI(TAG, "Received %d bytes from %s:%d:", len, ip_txt, source_addr.sin_port);
			ESP_LOGI(TAG, "%s", rx_buffer);
			fflush(stdout);

			replyUdp(sock, &source_addr, rx_buffer, len);
		}

	}
}
