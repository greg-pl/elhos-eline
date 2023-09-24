/* USER CODE BEGIN Header */
/**
 ******************************************************************************
 * @file           : usbd_cdc_if.h
 * @version        : GeKa
 ******************************************************************************
 */

#ifndef __USBD_WINUSB_IF_H__
#define __USBD_WINUSB_IF_H__

#ifdef __cplusplus
extern "C" {
#endif

#include "usbd_winusb.h"

extern USBD_WINUSB_ItfTypeDef USBD_WINUSB_Interface_fops_FS;

uint8_t WINUSB_SendData(const void *Buf, uint16_t Len);

#if (LOGGER_PIPE == 1)
uint8_t WINUSB_LogBuf(const void *Buf, uint16_t Len);
uint8_t WINUSB_LogStr(const char *txt);
uint8_t WINUSB_LogPrint(const char *txt, ...);
#endif

#ifdef __cplusplus
}
#endif

#endif

