/**
 ******************************************************************************
 * @file    usbd_winusb.c
 * @author  GeKa
 * @brief   This file provides the high layer firmware functions to manage the
 *          following functionalities of the USB CDC Class:
 *           - Initialization and Configuration of high and low layer
 *           - Enumeration as CDC Device (and enumeration for each implemented memory interface)
 *           - OUT/IN data transfer
 *           - Command IN transfer (class requests management)
 *           - Error management
 *
 ******************************************************************************
 */

/* Includes ------------------------------------------------------------------*/
#include "usbd_winusb.h"
#include "usbd_ctlreq.h"

static uint8_t USBD_WINUSB_Init(USBD_HandleTypeDef *pdev, uint8_t cfgidx);

static uint8_t USBD_WINUSB_DeInit(USBD_HandleTypeDef *pdev, uint8_t cfgidx);

static uint8_t USBD_WINUSB_Setup(USBD_HandleTypeDef *pdev, USBD_SetupReqTypedef *req);

static uint8_t USBD_WINUSB_DataIn(USBD_HandleTypeDef *pdev, uint8_t epnum);

static uint8_t USBD_WINUSB_DataOut(USBD_HandleTypeDef *pdev, uint8_t epnum);

static uint8_t USBD_WINUSB_EP0_RxReady(USBD_HandleTypeDef *pdev);

static uint8_t* USBD_WINUSB_GetFSCfgDesc(uint16_t *length);

static uint8_t* USBD_WINUSB_GetHSCfgDesc(uint16_t *length);

static uint8_t* USBD_WINUSB_GetOtherSpeedCfgDesc(uint16_t *length);

static uint8_t* USBD_WINUSB_GetOtherSpeedCfgDesc(uint16_t *length);

uint8_t* USBD_WINUSB_GetDeviceQualifierDescriptor(uint16_t *length);

static USBD_WINUSB_HandleTypeDef WinUsbHandle;

/* USB Standard Device Descriptor */
__ALIGN_BEGIN static uint8_t USBD_WINUSB_DeviceQualifierDesc[USB_LEN_DEV_QUALIFIER_DESC] __ALIGN_END
= {
USB_LEN_DEV_QUALIFIER_DESC,
USB_DESC_TYPE_DEVICE_QUALIFIER, 0x00, 0x02, 0x00, 0x00, 0x00, 0x40, 0x01, 0x00, };

/**
 * @}
 */

/** @defgroup USBD_WINUSB_Private_Variables
 * @{
 */

/* WINUSB interface class callbacks structure */
USBD_ClassTypeDef USBD_WINUSB = { USBD_WINUSB_Init, USBD_WINUSB_DeInit, USBD_WINUSB_Setup,
NULL, /* EP0_TxSent, */
USBD_WINUSB_EP0_RxReady, USBD_WINUSB_DataIn, USBD_WINUSB_DataOut,
NULL,
NULL,
NULL, USBD_WINUSB_GetHSCfgDesc, USBD_WINUSB_GetFSCfgDesc, USBD_WINUSB_GetOtherSpeedCfgDesc, USBD_WINUSB_GetDeviceQualifierDescriptor, };

/* USB WINUSB device Configuration Descriptor */

#if  (LOGGER_PIPE==1)
#define PIPE_CNT 3
#define WINUSB_CONFIG_DESC_SIZE 39

#else
#define PIPE_CNT 2
#define WINUSB_CONFIG_DESC_SIZE 32

#endif

__ALIGN_BEGIN uint8_t USBD_WINUSB_CfgHSDesc[WINUSB_CONFIG_DESC_SIZE] __ALIGN_END
= {
/*Configuration Descriptor*/
0x09, /* bLength: Configuration Descriptor size */
USB_DESC_TYPE_CONFIGURATION, /* bDescriptorType: Configuration */
WINUSB_CONFIG_DESC_SIZE, /* wTotalLength:no of returned bytes */
0x00, //
		0x01, /* bConfigurationValue: Configuration value */
		0x01, /* bConfigurationValue: Configuration value */
		USBD_IDX_CONFIG_STR, /* iConfiguration: Index of string descriptor describing the configuration */
		0xC0, /* bmAttributes: self powered */
		0x32, /* MaxPower 0 mA */

		/*---------------------------------------------------------------------------*/

		/*Interface Descriptor */
		0x09, /* bLength: Interface Descriptor size */
		USB_DESC_TYPE_INTERFACE, /* bDescriptorType: Interface */
		0x00, /* bInterfaceNumber: Number of Interface */
		0x00, /* bAlternateSetting: Alternate setting */
		PIPE_CNT, /* bInterfaceSubClass: Abstract Control Model */
		0xff, /* bInterfaceClass: vendor */
		0x00, /* bInterfaceSubClass: */
		0x00, /* bInterfaceProtocol: */
		0x00, /* iInterface: */

		/*Endpoint OUT Descriptor*/
		0x07, /* bLength: Endpoint Descriptor size */
		USB_DESC_TYPE_ENDPOINT, /* bDescriptorType: Endpoint */
		WINUSB_OUT_EP, /* bEndpointAddress */
		0x02, /* bmAttributes: Bulk */
		LOBYTE(WINUSB_DATA_HS_MAX_PACKET_SIZE), /* wMaxPacketSize: */
		HIBYTE(WINUSB_DATA_HS_MAX_PACKET_SIZE), 0x00, /* bInterval: ignore for Bulk transfer */

		/*Endpoint IN Descriptor*/
		0x07, /* bLength: Endpoint Descriptor size */
		USB_DESC_TYPE_ENDPOINT, /* bDescriptorType: Endpoint */
		WINUSB_IN_EP, /* bEndpointAddress */
		0x02, /* bmAttributes: Bulk */
		LOBYTE(WINUSB_DATA_HS_MAX_PACKET_SIZE), /* wMaxPacketSize: */
		HIBYTE(WINUSB_DATA_HS_MAX_PACKET_SIZE), //
		0x00, /* bInterval: ignore for Bulk transfer */

#if(LOGGER_PIPE==1)
		/*Endpoint OUT Descriptor*/
		0x07, /* bLength: Endpoint Descriptor size */
		USB_DESC_TYPE_ENDPOINT, /* bDescriptorType: Endpoint */
		WINUSB_LOGGER_EP, /* bEndpointAddress */
		0x02, /* bmAttributes: Bulk */
		LOBYTE(WINUSB_DATA_FS_MAX_PACKET_SIZE), /* wMaxPacketSize: */
		HIBYTE(WINUSB_DATA_FS_MAX_PACKET_SIZE), //
		0x00, /* bInterval: ignore for Bulk transfer */
#endif
		};

__ALIGN_BEGIN uint8_t USBD_WINUSB_CfgFSDesc[WINUSB_CONFIG_DESC_SIZE] __ALIGN_END = {
/*Configuration Descriptor*/
0x09, /* bLength: Configuration Descriptor size */
USB_DESC_TYPE_CONFIGURATION, /* bDescriptorType: Configuration */
WINUSB_CONFIG_DESC_SIZE, /* wTotalLength:no of returned bytes */
0x00, 0x01, /* bConfigurationValue: Configuration value */
0x01, /* bConfigurationValue: Configuration value */
USBD_IDX_CONFIG_STR, /* iConfiguration: Index of string descriptor describing the configuration */
0xC0, /* bmAttributes: self powered */
0x32, /* MaxPower 0 mA */

/*---------------------------------------------------------------------------*/

/*Interface Descriptor */
0x09, /* bLength: Interface Descriptor size */
USB_DESC_TYPE_INTERFACE, /* bDescriptorType: Interface */
0x00, /* bInterfaceNumber: Number of Interface */
0x00, /* bAlternateSetting: Alternate setting */
PIPE_CNT, /* bInterfaceClass: Communication Interface Class */
0xFF, /* bInterfaceClass: vendor */
0xFF, /* bInterfaceSubClass: */
0xFF, /* bInterfaceProtocol: */
0x00, /* iInterface: */

/*Endpoint IN Descriptor*/
0x07, /* bLength: Endpoint Descriptor size */
USB_DESC_TYPE_ENDPOINT, /* bDescriptorType: Endpoint */
WINUSB_IN_EP, /* bEndpointAddress */
0x02, /* bmAttributes: Bulk */
LOBYTE(WINUSB_DATA_FS_MAX_PACKET_SIZE), /* wMaxPacketSize: */
HIBYTE(WINUSB_DATA_FS_MAX_PACKET_SIZE), //
0x00, /* bInterval: ignore for Bulk transfer */

/*Endpoint OUT Descriptor*/
0x07, /* bLength: Endpoint Descriptor size */
USB_DESC_TYPE_ENDPOINT, /* bDescriptorType: Endpoint */
WINUSB_OUT_EP, /* bEndpointAddress */
0x02, /* bmAttributes: Bulk */
LOBYTE(WINUSB_DATA_FS_MAX_PACKET_SIZE), /* wMaxPacketSize: */
HIBYTE(WINUSB_DATA_FS_MAX_PACKET_SIZE), //
0x00, /* bInterval: ignore for Bulk transfer */
#if  (LOGGER_PIPE==1)
		/*Endpoint OUT Descriptor*/
		0x07, /* bLength: Endpoint Descriptor size */
		USB_DESC_TYPE_ENDPOINT, /* bDescriptorType: Endpoint */
		WINUSB_LOGGER_EP, /* bEndpointAddress */
		0x02, /* bmAttributes: Bulk */
		LOBYTE(WINUSB_DATA_FS_MAX_PACKET_SIZE), /* wMaxPacketSize: */
		HIBYTE(WINUSB_DATA_FS_MAX_PACKET_SIZE), //
		0x00, /* bInterval: ignore for Bulk transfer */
#endif
		};

static uint8_t USBD_WINUSB_Init(USBD_HandleTypeDef *pdev, uint8_t cfgidx) {
	uint8_t ret = 0U;
	USBD_WINUSB_HandleTypeDef *hcdc;

	if (pdev->dev_speed == USBD_SPEED_HIGH) {
		/* Open EP IN */
		USBD_LL_OpenEP(pdev, WINUSB_IN_EP, USBD_EP_TYPE_BULK, WINUSB_DATA_HS_IN_PACKET_SIZE);

		pdev->ep_in[WINUSB_IN_EP & 0xFU].is_used = 1U;

		/* Open EP OUT */
		USBD_LL_OpenEP(pdev, WINUSB_OUT_EP, USBD_EP_TYPE_BULK, WINUSB_DATA_HS_OUT_PACKET_SIZE);

		pdev->ep_out[WINUSB_OUT_EP & 0xFU].is_used = 1U;

	} else {
		/* Open EP IN */
		USBD_LL_OpenEP(pdev, WINUSB_IN_EP, USBD_EP_TYPE_BULK, WINUSB_DATA_FS_IN_PACKET_SIZE);

		pdev->ep_in[WINUSB_IN_EP & 0xFU].is_used = 1U;

		/* Open EP OUT */
		USBD_LL_OpenEP(pdev, WINUSB_OUT_EP, USBD_EP_TYPE_BULK,
		WINUSB_DATA_FS_OUT_PACKET_SIZE);

		pdev->ep_out[WINUSB_OUT_EP & 0xFU].is_used = 1U;
	}
	/* Open Command IN EP */
#if  (LOGGER_PIPE==1)
	USBD_LL_OpenEP(pdev, WINUSB_LOGGER_EP, USBD_EP_TYPE_INTR, WINUSB_LOG_PACKET_SIZE);
	pdev->ep_in[WINUSB_LOGGER_EP & 0xFU].is_used = 1U;
#endif
	pdev->pClassData = &WinUsbHandle;

	if (pdev->pClassData == NULL) {
		ret = 1U;
	} else {
		hcdc = (USBD_WINUSB_HandleTypeDef*) pdev->pClassData;

		/* Init  physical Interface components */
		((USBD_WINUSB_ItfTypeDef*) pdev->pUserData)->Init();

		/* Init Xfer states */
		hcdc->TxState = 0U;
		hcdc->RxState = 0U;
#if (LOGGER_PIPE == 1)
		hcdc->LogState = 0U;
#endif
		if (pdev->dev_speed == USBD_SPEED_HIGH) {
			/* Prepare Out endpoint to receive next packet */
			USBD_LL_PrepareReceive(pdev, WINUSB_OUT_EP, hcdc->RxBuffer, WINUSB_DATA_HS_OUT_PACKET_SIZE);
		} else {
			/* Prepare Out endpoint to receive next packet */
			USBD_LL_PrepareReceive(pdev, WINUSB_OUT_EP, hcdc->RxBuffer, WINUSB_DATA_FS_OUT_PACKET_SIZE);
		}
	}
	return ret;
}

static uint8_t USBD_WINUSB_DeInit(USBD_HandleTypeDef *pdev, uint8_t cfgidx) {
	uint8_t ret = 0U;

	/* Close EP IN */
	USBD_LL_CloseEP(pdev, WINUSB_IN_EP);
	pdev->ep_in[WINUSB_IN_EP & 0xFU].is_used = 0U;

	/* Close EP OUT */
	USBD_LL_CloseEP(pdev, WINUSB_OUT_EP);
	pdev->ep_out[WINUSB_OUT_EP & 0xFU].is_used = 0U;

	/* Close Command IN EP */
#if  (LOGGER_PIPE==1)
	USBD_LL_CloseEP(pdev, WINUSB_LOGGER_EP);
	pdev->ep_in[WINUSB_LOGGER_EP & 0xFU].is_used = 0U;
#endif
	/* DeInit  physical Interface components */
	if (pdev->pClassData != NULL) {
		((USBD_WINUSB_ItfTypeDef*) pdev->pUserData)->DeInit();
		USBD_free(pdev->pClassData);
		pdev->pClassData = NULL;
	}

	return ret;
}

static uint8_t USBD_WINUSB_Setup(USBD_HandleTypeDef *pdev, USBD_SetupReqTypedef *req) {
	USBD_WINUSB_HandleTypeDef *hcdc = (USBD_WINUSB_HandleTypeDef*) pdev->pClassData;
	uint8_t ifalt = 0U;
	uint16_t status_info = 0U;
	uint8_t ret = USBD_OK;

	switch (req->bmRequest & USB_REQ_TYPE_MASK) {
	case USB_REQ_TYPE_CLASS:
		if (req->wLength) {
			if (req->bmRequest & 0x80U) {
				((USBD_WINUSB_ItfTypeDef*) pdev->pUserData)->Control(req->bRequest, (uint8_t*) (void*) hcdc->data, req->wLength);

				USBD_CtlSendData(pdev, (uint8_t*) (void*) hcdc->data, req->wLength);
			} else {
				hcdc->CmdOpCode = req->bRequest;
				hcdc->CmdLength = (uint8_t) req->wLength;

				USBD_CtlPrepareRx(pdev, (uint8_t*) (void*) hcdc->data, req->wLength);
			}
		} else {
			((USBD_WINUSB_ItfTypeDef*) pdev->pUserData)->Control(req->bRequest, (uint8_t*) (void*) req, 0U);
		}
		break;

	case USB_REQ_TYPE_STANDARD:
		switch (req->bRequest) {
		case USB_REQ_GET_STATUS:
			if (pdev->dev_state == USBD_STATE_CONFIGURED) {
				USBD_CtlSendData(pdev, (uint8_t*) (void*) &status_info, 2U);
			} else {
				USBD_CtlError(pdev, req);
				ret = USBD_FAIL;
			}
			break;

		case USB_REQ_GET_INTERFACE:
			if (pdev->dev_state == USBD_STATE_CONFIGURED) {
				USBD_CtlSendData(pdev, &ifalt, 1U);
			} else {
				USBD_CtlError(pdev, req);
				ret = USBD_FAIL;
			}
			break;

		case USB_REQ_SET_INTERFACE:
			if (pdev->dev_state != USBD_STATE_CONFIGURED) {
				USBD_CtlError(pdev, req);
				ret = USBD_FAIL;
			}
			break;

		default:
			USBD_CtlError(pdev, req);
			ret = USBD_FAIL;
			break;
		}
		break;

	default:
		USBD_CtlError(pdev, req);
		ret = USBD_FAIL;
		break;
	}

	return ret;
}

static uint8_t USBD_WINUSB_DataIn(USBD_HandleTypeDef *pdev, uint8_t epnum) {
	USBD_WINUSB_HandleTypeDef *hcdc = (USBD_WINUSB_HandleTypeDef*) pdev->pClassData;
	PCD_HandleTypeDef *hpcd = pdev->pData;

	if (pdev->pClassData != NULL) {
		if ((pdev->ep_in[epnum].total_length > 0U) && ((pdev->ep_in[epnum].total_length % hpcd->IN_ep[epnum].maxpacket) == 0U)) {
			/* Update the packet total length */
			pdev->ep_in[epnum].total_length = 0U;

			/* Send ZLP */
			USBD_LL_Transmit(pdev, epnum, NULL, 0U);
		} else {
			if (epnum == (WINUSB_IN_EP & 0x7F))
				hcdc->TxState = 0U;
#if(LOGGER_PIPE==1)
			if (epnum == (WINUSB_LOGGER_EP & 0x7F))
				hcdc->LogState = 0U;
#endif
		}
		return USBD_OK;
	} else {
		return USBD_FAIL;
	}
}

static uint8_t USBD_WINUSB_DataOut(USBD_HandleTypeDef *pdev, uint8_t epnum) {
	USBD_WINUSB_HandleTypeDef *hcdc = (USBD_WINUSB_HandleTypeDef*) pdev->pClassData;

	/* Get the received data length */
	hcdc->RxLength = USBD_LL_GetRxDataSize(pdev, epnum);

	/* USB data will be immediately processed, this allow next USB traffic being
	 NAKed till the end of the application Xfer */
	if (pdev->pClassData != NULL) {
		((USBD_WINUSB_ItfTypeDef*) pdev->pUserData)->Receive(hcdc->RxBuffer, &hcdc->RxLength);

		return USBD_OK;
	} else {
		return USBD_FAIL;
	}
}

static uint8_t USBD_WINUSB_EP0_RxReady(USBD_HandleTypeDef *pdev) {
	USBD_WINUSB_HandleTypeDef *hcdc = (USBD_WINUSB_HandleTypeDef*) pdev->pClassData;

	if ((pdev->pUserData != NULL) && (hcdc->CmdOpCode != 0xFFU)) {
		((USBD_WINUSB_ItfTypeDef*) pdev->pUserData)->Control(hcdc->CmdOpCode, (uint8_t*) (void*) hcdc->data, (uint16_t) hcdc->CmdLength);
		hcdc->CmdOpCode = 0xFFU;

	}
	return USBD_OK;
}

static uint8_t* USBD_WINUSB_GetFSCfgDesc(uint16_t *length) {
	*length = sizeof(USBD_WINUSB_CfgFSDesc);
	return USBD_WINUSB_CfgFSDesc;
}

static uint8_t* USBD_WINUSB_GetHSCfgDesc(uint16_t *length) {
	*length = sizeof(USBD_WINUSB_CfgHSDesc);
	return USBD_WINUSB_CfgHSDesc;
}

static uint8_t* USBD_WINUSB_GetOtherSpeedCfgDesc(uint16_t *length) {
	*length = sizeof(USBD_WINUSB_CfgFSDesc);
	return USBD_WINUSB_CfgFSDesc;
}

uint8_t* USBD_WINUSB_GetDeviceQualifierDescriptor(uint16_t *length) {
	*length = sizeof(USBD_WINUSB_DeviceQualifierDesc);
	return USBD_WINUSB_DeviceQualifierDesc;
}

uint8_t USBD_WINUSB_RegisterInterface(USBD_HandleTypeDef *pdev, USBD_WINUSB_ItfTypeDef *fops) {
	uint8_t ret = USBD_FAIL;

	if (fops != NULL) {
		pdev->pUserData = fops;
		ret = USBD_OK;
	}

	return ret;
}

uint8_t USBD_WINUSB_SetRxBuffer(USBD_HandleTypeDef *pdev, uint8_t *pbuff) {
	USBD_WINUSB_HandleTypeDef *hcdc = (USBD_WINUSB_HandleTypeDef*) pdev->pClassData;

	hcdc->RxBuffer = pbuff;

	return USBD_OK;
}

uint8_t USBD_WINUSB_SetTxDataBuffer(USBD_HandleTypeDef *pdev, const void *pbuff, uint16_t length) {
	USBD_WINUSB_HandleTypeDef *hcdc = (USBD_WINUSB_HandleTypeDef*) pdev->pClassData;

	hcdc->TxBuffer = (uint8_t*) pbuff;
	hcdc->TxLength = length;

	return USBD_OK;
}

uint8_t USBD_WINUSB_TransmitDataPacket(USBD_HandleTypeDef *pdev) {
	USBD_WINUSB_HandleTypeDef *hcdc = (USBD_WINUSB_HandleTypeDef*) pdev->pClassData;

	if (pdev->pClassData != NULL) {
		if (hcdc->TxState == 0U) {
			/* Tx Transfer in progress */
			hcdc->TxState = 1U;

			/* Update the packet total length */
			pdev->ep_in[WINUSB_IN_EP & 0xFU].total_length = hcdc->TxLength;

			/* Transmit next packet */
			USBD_LL_Transmit(pdev, WINUSB_IN_EP, hcdc->TxBuffer, (uint16_t) hcdc->TxLength);

			return USBD_OK;
		} else {
			return USBD_BUSY;
		}
	} else {
		return USBD_FAIL;
	}
}

#if (LOGGER_PIPE == 1)

uint8_t USBD_WINUSB_SetTxLogBuffer(USBD_HandleTypeDef *pdev, const void *pbuff, uint16_t length) {
	USBD_WINUSB_HandleTypeDef *hcdc = (USBD_WINUSB_HandleTypeDef*) pdev->pClassData;

	hcdc->LogBuffer = (uint8_t*) pbuff;
	hcdc->LogLength = length;

	return USBD_OK;
}

uint8_t USBD_WINUSB_TransmitLogPacket(USBD_HandleTypeDef *pdev) {
	USBD_WINUSB_HandleTypeDef *hcdc = (USBD_WINUSB_HandleTypeDef*) pdev->pClassData;

	if (pdev->pClassData != NULL) {
		if (hcdc->LogState == 0U) {
			hcdc->LogState = 1U;

			pdev->ep_in[WINUSB_LOGGER_EP & 0xFU].total_length = hcdc->LogLength;

			/* Transmit next packet */
			USBD_LL_Transmit(pdev, WINUSB_LOGGER_EP, hcdc->LogBuffer, (uint16_t) hcdc->LogLength);

			return USBD_OK;
		} else {
			return USBD_BUSY;
		}
	} else {
		return USBD_FAIL;
	}
}
#endif

uint8_t USBD_WINUSB_ReceivePacket(USBD_HandleTypeDef *pdev) {
	USBD_WINUSB_HandleTypeDef *hcdc = (USBD_WINUSB_HandleTypeDef*) pdev->pClassData;

	if (pdev->pClassData != NULL) {
		uint16_t pktSz = (pdev->dev_speed == USBD_SPEED_HIGH) ? WINUSB_DATA_HS_OUT_PACKET_SIZE :  //
				WINUSB_DATA_FS_OUT_PACKET_SIZE;

		USBD_LL_PrepareReceive(pdev, WINUSB_OUT_EP, hcdc->RxBuffer, pktSz);

		return USBD_OK;
	} else {
		return USBD_FAIL;
	}
}
