/**
 ******************************************************************************
 * @file    usbd_winusb.h
 * @author  GeKa
 * @brief   header file for the usbd_winusb.c file.
 ******************************************************************************
 */

#ifndef __USB_WINUSB_H
#define __USB_WINUSB_H

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include  "usbd_ioreq.h"

#define LOGGER_PIPE  1

#define WINUSB_IN_EP                                   0x81U  // EP1 for data IN
#define WINUSB_OUT_EP                                  0x01U  // EP1 for data OUT
#if(LOGGER_PIPE==1)
#define WINUSB_LOGGER_EP                                  0x82U  // EP2 for WINUSB logger
#endif

/* CDC Endpoints parameters: you can fine tune these values depending on the needed baudrates and performance. */
#define WINUSB_DATA_HS_MAX_PACKET_SIZE                 512U  /* Endpoint IN & OUT Packet size */
#define WINUSB_DATA_FS_MAX_PACKET_SIZE                 64U  /* Endpoint IN & OUT Packet size */
#define WINUSB_LOG_PACKET_SIZE                         64U  /* Log Endpoint Packet size */

#define USB_CDC_CONFIG_DESC_SIZ                     67U
#define WINUSB_DATA_HS_IN_PACKET_SIZE                  WINUSB_DATA_HS_MAX_PACKET_SIZE
#define WINUSB_DATA_HS_OUT_PACKET_SIZE                 WINUSB_DATA_HS_MAX_PACKET_SIZE

#define WINUSB_DATA_FS_IN_PACKET_SIZE                  WINUSB_DATA_FS_MAX_PACKET_SIZE
#define WINUSB_DATA_FS_OUT_PACKET_SIZE                 WINUSB_DATA_FS_MAX_PACKET_SIZE

typedef struct {
	int8_t (*Init)(void);
	int8_t (*DeInit)(void);
	int8_t (*Control)(uint8_t cmd, uint8_t *pbuf, uint16_t length);
	int8_t (*Receive)(uint8_t *Buf, uint32_t *Len);

} USBD_WINUSB_ItfTypeDef;

typedef struct {
	uint32_t data[WINUSB_DATA_HS_MAX_PACKET_SIZE / 4U]; /* Force 32bits alignment */
	uint8_t CmdOpCode;
	uint8_t CmdLength;
	uint8_t *RxBuffer;
	uint32_t RxLength;

	uint8_t *TxBuffer;
	uint32_t TxLength;
	__IO uint32_t TxState;

	__IO uint32_t RxState;
#if (LOGGER_PIPE == 1)
	uint8_t *LogBuffer;
	uint32_t LogLength;
	__IO uint32_t LogState;
#endif
} USBD_WINUSB_HandleTypeDef;

extern USBD_ClassTypeDef USBD_WINUSB;
#define USBD_WINUSB_CLASS    &USBD_WINUSB

uint8_t USBD_WINUSB_RegisterInterface(USBD_HandleTypeDef *pdev, USBD_WINUSB_ItfTypeDef *fops);

uint8_t USBD_WINUSB_SetTxDataBuffer(USBD_HandleTypeDef *pdev, const void *pbuff, uint16_t length);

uint8_t USBD_WINUSB_SetRxBuffer(USBD_HandleTypeDef *pdev, uint8_t *pbuff);

uint8_t USBD_WINUSB_ReceivePacket(USBD_HandleTypeDef *pdev);

uint8_t USBD_WINUSB_TransmitDataPacket(USBD_HandleTypeDef *pdev);

#if (LOGGER_PIPE == 1)
uint8_t USBD_WINUSB_SetTxLogBuffer(USBD_HandleTypeDef *pdev, const void *pbuff, uint16_t length);
uint8_t USBD_WINUSB_TransmitLogPacket(USBD_HandleTypeDef *pdev);
#endif

#ifdef __cplusplus
}
#endif

#endif
