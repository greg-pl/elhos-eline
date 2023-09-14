/*
 * MyBT.cpp
 *
 *  Created on: 6 kwi 2021
 *      Author: Grzegorz
 */

#include "MyBT.h"

#include <string.h>
#include <sys/param.h>

#include "esp_system.h"
#include "esp_event.h"
#include "esp_log.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#include "esp_bt.h"
#include "esp_bt_main.h"
#include "esp_gap_bt_api.h"
#include "esp_bt_device.h"
#include "esp_spp_api.h"
#include "Token.h"
#include "MyConfig.h"

#define TAG "BT"
#define SPP_SERVER_NAME "ELINE_RMT_SERVER"

InitPhase MyBT::mInitPhase;
bool MyBT::mConnected;
bool MyBT::mSendMeas;
uint32_t MyBT::mHandle;
char MyBT::inpBuf[300];
char MyBT::outBuf[300];
bool MyBT::mSending;
int MyBT::mSendingTick;
int MyBT::mDebug;
int MyBT::mTmp1;


extern MyConfig *myConfig;

void MyBT::esp_spp_cb(esp_spp_cb_event_t event, esp_spp_cb_param_t *param) {
	switch (event) {
	case ESP_SPP_INIT_EVT:{
		ESP_LOGI(TAG, "ESP_SPP_INIT_EVT");
		const char *name = myConfig->getUSBName();
		esp_bt_dev_set_device_name(name);
		esp_bt_gap_set_scan_mode(ESP_BT_CONNECTABLE, ESP_BT_GENERAL_DISCOVERABLE);
		esp_spp_start_srv(ESP_SPP_SEC_AUTHENTICATE, ESP_SPP_ROLE_SLAVE, 0, SPP_SERVER_NAME);
	}break;
	case ESP_SPP_DISCOVERY_COMP_EVT:
		ESP_LOGI(TAG, "ESP_SPP_DISCOVERY_COMP_EVT");
		break;
	case ESP_SPP_OPEN_EVT:
		ESP_LOGI(TAG, "ESP_SPP_OPEN_EVT H=%u st=%u", param->open.handle, param->open.status);
		if (param->open.status == 0) {
			mHandle = param->open.handle;
			mConnected = true;
		}

		break;
	case ESP_SPP_CLOSE_EVT:
		ESP_LOGI(TAG, "ESP_SPP_CLOSE_EVT");
		mConnected = false;
		break;
	case ESP_SPP_START_EVT:
		ESP_LOGI(TAG, "ESP_SPP_START_EVT");
		break;
	case ESP_SPP_CL_INIT_EVT:
		ESP_LOGI(TAG, "ESP_SPP_CL_INIT_EVT");
		break;
	case ESP_SPP_DATA_IND_EVT:
		//ESP_LOGI(TAG, "ESP_SPP_DATA_IND_EVT len=%d handle=%d", param->data_ind.len, param->data_ind.handle);
		//esp_log_buffer_hex("",param->data_ind.data,param->data_ind.len);
		onDataRecived(param->data_ind.data, param->data_ind.len);
		break;
	case ESP_SPP_CONG_EVT:
		ESP_LOGI(TAG, "ESP_SPP_CONG_EVT");
		break;
	case ESP_SPP_WRITE_EVT:
		//ESP_LOGI(TAG, "ESP_SPP_WRITE_EVT");
		mSending = false;
		break;
	case ESP_SPP_SRV_OPEN_EVT:
		ESP_LOGI(TAG, "ESP_SPP_SRV_OPEN_EVT");
		if (param->srv_open.status == 0) {
			mHandle = param->srv_open.handle;
			mConnected = true;
		}
		break;
	case ESP_SPP_SRV_STOP_EVT:
		ESP_LOGI(TAG, "ESP_SPP_SRV_STOP_EVT");
		break;
	case ESP_SPP_UNINIT_EVT:
		ESP_LOGI(TAG, "ESP_SPP_UNINIT_EVT");
		break;
	default:
		break;
	}
}

void MyBT::esp_bt_gap_cb(esp_bt_gap_cb_event_t event, esp_bt_gap_cb_param_t *param) {
	switch (event) {
	case ESP_BT_GAP_AUTH_CMPL_EVT: {
		if (param->auth_cmpl.stat == ESP_BT_STATUS_SUCCESS) {
			ESP_LOGI(TAG, "authentication success: %s", param->auth_cmpl.device_name);
			esp_log_buffer_hex(TAG, param->auth_cmpl.bda, ESP_BD_ADDR_LEN);
		} else {
			ESP_LOGE(TAG, "authentication failed, status:%d", param->auth_cmpl.stat);
		}
		break;
	}
	case ESP_BT_GAP_PIN_REQ_EVT: {
		ESP_LOGI(TAG, "ESP_BT_GAP_PIN_REQ_EVT min_16_digit:%d", param->pin_req.min_16_digit);
		if (param->pin_req.min_16_digit) {
			ESP_LOGI(TAG, "Input pin code: 0000 0000 0000 0000");
			esp_bt_pin_code_t pin_code = { 0 };
			esp_bt_gap_pin_reply(param->pin_req.bda, true, 16, pin_code);
		} else {
			ESP_LOGI(TAG, "Input pin code: 1234");
			esp_bt_pin_code_t pin_code;
			pin_code[0] = '1';
			pin_code[1] = '2';
			pin_code[2] = '3';
			pin_code[3] = '4';
			esp_bt_gap_pin_reply(param->pin_req.bda, true, 4, pin_code);
		}
		break;
	}

#if (CONFIG_BT_SSP_ENABLED == true)
	case ESP_BT_GAP_CFM_REQ_EVT:
		ESP_LOGI(TAG, "ESP_BT_GAP_CFM_REQ_EVT Please compare the numeric value: %d", param->cfm_req.num_val);
		esp_bt_gap_ssp_confirm_reply(param->cfm_req.bda, true);
		break;
	case ESP_BT_GAP_KEY_NOTIF_EVT:
		ESP_LOGI(TAG, "ESP_BT_GAP_KEY_NOTIF_EVT passkey:%d", param->key_notif.passkey);
		break;
	case ESP_BT_GAP_KEY_REQ_EVT:
		ESP_LOGI(TAG, "ESP_BT_GAP_KEY_REQ_EVT Please enter passkey!");
		break;
#endif

	default: {
		ESP_LOGI(TAG, "event: %d", event);
		break;
	}
	}
	return;
}

void MyBT::init() {

	esp_err_t ret;

	ESP_ERROR_CHECK(esp_bt_controller_mem_release(ESP_BT_MODE_BLE));

	esp_bt_controller_config_t bt_cfg = BT_CONTROLLER_INIT_CONFIG_DEFAULT()

	mInitPhase = iniControlerInit;

	if ((ret = esp_bt_controller_init(&bt_cfg)) != ESP_OK) {
		ESP_LOGE(TAG, "%s initialize controller failed: %s\n", __func__, esp_err_to_name(ret));
		return;
	}

	mInitPhase = iniControlerEnable;
	if ((ret = esp_bt_controller_enable(ESP_BT_MODE_CLASSIC_BT)) != ESP_OK) {
		ESP_LOGE(TAG, "%s enable controller failed: %s\n", __func__, esp_err_to_name(ret));
		return;
	}

	mInitPhase = iniBlueroidInit;
	if ((ret = esp_bluedroid_init()) != ESP_OK) {
		ESP_LOGE(TAG, "%s initialize bluedroid failed: %s\n", __func__, esp_err_to_name(ret));
		return;
	}

	mInitPhase = iniBlueroidEnable;
	if ((ret = esp_bluedroid_enable()) != ESP_OK) {
		ESP_LOGE(TAG, "%s enable bluedroid failed: %s\n", __func__, esp_err_to_name(ret));
		return;
	}

	mInitPhase = iniRegGapCallback;
	if ((ret = esp_bt_gap_register_callback(esp_bt_gap_cb)) != ESP_OK) {
		ESP_LOGE(TAG, "%s gap register failed: %s\n", __func__, esp_err_to_name(ret));
		return;
	}

	mInitPhase = iniRegSppCallback;
	if ((ret = esp_spp_register_callback(esp_spp_cb)) != ESP_OK) {
		ESP_LOGE(TAG, "%s spp register failed: %s\n", __func__, esp_err_to_name(ret));
		return;
	}

	mInitPhase = iniSppInit;
	if ((ret = esp_spp_init(ESP_SPP_MODE_CB)) != ESP_OK) {
		ESP_LOGE(TAG, "%s spp init failed: %s\n", __func__, esp_err_to_name(ret));
		return;
	}

#if (CONFIG_BT_SSP_ENABLED == true)
	/* Set default parameters for Secure Simple Pairing */
	esp_bt_sp_param_t param_type = ESP_BT_SP_IOCAP_MODE;
	esp_bt_io_cap_t iocap = ESP_BT_IO_CAP_IO;
	esp_bt_gap_set_security_param(param_type, &iocap, sizeof(uint8_t));
#endif

	/*
	 * Set default parameters for Legacy Pairing
	 * Use variable pin, input pin code when pairing
	 */
	esp_bt_pin_type_t pin_type = ESP_BT_PIN_TYPE_VARIABLE;
	esp_bt_pin_code_t pin_code;
	esp_bt_gap_set_pin(pin_type, 0, pin_code);
	mInitPhase = iniBtOK;
	mConnected = false;
	mSendMeas = false;
	mSending = false;
	mDebug = 0;

}

extern "C" void refreshKeepAlive();
extern "C" void showLcdBigMsg(const char *msg);
extern "C" void offMySelfbyBT(int delay);




void MyBT::writeBT(const char *dt, int len) {
	esp_spp_write(mHandle, len, (uint8_t*) dt);
	mSending = true;
	mSendingTick = esp_log_timestamp();

}

void MyBT::writeStrBT(const char *dt) {
	writeBT(dt, strlen(dt));
}

void MyBT::onDataRecived(uint8_t *dt, int len) {
	refreshKeepAlive();

	if (len > sizeof(inpBuf) - 1) {
		len = sizeof(inpBuf) - 1;
		ESP_LOGE(TAG, "Too long input command");
	}
	memcpy(inpBuf, dt, len);
	inpBuf[len] = 0;

	Token::remooveEOL(inpBuf);

	const char *inp = inpBuf;

	char tok[20];
	Token::get(&inp, tok, sizeof(tok));

	if (mDebug >= 2) {
		printf("Token [%s] len=%u\n", tok, strlen(tok));
	}

	if (strcmp(tok, "MEAS") == 0) {
		Token::getAsBool(&inp, &mSendMeas);

	} else if (strcmp(tok, "GET_CFG") == 0) {
		int n = snprintf(outBuf, sizeof(outBuf), "CFG=%s;%s;%u;\n", myConfig->cfg.WifiSSID, myConfig->cfg.WifiPassword, myConfig->cfg.WifiAuthMode);
		writeBT(outBuf, n);
	} else if (strcmp(tok, "GET_SERVICE_CFG") == 0) {

	} else if (strcmp(tok, "WELCOME") == 0) {
		writeStrBT("eLine\n");
	} else if (strcmp(tok, "IDENTIFY") == 0) {
		writeStrBT("OK\n");
		showLcdBigMsg(" eLINE! ");
	} else if (strcmp(tok, "OFF_ME") == 0) {
		writeStrBT("OK\n");
		offMySelfbyBT(1000);
	}
}

bool MyBT::menu(char ch) {
	switch (ch) {
	case 'g':
		mDebug = (mDebug + 1) % 4;
		printf("Debug=%d\n", mDebug);
		break;
	case 's':
		printf("InitPhase:%u\n", mInitPhase);
		printf("Connected:%u\n", mConnected);
		printf("Sending:%u\n", mSending);
		printf("Tmp1:0x%04X\n", mTmp1);

		break;
	case 'I':
		init();
		break;

	case 27:
		return true;
	default:
		printf("____BlueTooth menu____\n"
				"s - status\n"
				"I - init\n"

		);
	}
	return false;
}

