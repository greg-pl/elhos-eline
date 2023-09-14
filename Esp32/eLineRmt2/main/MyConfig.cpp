/*
 * MyConfig.cpp
 *
 *  Created on: 1 kwi 2021
 *      Author: Grzegorz
 */
#include <string.h>
#include <sys/param.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "esp_netif.h"
//#include "protocol_examples_common.h"

#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include <lwip/netdb.h>
#include <MyConfig.h>

#include "MyConfig.h"

MyConfig::MyConfig() {
	// TODO Auto-generated constructor stub

}

MyConfig::~MyConfig() {
	// TODO Auto-generated destructor stub
}

void MyConfig::init() {
	esp_err_t ret = nvs_flash_init();
	if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
		ESP_ERROR_CHECK(nvs_flash_erase());
		ret = nvs_flash_init();
	}
	nvs_handle_t handle;

	ret = nvs_open("sLINE", NVS_READONLY, &handle);
	if (ret == ESP_OK) {
		size_t len = sizeof(data.WifiSSID);
		nvs_get_str(handle, "WifiSSID", data.WifiSSID, &len);
		len = sizeof(data.WifiPassword);
		nvs_get_str(handle, "WifiPassword", data.WifiPassword, &len);
		nvs_close(handle);
	} else {
		defaultCfg();
	}

}

void MyConfig::defaultCfg() {
	strcpy(data.WifiSSID,"KANIA-A");
	strcpy(data.WifiPassword,"mikemia7");
	write();
}

void MyConfig::write() {
	nvs_handle_t handle;
	esp_err_t ret = nvs_open("sLINE", NVS_READWRITE, &handle);
	if (ret == ESP_OK) {
		nvs_set_str(handle, "WifiSSID", data.WifiSSID);
		nvs_set_str(handle, "WifiPassword", data.WifiPassword);
		nvs_close(handle);
	}
}

