/**
 ******************************************************************************
 * @file           : usbd_winusb_if.c
 * @version        : GeKa
 ******************************************************************************
 */

#include "usbd_winusb_if.h"
#include "stdarg.h"

#define APP_RX_DATA_SIZE  512
#define APP_TX_DATA_SIZE  512

uint8_t WinUsbRxBufferFS[APP_RX_DATA_SIZE];
uint8_t WinUsbTxBufferFS[APP_TX_DATA_SIZE];

extern USBD_HandleTypeDef hUsbDeviceFS;

static int8_t WINUSB_Init_FS(void);
static int8_t WINUSB_DeInit_FS(void);
static int8_t WINUSB_Control_FS(uint8_t cmd, uint8_t *pbuf, uint16_t length);
static int8_t WINUSB_Receive_FS(uint8_t *pbuf, uint32_t *Len);

void onWINUSB_ReceivePacket(char *Buf, int Len);

USBD_WINUSB_ItfTypeDef USBD_WINUSB_Interface_fops_FS = { WINUSB_Init_FS, WINUSB_DeInit_FS, WINUSB_Control_FS, WINUSB_Receive_FS };

static int8_t WINUSB_Init_FS(void) {
	USBD_WINUSB_SetRxBuffer(&hUsbDeviceFS, WinUsbRxBufferFS);
	USBD_WINUSB_SetTxDataBuffer(&hUsbDeviceFS, WinUsbTxBufferFS, 0);
	return (USBD_OK);
}

static int8_t WINUSB_DeInit_FS(void) {
	return (USBD_OK);
}

static int8_t WINUSB_Control_FS(uint8_t cmd, uint8_t *pbuf, uint16_t length) {
	printf("WINUSB_Control_FS cmd=%u, len=%u\r\n", cmd, length);
	return (USBD_OK);
}

static int8_t WINUSB_Receive_FS(uint8_t *Buf, uint32_t *Len) {
	USBD_WINUSB_SetRxBuffer(&hUsbDeviceFS, &Buf[0]);
	USBD_WINUSB_ReceivePacket(&hUsbDeviceFS);
	onWINUSB_ReceivePacket((char*) Buf, *Len);
	return (USBD_OK);
}

uint8_t WINUSB_SendData(const void *Buf, uint16_t Len) {
	uint8_t result = USBD_OK;
	USBD_WINUSB_HandleTypeDef *hcdc = (USBD_WINUSB_HandleTypeDef*) hUsbDeviceFS.pClassData;

	if (hcdc->TxState != 0) {
		return USBD_BUSY;
	}
	USBD_WINUSB_SetTxDataBuffer(&hUsbDeviceFS, Buf, Len);
	result = USBD_WINUSB_TransmitDataPacket(&hUsbDeviceFS);
	return result;
}

#if (LOGGER_PIPE == 1)
uint8_t WINUSB_LogBuf(const void *Buf, uint16_t Len) {
	uint8_t result = USBD_OK;
	USBD_WINUSB_HandleTypeDef *hcdc = (USBD_WINUSB_HandleTypeDef*) hUsbDeviceFS.pClassData;

	if (hcdc->LogState != 0) {
		return USBD_BUSY;
	}
	USBD_WINUSB_SetTxLogBuffer(&hUsbDeviceFS, Buf, Len);
	result = USBD_WINUSB_TransmitLogPacket(&hUsbDeviceFS);
	return result;
}

uint8_t WINUSB_SendLogStr(const char *txt) {
	return WINUSB_LogBuf(txt, strlen(txt));
}
uint8_t WINUSB_LogPrint(const char *txt, ...) {
	char buffer[100];
	va_list argList;
	va_start(argList, txt);
	int n = vsnprintf(buffer, sizeof(buffer), txt, argList);
	va_end(argList);
	return WINUSB_LogBuf(buffer,n);
}

#endif

__attribute__((weak)) void onWINUSB_ReceivePacket(char *Buf, int Len) {

}

