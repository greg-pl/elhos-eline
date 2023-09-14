/******************** (C) COPYRIGHT 2011 STMicroelectronics ********************
* File Name          : usb_desc.h
* Author             : MCD Application Team
* Version            : V3.3.0
* Date               : 21-March-2011
* Description        : Descriptor Header for Custom HID Demo
********************************************************************************
* THE PRESENT FIRMWARE WHICH IS FOR GUIDANCE ONLY AIMS AT PROVIDING CUSTOMERS
* WITH CODING INFORMATION REGARDING THEIR PRODUCTS IN ORDER FOR THEM TO SAVE TIME.
* AS A RESULT, STMICROELECTRONICS SHALL NOT BE HELD LIABLE FOR ANY DIRECT,
* INDIRECT OR CONSEQUENTIAL DAMAGES WITH RESPECT TO ANY CLAIMS ARISING FROM THE
* CONTENT OF SUCH FIRMWARE AND/OR THE USE MADE BY CUSTOMERS OF THE CODING
* INFORMATION CONTAINED HEREIN IN CONNECTION WITH THEIR PRODUCTS.
*******************************************************************************/

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __USB_DESC_H
#define __USB_DESC_H

/* Includes ------------------------------------------------------------------*/
/* Exported types ------------------------------------------------------------*/
typedef struct
{
// Header
uint32_t dwLength;
uint16_t  bcdVersion;
uint16_t  wIndex;
uint8_t  bCount;
uint8_t  bReserved1[7];
// Function Section 1
uint8_t  bFirstInterfaceNumber;
uint8_t  bReserved2;
uint8_t  bCompatibleID[8];
uint8_t  bSubCompatibleID[8];
uint8_t  bReserved3[6];
} USBD_CompatIDDescStruct;

typedef struct
{
// Header
uint32_t dwLength;
uint16_t  bcdVersion;
uint16_t  wIndex;
uint16_t  wCount;
// Custom Property Section 1
uint32_t dwSize;
uint32_t dwPropertyDataType;
uint16_t  wPropertyNameLength;
uint16_t  bPropertyName[20];
uint32_t dwPropertyDataLength;
uint16_t  bPropertyData[39];
} USBD_ExtPropertiesDescStruct;
/* Exported constants --------------------------------------------------------*/
/* Exported macro ------------------------------------------------------------*/
/* Exported define -----------------------------------------------------------*/
#define USB_DEVICE_DESCRIPTOR_TYPE              0x01
#define USB_CONFIGURATION_DESCRIPTOR_TYPE       0x02
#define USB_STRING_DESCRIPTOR_TYPE              0x03
#define USB_INTERFACE_DESCRIPTOR_TYPE           0x04
#define USB_ENDPOINT_DESCRIPTOR_TYPE            0x05

#define HID_DESCRIPTOR_TYPE                     0x21
#define CUSTOMHID_SIZ_HID_DESC                  0x09
#define CUSTOMHID_OFF_HID_DESC                  0x12

#define CUSTOMHID_SIZ_DEVICE_DESC               18
#define CUSTOMHID_SIZ_CONFIG_DESC               41
#define CUSTOMHID_SIZ_REPORT_DESC               163
#define CUSTOMHID_SIZ_STRING_LANGID             4
#define CUSTOMHID_SIZ_STRING_VENDOR             38
#define CUSTOMHID_SIZ_STRING_PRODUCT            32
#define CUSTOMHID_SIZ_STRING_SERIAL             26
#define CUSTOMHID_SIZ_STRING_WINUSB				18 //0x12
#define	USB_REQ_GET_OS_FEATURE_DESCRIPTOR		0x20
#define OS_STRING_LENGTH 8
 

#define STANDARD_ENDPOINT_DESC_SIZE             0x09

/* Exported functions ------------------------------------------------------- */
extern const uint8_t CustomHID_DeviceDescriptor[CUSTOMHID_SIZ_DEVICE_DESC];
extern const uint8_t CustomHID_ConfigDescriptor[CUSTOMHID_SIZ_CONFIG_DESC];
extern const uint8_t CustomHID_ReportDescriptor[CUSTOMHID_SIZ_REPORT_DESC];
extern const uint8_t CustomHID_StringLangID[CUSTOMHID_SIZ_STRING_LANGID];
extern const uint8_t CustomHID_StringVendor[CUSTOMHID_SIZ_STRING_VENDOR];
extern const uint8_t CustomHID_StringProduct[CUSTOMHID_SIZ_STRING_PRODUCT];
extern uint8_t CustomHID_StringSerial[CUSTOMHID_SIZ_STRING_SERIAL];
extern uint8_t CustomHID_StringWinUSB[CUSTOMHID_SIZ_STRING_WINUSB];
extern USBD_CompatIDDescStruct USBD_CompatIDDesc;
extern USBD_ExtPropertiesDescStruct USBD_ExtPropertiesDesc;
#endif /* __USB_DESC_H */

/******************* (C) COPYRIGHT 2011 STMicroelectronics *****END OF FILE****/
