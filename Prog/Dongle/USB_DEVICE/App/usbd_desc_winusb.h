/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : usbd_desc.c
  * @version        : GeKa
  ******************************************************************************
*/
#ifndef __USBD_WINUSB_DESC__C__
#define __USBD_WINUSB_DESC__C__

#ifdef __cplusplus
 extern "C" {
#endif

#include "usbd_def.h"

#define         DEVICE_ID1          (UID_BASE)
#define         DEVICE_ID2          (UID_BASE + 0x4)
#define         DEVICE_ID3          (UID_BASE + 0x8)

#define  USB_SIZ_STRING_SERIAL       0x1A

extern USBD_DescriptorsTypeDef FS_Desc_WinUsb;

#ifdef __cplusplus
}
#endif

#endif

