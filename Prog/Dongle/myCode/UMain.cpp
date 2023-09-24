/*
 * UMain.cpp
 *
 *  Created on: 20 maj 2021
 *      Author: Grzegorz
 */
#include "stddef.h"
#include "stdint.h"
#include "stdio.h"
#include "string.h"

#include "usbd_winusb_if.h"

#include "main.h"
#include "UMain.h"
#include "dbgUart.h"

extern "C" void setLed1(uint8_t q) {
	if (q)
		HAL_GPIO_WritePin(LED1_GPIO_Port, LED1_Pin, GPIO_PIN_RESET);
	else
		HAL_GPIO_WritePin(LED1_GPIO_Port, LED1_Pin, GPIO_PIN_SET);
}

extern "C" void setLed2(uint8_t q) {
	if (q)
		HAL_GPIO_WritePin(LED2_GPIO_Port, LED2_Pin, GPIO_PIN_RESET);
	else
		HAL_GPIO_WritePin(LED2_GPIO_Port, LED2_Pin, GPIO_PIN_SET);
}

extern "C" void usbOn(uint8_t q) {
	if (q)
		HAL_GPIO_WritePin(USB_ON_GPIO_Port, USB_ON_Pin, GPIO_PIN_RESET);
	else
		HAL_GPIO_WritePin(USB_ON_GPIO_Port, USB_ON_Pin, GPIO_PIN_SET);
}

extern "C" void initCubeSys();

extern "C" int _write(int file, char *ptr, int len) {
	DbgUart::Write(ptr, len);
	return len;
}

extern "C" int __io_putchar(int ch) {
	DbgUart::Write((const char*) &ch, 1);
	return 1;
}

int RecPacketCnt;
extern "C" void onWINUSB_ReceivePacket(char *Buf, int Len) {
	/*
	int n = Len;
	if (n > 16)
		n = 16;
	printf("RecData n=%u: ", (int) Len);
	for (int i = 0; i < 16; i++) {
		printf("%02X ", Buf[i]);
	}
	printf("\r\n");

	char sndTxt[100];
	int m = snprintf(sndTxt,sizeof(sndTxt),"Odebrano %u bytes",Len);
	WINUSB_SendData(sndTxt, m);
	*/
	WINUSB_SendData(Buf,Len);
	RecPacketCnt++;

}

char TxData[200];

extern "C" void main2(void) {
	initCubeSys();
	setLed2(0);
	DbgUart::Init(115200);
	//DbgUart::WriteStr("\r\neLine-DONGLE\r\n----------------------------------\r\n");

	printf("\r\neLine-DONGLE_2\r\n----------------------------------\r\n");

	HAL_Delay(250);
	usbOn(1);

	uint32_t led_tt = HAL_GetTick();

	bool led2 = false;
	int v = 0;
	while (1) {
		uint32_t tt = HAL_GetTick();
		if (tt - led_tt > 1000) {
			led_tt = tt;
			led2 = !led2;
			setLed1(led2);

			printf("RecPacketCnt=%u\r\n", RecPacketCnt);
			fflush(stdout);

			WINUSB_LogPrint("RecPacketCnt=%u\n",RecPacketCnt);

		}
	}

}
