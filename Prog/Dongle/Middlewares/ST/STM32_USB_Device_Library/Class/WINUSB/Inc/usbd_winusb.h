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


#define CDC_IN_EP                                   0x81U  /* EP1 for data IN */
#define CDC_OUT_EP                                  0x01U  /* EP1 for data OUT */
#define CDC_CMD_EP                                  0x82U  /* EP2 for CDC commands */

#ifndef CDC_HS_BINTERVAL
#define CDC_HS_BINTERVAL                          0x10U
#endif /* CDC_HS_BINTERVAL */

#ifndef CDC_FS_BINTERVAL
#define CDC_FS_BINTERVAL                          0x10U
#endif /* CDC_FS_BINTERVAL */

/* CDC Endpoints parameters: you can fine tune these values depending on the needed baudrates and performance. */
#define CDC_DATA_HS_MAX_PACKET_SIZE                 512U  /* Endpoint IN & OUT Packet size */
#define CDC_DATA_FS_MAX_PACKET_SIZE                 64U  /* Endpoint IN & OUT Packet size */
#define CDC_CMD_PACKET_SIZE                         8U  /* Control Endpoint Packet size */

#define USB_CDC_CONFIG_DESC_SIZ                     67U
#define CDC_DATA_HS_IN_PACKET_SIZE                  CDC_DATA_HS_MAX_PACKET_SIZE
#define CDC_DATA_HS_OUT_PACKET_SIZE                 CDC_DATA_HS_MAX_PACKET_SIZE

#define CDC_DATA_FS_IN_PACKET_SIZE                  CDC_DATA_FS_MAX_PACKET_SIZE
#define CDC_DATA_FS_OUT_PACKET_SIZE                 CDC_DATA_FS_MAX_PACKET_SIZE

/*---------------------------------------------------------------------*/
/*  CDC definitions                                                    */
/*---------------------------------------------------------------------*/
#define CDC_SEND_ENCAPSULATED_COMMAND               0x00U
#define CDC_GET_ENCAPSULATED_RESPONSE               0x01U
#define CDC_SET_COMM_FEATURE                        0x02U
#define CDC_GET_COMM_FEATURE                        0x03U
#define CDC_CLEAR_COMM_FEATURE                      0x04U
#define CDC_SET_LINE_CODING                         0x20U
#define CDC_GET_LINE_CODING                         0x21U
#define CDC_SET_CONTROL_LINE_STATE                  0x22U
#define CDC_SEND_BREAK                              0x23U

/**
  * @}
  */



typedef struct 
{
  int8_t (* Init)(void);
  int8_t (* DeInit)(void);
  int8_t (* Control)(uint8_t cmd, uint8_t *pbuf, uint16_t length);
  int8_t (* Receive)(uint8_t *Buf, uint32_t *Len);

} USBD_WINUSB_ItfTypeDef;


typedef struct
{
  uint32_t data[CDC_DATA_HS_MAX_PACKET_SIZE / 4U];      /* Force 32bits alignment */
  uint8_t  CmdOpCode;
  uint8_t  CmdLength;
  uint8_t  *RxBuffer;
  uint8_t  *TxBuffer;
  uint32_t RxLength;
  uint32_t TxLength;

  __IO uint32_t TxState;
  __IO uint32_t RxState;
}
USBD_WINUSB_HandleTypeDef;




extern USBD_ClassTypeDef  USBD_WINUSB;
#define USBD_WINUSB_CLASS    &USBD_WINUSB

uint8_t  USBD_WINUSB_RegisterInterface(USBD_HandleTypeDef   *pdev,
                                    USBD_WINUSB_ItfTypeDef *fops);

uint8_t  USBD_WINUSB_SetTxBuffer(USBD_HandleTypeDef   *pdev,
                              uint8_t  *pbuff,
                              uint16_t length);

uint8_t  USBD_WINUSB_SetRxBuffer(USBD_HandleTypeDef   *pdev,
                              uint8_t  *pbuff);

uint8_t  USBD_WINUSB_ReceivePacket(USBD_HandleTypeDef *pdev);

uint8_t  USBD_WINUSB_TransmitPacket(USBD_HandleTypeDef *pdev);

#endif
