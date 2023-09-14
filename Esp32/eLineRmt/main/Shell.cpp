/*
 * Shell.cpp
 *
 *  Created on: 2 kwi 2021
 *      Author: Grzegorz
 */

#include <stdint.h>
#include <string.h>
#include <stdbool.h>
#include <stdio.h>
#include "esp_system.h"
#include "esp_log.h"
#include "esp_wifi_types.h"
#include "esp_wifi.h"
#include "esp_spi_flash.h"

#include "driver/uart.h"
#include "driver/gpio.h"

#include "myConfig.h"
#include "UMain.h"
#include "Shell.h"
#include <I2C.h>
#include <ssd1306.h>
#include "Max11612.h"
#include "MyConfig.h"
#include "MyBT.h"
#include "TcpSvrTask.h"

#define DBG_UART 0
#define BUF_SIZE        (16)
#define PACKET_READ_TICS        (1000 / portTICK_RATE_MS)

extern SSD1306Dev *lcd;
extern Max11612 *max11612;
extern MyConfig *myConfig;
extern TcpSvrTask *tcpSvrTask;

static  const char *TAG = "Shell";

Shell::Shell() :
		TaskClass::TaskClass("ShellTask", 4096) {
	menuNr = 'M';

}

#define UART0_TX    GPIO_NUM_1
#define UART0_RX    GPIO_NUM_3

void Shell::initialize_console(void) {
	/* Drain stdout before reconfiguring it */
	fflush(stdout);

	/* Disable buffering on stdin */
	//setvbuf(stdin, NULL, _IONBF, 0);
	const uart_config_t uart_config = { //
			.baud_rate = CONFIG_ESP_CONSOLE_UART_BAUDRATE, //
					.data_bits = UART_DATA_8_BITS, //
					.parity = UART_PARITY_DISABLE, //
					.stop_bits = UART_STOP_BITS_1, //
					.flow_ctrl = UART_HW_FLOWCTRL_DISABLE, //
					.rx_flow_ctrl_thresh = 10, //
					.source_clk = UART_SCLK_APB };
	ESP_ERROR_CHECK(uart_param_config(DBG_UART, &uart_config));
	uart_set_pin(DBG_UART, UART0_TX, UART0_RX, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE);

	ESP_ERROR_CHECK(uart_driver_install(DBG_UART,0xA0, 0x1000, 0, NULL, 0));

	uart_set_mode(DBG_UART, UART_MODE_UART);
}

void Shell::chipInfo() {
	esp_chip_info_t info;
	esp_chip_info(&info);
	printf("IDF Version:%s\r\n", esp_get_idf_version());
	printf("Chip info:\r\n");
	printf("\tmodel:%s\r\n", info.model == CHIP_ESP32 ? "ESP32" : "Unknow");
	printf("\tcores:%d\r\n", info.cores);
	printf("\tfeature:%s%s%s%s%d%s\r\n", //
			info.features & CHIP_FEATURE_WIFI_BGN ? "/802.11bgn" : "", //
			info.features & CHIP_FEATURE_BLE ? "/BLE" : "", //
			info.features & CHIP_FEATURE_BT ? "/BT" : "", //
			info.features & CHIP_FEATURE_EMB_FLASH ? "/Embedded-Flash:" : "/External-Flash:", //
			spi_flash_get_chip_size() / (1024 * 1024), " MB");
	printf("\trevision number:%d\n", info.revision);

	uint8_t mac[6];
	esp_efuse_mac_get_default(mac);
	printf("\tMAC %02X:%02X:%02X:%02X:%02X:%02X\n", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
	printf("\tFreeMem %d[bytes]\n", esp_get_free_heap_size());

}

void Shell::tasksInfo() {
	const size_t bytes_per_task = 40; /* see vTaskList description */
	char *task_list_buffer = (char*) malloc(uxTaskGetNumberOfTasks() * bytes_per_task);
	if (task_list_buffer == NULL) {
		ESP_LOGE(TAG, "failed to allocate buffer for vTaskList output");
		return;
	}
	fputs("Task Name\tStatus\tPrio\tHWM\tTask#", stdout);
#ifdef CONFIG_FREERTOS_VTASKLIST_INCLUDE_COREID
    fputs("\tAffinity", stdout);
#endif
	fputs("\n", stdout);
	vTaskList(task_list_buffer);
	fputs(task_list_buffer, stdout);
	free(task_list_buffer);
}

void Shell::mainMenu(char ch) {
	switch (ch) {
	case 'L':
	case 'X':
	case 'C':
	case 'B':
	case 'S':
		menuNr = ch;
		break;
	case 'R':
		ESP_LOGI(TAG, "Restarting");
		esp_restart();
		break;

	case 's':
		printf("HDW:LadStat=%d\n", Hdw::getLadStatus());
		printf("    KeyPwr=%d\n", Hdw::getKeyPwr());
		break;
	case 'K':
		printf("KPower=%d\n", Hdw::chgKPower());
		break;
	case 'V':
		printf("V12on=%d\n", Hdw::chgV12());
		break;
	case 'O':
		printf("SterOut=%d\n", Hdw::chgSterOut());
		break;
	case 'n':
		I2C::scan();
		break;
	case 'i':
		chipInfo();
		break;
	case 'p':
		tasksInfo();
		break;

	default:
		printf("____Main menu____\n"
				"L >> Lcd menu\n"
				"X >> MAX11612 menu\n"
				"C >> Cfg menu\n"
				"B >> BlueTooth menu\n"
				"S >> Svr menu\n"
				"R - restart\n"
				"s - get status\n"
				"i - chip info\n"
				"p - task info\n"
				"n - scan I2C\n"
				"V - on/off 12V\n"
				"O - ster OUT\n"
				"K - ster KPOWER\n"

		);

	}

}
void Shell::menu(char ch) {
	switch (menuNr) {
	case 'L':
		if (lcd->menu(ch))
			menuNr = 'M';
		break;
	case 'X':
		if (max11612->menu(ch))
			menuNr = 'M';
		break;
	case 'C':
		if (myConfig->menu(ch))
			menuNr = 'M';
		break;
	case 'B':
		if (MyBT::menu(ch))
			menuNr = 'M';
		break;
	case 'S':
		if (tcpSvrTask->menu(ch))
			menuNr = 'M';
		break;
	default:
		mainMenu(ch);
		break;
	}

}

extern "C" void refreshKeepAlive();

void Shell::ThreadFunc() {

	initialize_console();
	menuNr = 'M';
	printf(">");
	fflush(stdout);
	while (true) {
		uint8_t ch;
		int len = uart_read_bytes(DBG_UART, &ch, 1, PACKET_READ_TICS);
		//printf("Key=%c [%02X] len=%d\r\n", ch, ch, len);
		if (len > 0) {
			printf("%c\r\n", ch);
			menu(ch);
			printf(">");
			fflush(stdout);
			refreshKeepAlive();
		}
	}
}


void Shell::oWrX(TermColor color, const char *buf) {

}
void Shell::oFormatX(TermColor color, const char *pFormat, va_list ap) {
	if (oOpen(color)) {
		vprintf(pFormat, ap);
		printf("\n");
		oClose();
	}
}

void Shell::oFormat(const char *pFormat, va_list ap) {
	vprintf(pFormat, ap);
	printf("\n");
}

bool Shell::oOpen(TermColor color) {
	return true;
}
void Shell::oClose() {

}

void Shell::oWr(const char *txt) {
	printf(txt);
	printf("\n");
}

extern "C" const char* ipToStr(char *buf, esp_ip4_addr_t ip) {
	snprintf(buf, 20, IPSTR, IP2STR(&ip));
	return buf;
}
