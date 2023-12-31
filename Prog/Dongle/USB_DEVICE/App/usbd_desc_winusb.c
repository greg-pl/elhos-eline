/**
  ******************************************************************************
  * @file           : App/usbd_desc.c
  * @version        : GeKa
  ******************************************************************************
*/
#include "stdint.h"
#include "usbd_conf.h"
#include "usbd_core.h"
#include "usbd_desc.h"
#include "usbd_conf.h"


#define USBD_VID                      0x4701
#define USBD_PID_FS                   0x0295
#define USBD_LANGID_STRING            1033
#define USBD_MANUFACTURER_STRING      "GEKA"
#define USBD_PRODUCT_STRING_FS        "eLine Dongle"
#define USBD_SERIALNUMBER_STRING_FS   "00000000001A"
#define USBD_CONFIGURATION_STRING_FS  "WINUSB Config"
#define USBD_INTERFACE_STRING_FS      "WINUSB Interface"


static void Get_SerialNum(void);
static void IntToUnicode(uint32_t value, uint8_t* pbuf, uint8_t len);


static uint8_t* USBD_FS_DeviceDescriptor(USBD_SpeedTypeDef speed, uint16_t* length);
static uint8_t* USBD_FS_LangIDStrDescriptor(USBD_SpeedTypeDef speed, uint16_t* length);
static uint8_t* USBD_FS_ManufacturerStrDescriptor(USBD_SpeedTypeDef speed, uint16_t* length);
static uint8_t* USBD_FS_ProductStrDescriptor(USBD_SpeedTypeDef speed, uint16_t* length);
static uint8_t* USBD_FS_SerialStrDescriptor(USBD_SpeedTypeDef speed, uint16_t* length);
static uint8_t* USBD_FS_ConfigStrDescriptor(USBD_SpeedTypeDef speed, uint16_t* length);
static uint8_t* USBD_FS_InterfaceStrDescriptor(USBD_SpeedTypeDef speed, uint16_t* length);

static uint8_t* USBD_WinUSBOSStrDescriptor(uint16_t* length);
static uint8_t* USBD_WinUSBOSFeatureDescriptor(uint16_t* length);
static uint8_t* USBD_WinUSBOSPropertyDescriptor(uint16_t* length);


USBD_DescriptorsTypeDef FS_Desc_WinUsb =
{
  USBD_FS_DeviceDescriptor
, USBD_FS_LangIDStrDescriptor
, USBD_FS_ManufacturerStrDescriptor
, USBD_FS_ProductStrDescriptor
, USBD_FS_SerialStrDescriptor
, USBD_FS_ConfigStrDescriptor
, USBD_FS_InterfaceStrDescriptor

, USBD_WinUSBOSFeatureDescriptor
, USBD_WinUSBOSPropertyDescriptor

};


static __ALIGN_BEGIN uint8_t USBD_FS_DeviceDesc[USB_LEN_DEV_DESC] __ALIGN_END =
{
  0x12,                       /*bLength */
  USB_DESC_TYPE_DEVICE,       /*bDescriptorType*/
  0x00,                       /*bcdUSB */
  0x02,
  0x00,                       /*bDeviceClass*/
  0x00,                       /*bDeviceSubClass*/
  0x00,                       /*bDeviceProtocol*/
  USB_MAX_EP0_SIZE,           /*bMaxPacketSize*/
  LOBYTE(USBD_VID),           /*idVendor*/
  HIBYTE(USBD_VID),           /*idVendor*/
  LOBYTE(USBD_PID_FS),        /*idProduct*/
  HIBYTE(USBD_PID_FS),        /*idProduct*/
  0x01,                       /*bcdDevice rel. 2.00*/
  0x02,
  USBD_IDX_MFC_STR,           /*Index of manufacturer  string*/
  USBD_IDX_PRODUCT_STR,       /*Index of product string*/
  USBD_IDX_SERIAL_STR,        /*Index of serial number string*/
  USBD_MAX_NUM_CONFIGURATION  /*bNumConfigurations*/
};

/* USB_DeviceDescriptor */


#define USB_LEN_OS_FEATURE_DESC 0x28

static __ALIGN_BEGIN uint8_t USBD_WINUSB_OSFeatureDesc[USB_LEN_OS_FEATURE_DESC] __ALIGN_END =
{
   0x28, 0, 0, 0, // length
   0, 1,          // bcd version 1.0
   4, 0,          // windex: extended compat ID descritor
   1,             // no of function
   0, 0, 0, 0, 0, 0, 0, // reserve 7 bytes
   // function
      0,             // interface no
      1,             // reserved
      'W', 'I', 'N', 'U', 'S', 'B', 0, 0, //  first ID
        0,   0,   0,   0,   0,   0, 0, 0,  // second ID
        0,   0,   0,   0,   0,   0 // reserved 6 bytes
};

#define USB_LEN_OS_PROPERTY_DESC 0x8E
__ALIGN_BEGIN uint8_t USBD_WINUSB_OSPropertyDesc[USB_LEN_OS_PROPERTY_DESC] __ALIGN_END =
{
      0x8E, 0, 0, 0,  // length 246 byte
      0x00, 0x01,   // BCD version 1.0
      0x05, 0x00,   // Extended Property Descriptor Index(5)
      0x01, 0x00,   // number of section (1)
      //; property section
            0x84, 0x00, 0x00, 0x00,   // size of property section
            0x1, 0, 0, 0,   //; property data type (1)
            0x28, 0,        //; property name length (42)
            'D', 0,
            'e', 0,
            'v', 0,
            'i', 0,
            'c', 0,
            'e', 0,
            'I', 0,
            'n', 0,
            't', 0,
            'e', 0,
            'r', 0,
            'f', 0,
            'a', 0,
            'c', 0,
            'e', 0,
            'G', 0,
            'U', 0,
            'I', 0,
            'D', 0,
            0, 0,
            // D6805E56-0447-4049-9848-46D6B2AC5D28
            0x4E, 0, 0, 0,  // ; property data length
            '{', 0,
            '1', 0,
            '3', 0,
            'E', 0,
            'B', 0,
            '3', 0,
            '6', 0,
            '0', 0,
            'B', 0,
            '-', 0,
            'B', 0,
            'C', 0,
            '1', 0,
            'E', 0,
            '-', 0,
            '4', 0,
            '6', 0,
            'C', 0,
            'B', 0,
            '-', 0,
            'A', 0,
            'C', 0,
            '8', 0,
            'B', 0,
            '-', 0,
            'E', 0,
            'F', 0,
            '3', 0,
            'D', 0,
            'A', 0,
            '4', 0,
            '7', 0,
            'B', 0,
            '4', 0,
            '0', 0,
            '6', 0,
            '2', 0,
            '}', 0,
            0, 0,

};



    /** USB lang indentifier descriptor. */
static __ALIGN_BEGIN uint8_t USBD_LangIDDesc[USB_LEN_LANGID_STR_DESC] __ALIGN_END =
{
     USB_LEN_LANGID_STR_DESC,
     USB_DESC_TYPE_STRING,
     LOBYTE(USBD_LANGID_STRING),
     HIBYTE(USBD_LANGID_STRING)
};


/* Internal string descriptor. */
static __ALIGN_BEGIN uint8_t USBD_StrDesc[USBD_MAX_STR_DESC_SIZ] __ALIGN_END;


static __ALIGN_BEGIN uint8_t USBD_StringSerial[USB_SIZ_STRING_SERIAL] __ALIGN_END = {
  USB_SIZ_STRING_SERIAL,
  USB_DESC_TYPE_STRING,
};


static uint8_t* USBD_FS_DeviceDescriptor(USBD_SpeedTypeDef speed, uint16_t* length)
{
  UNUSED(speed);
  *length = sizeof(USBD_FS_DeviceDesc);
  return USBD_FS_DeviceDesc;
}

static uint8_t* USBD_FS_LangIDStrDescriptor(USBD_SpeedTypeDef speed, uint16_t* length)
{
  UNUSED(speed);
  *length = sizeof(USBD_LangIDDesc);
  return USBD_LangIDDesc;
}

static uint8_t* USBD_FS_ProductStrDescriptor(USBD_SpeedTypeDef speed, uint16_t* length)
{
  if (speed == 0)
  {
    USBD_GetString((uint8_t*)USBD_PRODUCT_STRING_FS, USBD_StrDesc, length);
  } else
  {
    USBD_GetString((uint8_t*)USBD_PRODUCT_STRING_FS, USBD_StrDesc, length);
  }
  return USBD_StrDesc;
}

static uint8_t* USBD_FS_ManufacturerStrDescriptor(USBD_SpeedTypeDef speed, uint16_t* length)
{
  UNUSED(speed);
  USBD_GetString((uint8_t*)USBD_MANUFACTURER_STRING, USBD_StrDesc, length);
  return USBD_StrDesc;
}

static uint8_t* USBD_FS_SerialStrDescriptor(USBD_SpeedTypeDef speed, uint16_t* length)
{
  UNUSED(speed);
  *length = USB_SIZ_STRING_SERIAL;

  Get_SerialNum();
  return (uint8_t*)USBD_StringSerial;
}

static uint8_t* USBD_FS_ConfigStrDescriptor(USBD_SpeedTypeDef speed, uint16_t* length)
{
  if (speed == USBD_SPEED_HIGH)
  {
    USBD_GetString((uint8_t*)USBD_CONFIGURATION_STRING_FS, USBD_StrDesc, length);
  } else
  {
    USBD_GetString((uint8_t*)USBD_CONFIGURATION_STRING_FS, USBD_StrDesc, length);
  }
  return USBD_StrDesc;
}

static uint8_t* USBD_FS_InterfaceStrDescriptor(USBD_SpeedTypeDef speed, uint16_t* length)
{
  if (speed == 0)
  {
    USBD_GetString((uint8_t*)USBD_INTERFACE_STRING_FS, USBD_StrDesc, length);
  } else
  {
    USBD_GetString((uint8_t*)USBD_INTERFACE_STRING_FS, USBD_StrDesc, length);
  }
  return USBD_StrDesc;
}

static void Get_SerialNum(void)
{
  uint32_t deviceserial0, deviceserial1, deviceserial2;

  deviceserial0 = *(uint32_t*)DEVICE_ID1;
  deviceserial1 = *(uint32_t*)DEVICE_ID2;
  deviceserial2 = *(uint32_t*)DEVICE_ID3;

  deviceserial0 += deviceserial2;

  if (deviceserial0 != 0)
  {
    IntToUnicode(deviceserial0, &USBD_StringSerial[2], 8);
    IntToUnicode(deviceserial1, &USBD_StringSerial[18], 4);
  }
}

const uint8_t USBD_OS_STRING[9] = {
   'M',
   'S',
   'F',
   'T',
   '1',
   '0',
   '0',
   USB_REQ_MS_VENDOR_CODE,
   0
};
static uint8_t* USBD_WinUSBOSStrDescriptor(uint16_t* length)
{
  USBD_GetString((uint8_t*)USBD_OS_STRING, USBD_StrDesc, length);
  return USBD_StrDesc;
}
static uint8_t* USBD_WinUSBOSFeatureDescriptor(uint16_t* length)
{
  *length = USB_LEN_OS_FEATURE_DESC;
  return USBD_WINUSB_OSFeatureDesc;
}

static uint8_t* USBD_WinUSBOSPropertyDescriptor(uint16_t* length)
{
  *length = USB_LEN_OS_PROPERTY_DESC;
  return USBD_WINUSB_OSPropertyDesc;
}


static void IntToUnicode(uint32_t value, uint8_t* pbuf, uint8_t len)
{

  for (uint8_t idx = 0; idx < len; idx++)
  {
    if (((value >> 28)) < 0xA)
    {
      pbuf[2 * idx] = (value >> 28) + '0';
    } else
    {
      pbuf[2 * idx] = (value >> 28) + 'A' - 10;
    }

    value = value << 4;

    pbuf[2 * idx + 1] = 0;
  }
}
