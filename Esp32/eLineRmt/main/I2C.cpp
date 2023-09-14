/*
 * I2C.cpp
 *
 *  Created on: 3 kwi 2021
 *      Author: Grzegorz
 */

#include <stdio.h>
#include "esp_log.h"
#include "driver/i2c.h"

#include "I2C.h"

#define I2C_MASTER_SDA_IO GPIO_NUM_21
#define I2C_MASTER_SCL_IO GPIO_NUM_23
#define I2C_MASTER_FREQ_HZ 100000

SemaphoreHandle_t I2C::bus_mux;

void I2C::lock() {
	xSemaphoreTake(bus_mux, portMAX_DELAY);
}

void I2C::unlock() {
	xSemaphoreGive(bus_mux);
}

esp_err_t I2C::Init() {
	bus_mux = xSemaphoreCreateMutex();

	i2c_config_t conf;
	conf.mode = I2C_MODE_MASTER;
	conf.sda_io_num = I2C_MASTER_SDA_IO;
	conf.sda_pullup_en = GPIO_PULLUP_ENABLE;
	conf.scl_io_num = I2C_MASTER_SCL_IO;
	conf.scl_pullup_en = GPIO_PULLUP_ENABLE;
	conf.master.clk_speed = I2C_MASTER_FREQ_HZ;
	i2c_param_config(I2C_NUMBER, &conf);

	return i2c_driver_install(I2C_NUMBER, conf.mode, 0, 0, 0);
}

bool I2C::checkDevExist(uint8_t adr) {
	i2c_cmd_handle_t cmd = i2c_cmd_link_create();
	i2c_master_start(cmd);
	i2c_master_write_byte(cmd, adr << 1 | I2C_MASTER_WRITE, true);
	i2c_master_stop(cmd);
	lock();
	int ret = i2c_master_cmd_begin(I2C_NUMBER, cmd, 1000 / portTICK_RATE_MS);
	unlock();
	i2c_cmd_link_delete(cmd);
	if (ret != ESP_OK && ret != ESP_FAIL) {
		printf("checkDevExist adr=%u  ret=%d\n", adr, ret);
	}
	return (ret == ESP_OK);
}

void I2C::scan() {
	printf("Scanning..\n");
	for (int adr = 0; adr < 0x80; adr++) {
		if (checkDevExist(adr)) {
			printf("%3u (0x%02X):OK\n", adr, adr);
		}
	}
}

void I2CDev::lock() {
	I2C::lock();
}

void I2CDev::unlock() {
	I2C::unlock();
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
bool I2CDev::checkDevExist(uint8_t adr) {
	return I2C::checkDevExist(adr);
}

bool I2CDev::_writeMem(uint8_t devAdr, uint8_t adr, uint8_t *dt, int cnt) {
	i2c_cmd_handle_t cmd = i2c_cmd_link_create();
	i2c_master_start(cmd);
	i2c_master_write_byte(cmd, devAdr << 1 | I2C_MASTER_WRITE, true);
	i2c_master_write_byte(cmd, adr, true);
	i2c_master_write(cmd, dt, cnt, true);
	i2c_master_stop(cmd);
	int ret = i2c_master_cmd_begin(I2C::I2C_NUMBER, cmd, 1000 / portTICK_RATE_MS);
	i2c_cmd_link_delete(cmd);
	return (ret == ESP_OK);
}

bool I2CDev::writeMem(uint8_t devAdr, uint8_t adr, uint8_t *dt, int cnt) {
	lock();
	bool ret = _writeMem(devAdr, adr, dt, cnt);
	unlock();
	return ret;
}

bool I2CDev::_writeByte(uint8_t devAdr, uint8_t adr, uint8_t val) {
	return _writeMem(devAdr, adr, &val, 1);
}

bool I2CDev::writeByte(uint8_t devAdr, uint8_t adr, uint8_t val) {
	return writeMem(devAdr, adr, &val, 1);
}

bool I2CDev::_writeReg(uint8_t devAdr, uint8_t val) {
	i2c_cmd_handle_t cmd = i2c_cmd_link_create();
	i2c_master_start(cmd);
	i2c_master_write_byte(cmd, devAdr << 1 | I2C_MASTER_WRITE, true);
	i2c_master_write_byte(cmd, val, true);
	i2c_master_stop(cmd);
	int ret = i2c_master_cmd_begin(I2C::I2C_NUMBER, cmd, 1000 / portTICK_RATE_MS);
	i2c_cmd_link_delete(cmd);
	return (ret == ESP_OK);
}

bool I2CDev::writeReg(uint8_t devAdr, uint8_t val) {
	lock();
	bool ret = _writeReg(devAdr, val);
	unlock();
	return ret;
}

bool I2CDev::_writeReg2(uint8_t devAdr, uint8_t val1, uint8_t val2) {
	i2c_cmd_handle_t cmd = i2c_cmd_link_create();
	i2c_master_start(cmd);
	i2c_master_write_byte(cmd, devAdr << 1 | I2C_MASTER_WRITE, true);
	i2c_master_write_byte(cmd, val1, true);
	i2c_master_write_byte(cmd, val2, true);
	i2c_master_stop(cmd);
	int ret = i2c_master_cmd_begin(I2C::I2C_NUMBER, cmd, 1000 / portTICK_RATE_MS);
	i2c_cmd_link_delete(cmd);
	return (ret == ESP_OK);
}

bool I2CDev::writeReg2(uint8_t devAdr, uint8_t val1, uint8_t val2) {
	lock();
	bool ret = _writeReg2(devAdr, val1, val2);
	unlock();
	return ret;
}

bool I2CDev::_readReg(uint8_t devAdr, uint8_t *tab, uint8_t cnt) {
	i2c_cmd_handle_t cmd = i2c_cmd_link_create();
	i2c_master_start(cmd);
	i2c_master_write_byte(cmd, devAdr << 1 | I2C_MASTER_READ, true);
	i2c_master_read(cmd, tab, cnt, I2C_MASTER_ACK);
	i2c_master_stop(cmd);
	int ret = i2c_master_cmd_begin(I2C::I2C_NUMBER, cmd, 1000 / portTICK_RATE_MS);
	i2c_cmd_link_delete(cmd);
	return (ret == ESP_OK);
}

bool I2CDev::readReg(uint8_t devAdr, uint8_t *tab, uint8_t cnt) {
	lock();
	bool ret = _readReg(devAdr, tab, cnt);
	unlock();
	return ret;

}
