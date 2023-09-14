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

#include "driver/uart.h"
#include "driver/gpio.h"

#include "myConfig.h"
#include "UMain.h"
#include "Shell.h"
#include <I2C.h>

#define DBG_UART 0
#define BUF_SIZE        (16)
#define PACKET_READ_TICS        (1000 / portTICK_RATE_MS)


extern I2C *i2c;

Shell::Shell() :
		TaskClass::TaskClass(4096) {

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

void Shell::menu(char ch) {
	switch (ch) {
	case 'K':
		printf("KPower=%d\n", Hdw::chgKPower());
		break;
	case 'V':
		printf("V12on=%d\n", Hdw::chgV12());
		break;
	case 'O':
		printf("SterOut=%d\n", Hdw::chgSterOut());
		break;
	case 's':
		printf("LadStat=%d\n", Hdw::getLadStatus());
		printf("KeyPwr=%d\n", Hdw::getKeyPwr());
		break;

	default:
		printf("____Main menu____\n"
				"s - get status\n"
				"V - on/off 12V\n"
				"O - ster OUT\n"
				"K - ster KPOWER\n"

		);

	}

}

void Shell::taskFun() {

	initialize_console();

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
		}

	}

}

