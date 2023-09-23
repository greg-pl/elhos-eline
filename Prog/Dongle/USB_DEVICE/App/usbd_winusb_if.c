/**
 ******************************************************************************
 * @file           : usbd_winusb_if.c
 * @version        : GeKa
 ******************************************************************************
 */

#include "usbd_winusb_if.h"

#define APP_RX_DATA_SIZE  512
#define APP_TX_DATA_SIZE  512

uint8_t WinUsbRxBufferFS[APP_RX_DATA_SIZE];
uint8_t WinUsbTxBufferFS[APP_TX_DATA_SIZE];


extern USBD_HandleTypeDef hUsbDeviceFS;


static int8_t WINUSB_Init_FS(void);
static int8_t WINUSB_DeInit_FS(void);
static int8_t WINUSB_Control_FS(uint8_t cmd, uint8_t* pbuf, uint16_t length);
static int8_t WINUSB_Receive_FS(uint8_t* pbuf, uint32_t* Len);

void onWINUSB_ReceivePacket(char* Buf, int Len);

USBD_WINUSB_ItfTypeDef USBD_WINUSB_Interface_fops_FS =
{
  WINUSB_Init_FS,
  WINUSB_DeInit_FS,
  WINUSB_Control_FS,
  WINUSB_Receive_FS
};


static int8_t WINUSB_Init_FS(void)
{
  USBD_WINUSB_SetTxBuffer(&hUsbDeviceFS, WinUsbTxBufferFS, 0);
  USBD_WINUSB_SetRxBuffer(&hUsbDeviceFS, WinUsbRxBufferFS);
  return (USBD_OK);
}

static int8_t WINUSB_DeInit_FS(void)
{
  return (USBD_OK);
}

static int8_t WINUSB_Control_FS(uint8_t cmd, uint8_t* pbuf, uint16_t length)
{
  switch (cmd) {
  case CDC_SEND_ENCAPSULATED_COMMAND:

    break;

  case CDC_GET_ENCAPSULATED_RESPONSE:

    break;

  case CDC_SET_COMM_FEATURE:

    break;

  case CDC_GET_COMM_FEATURE:

    break;

  case CDC_CLEAR_COMM_FEATURE:

    break;

    /*******************************************************************************/
    /* Line Coding Structure                                                       */
    /*-----------------------------------------------------------------------------*/
    /* Offset | Field       | Size | Value  | Description                          */
    /* 0      | dwDTERate   |   4  | Number |Data terminal rate, in bits per second*/
    /* 4      | bCharFormat |   1  | Number | Stop bits                            */
    /*                                        0 - 1 Stop bit                       */
    /*                                        1 - 1.5 Stop bits                    */
    /*                                        2 - 2 Stop bits                      */
    /* 5      | bParityType |  1   | Number | Parity                               */
    /*                                        0 - None                             */
    /*                                        1 - Odd                              */
    /*                                        2 - Even                             */
    /*                                        3 - Mark                             */
    /*                                        4 - Space                            */
    /* 6      | bDataBits  |   1   | Number Data bits (5, 6, 7, 8 or 16).          */
    /*******************************************************************************/
  case CDC_SET_LINE_CODING:

    break;

  case CDC_GET_LINE_CODING:

    break;

  case CDC_SET_CONTROL_LINE_STATE:

    break;

  case CDC_SEND_BREAK:

    break;

  default:
    break;
  }

  return (USBD_OK);
}

static int8_t WINUSB_Receive_FS(uint8_t* Buf, uint32_t* Len)
{
  USBD_WINUSB_SetRxBuffer(&hUsbDeviceFS, &Buf[0]);
  USBD_WINUSB_ReceivePacket(&hUsbDeviceFS);
  onWINUSB_ReceivePacket((char*)Buf, *Len);
  return (USBD_OK);
}

uint8_t WINUSB_Transmit_FS(uint8_t* Buf, uint16_t Len)
{
  uint8_t result = USBD_OK;
  USBD_WINUSB_HandleTypeDef* hcdc = (USBD_WINUSB_HandleTypeDef*)hUsbDeviceFS.pClassData;

  if (hcdc->TxState != 0) {
    return USBD_BUSY;
  }
  USBD_WINUSB_SetTxBuffer(&hUsbDeviceFS, Buf, Len);
  result = USBD_WINUSB_TransmitPacket(&hUsbDeviceFS);
  return result;
}


__attribute__((weak)) void onWINUSB_ReceivePacket(char* Buf, int Len) {

}

