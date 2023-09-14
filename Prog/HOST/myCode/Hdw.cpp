/*
 * Hdw.cpp
 *
 *  Created on: 11 mar 2021
 *      Author: Grzegorz
 */

#include <Hdw.h>

//-------------------------------------------------------------------------------------
// Hdw
//-------------------------------------------------------------------------------------

void Hdw::setPinAnsInpNoPull(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin) {
	GPIO_InitTypeDef R = {
			0 };
	R.Pin = GPIO_Pin;
	R.Mode = GPIO_MODE_INPUT;
	R.Pull = GPIO_NOPULL;
	R.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOx, &R);
}

void Hdw::setPinAnsInpPullUp(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin) {
	GPIO_InitTypeDef R = {
			0 };
	R.Pin = GPIO_Pin;
	R.Mode = GPIO_MODE_INPUT;
	R.Pull = GPIO_PULLUP;
	R.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOx, &R);
}

void Hdw::setPinAnsInpPullDn(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin) {
	GPIO_InitTypeDef R = {
			0 };
	R.Pin = GPIO_Pin;
	R.Mode = GPIO_MODE_INPUT;
	R.Pull = GPIO_PULLDOWN;
	R.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOx, &R);
}

ST3 Hdw::getPinCfg(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin) {
	setPinAnsInpPullUp(GPIOx, GPIO_Pin);
	bool qu = HAL_GPIO_ReadPin(GPIOx, GPIO_Pin);
	setPinAnsInpPullDn(GPIOx, GPIO_Pin);
	bool qd = HAL_GPIO_ReadPin(GPIOx, GPIO_Pin);
	setPinAnsInpNoPull(GPIOx, GPIO_Pin);
	if (qu & qd)
		return posVCC;
	if (!qu & !qd)
		return posGND;
	return posFREE;

}

void Hdw::led1(bool q) {
	if (q)
		HAL_GPIO_WritePin(LED1_GPIO_Port, LED1_Pin, GPIO_PIN_RESET);
	else
		HAL_GPIO_WritePin(LED1_GPIO_Port, LED1_Pin, GPIO_PIN_SET);
}

void Hdw::led2(bool q) {
	if (q)
		HAL_GPIO_WritePin(LED2_GPIO_Port, LED2_Pin, GPIO_PIN_RESET);
	else
		HAL_GPIO_WritePin(LED2_GPIO_Port, LED2_Pin, GPIO_PIN_SET);
}

void Hdw::phyReset(bool activ) {
	if (activ)
		HAL_GPIO_WritePin(ETH_RST_GPIO_Port, ETH_RST_Pin, GPIO_PIN_RESET);
	else
		HAL_GPIO_WritePin(ETH_RST_GPIO_Port, ETH_RST_Pin, GPIO_PIN_SET);
}

bool Hdw::getKey1() {
	return (HAL_GPIO_ReadPin(KY1_GPIO_Port, KY1_Pin) == GPIO_PIN_RESET);
}

bool Hdw::getInp1() {
	return (HAL_GPIO_ReadPin(INP1_GPIO_Port, INP1_Pin) == GPIO_PIN_RESET);
}
bool Hdw::getInp2() {
	return (HAL_GPIO_ReadPin(INP2_GPIO_Port, INP2_Pin) == GPIO_PIN_RESET);
}

bool Hdw::rdPanelIrq() {
	return (HAL_GPIO_ReadPin(KY_IRQ_GPIO_Port, KY_IRQ_Pin) == GPIO_PIN_RESET);
}

void Hdw::setPk(int pknr, bool q) {
	switch (pknr) {
	case 0:
		if (q)
			HAL_GPIO_WritePin(PKI1_GPIO_Port, PKI1_Pin, GPIO_PIN_SET);
		else
			HAL_GPIO_WritePin(PKI1_GPIO_Port, PKI1_Pin, GPIO_PIN_RESET);
		break;
	case 1:
		if (q)
			HAL_GPIO_WritePin(PKI2_GPIO_Port, PKI2_Pin, GPIO_PIN_SET);
		else
			HAL_GPIO_WritePin(PKI2_GPIO_Port, PKI2_Pin, GPIO_PIN_RESET);
		break;
	case 2:
		if (q)
			HAL_GPIO_WritePin(PKI3_GPIO_Port, PKI3_Pin, GPIO_PIN_SET);
		else
			HAL_GPIO_WritePin(PKI3_GPIO_Port, PKI3_Pin, GPIO_PIN_RESET);
		break;
	case 3:
		if (q)
			HAL_GPIO_WritePin(PKI4_GPIO_Port, PKI4_Pin, GPIO_PIN_SET);
		else
			HAL_GPIO_WritePin(PKI4_GPIO_Port, PKI4_Pin, GPIO_PIN_RESET);
		break;
	case 4:
		if (q)
			HAL_GPIO_WritePin(PKI5_GPIO_Port, PKI5_Pin, GPIO_PIN_SET);
		else
			HAL_GPIO_WritePin(PKI5_GPIO_Port, PKI5_Pin, GPIO_PIN_RESET);
		break;
	case 5:
		if (q)
			HAL_GPIO_WritePin(PKI6_GPIO_Port, PKI6_Pin, GPIO_PIN_SET);
		else
			HAL_GPIO_WritePin(PKI6_GPIO_Port, PKI6_Pin, GPIO_PIN_RESET);
		break;
	case 6:
		if (q)
			HAL_GPIO_WritePin(PKI7_GPIO_Port, PKI7_Pin, GPIO_PIN_SET);
		else
			HAL_GPIO_WritePin(PKI7_GPIO_Port, PKI7_Pin, GPIO_PIN_RESET);
		break;
	case 7:
		if (q)
			HAL_GPIO_WritePin(PKI8_GPIO_Port, PKI8_Pin, GPIO_PIN_SET);
		else
			HAL_GPIO_WritePin(PKI8_GPIO_Port, PKI8_Pin, GPIO_PIN_RESET);
		break;
	}
}

bool Hdw::getPK(int pknr) {
	GPIO_PinState st = GPIO_PIN_RESET;
	switch (pknr) {
	case 1:
		st = HAL_GPIO_ReadPin(PKI1_GPIO_Port, PKI1_Pin);
		break;
	case 2:
		st = HAL_GPIO_ReadPin(PKI2_GPIO_Port, PKI2_Pin);
		break;
	case 3:
		st = HAL_GPIO_ReadPin(PKI3_GPIO_Port, PKI3_Pin);
		break;
	case 4:
		st = HAL_GPIO_ReadPin(PKI4_GPIO_Port, PKI4_Pin);
		break;
	case 5:
		st = HAL_GPIO_ReadPin(PKI5_GPIO_Port, PKI5_Pin);
		break;
	case 6:
		st = HAL_GPIO_ReadPin(PKI6_GPIO_Port, PKI6_Pin);
		break;
	case 7:
		st = HAL_GPIO_ReadPin(PKI7_GPIO_Port, PKI7_Pin);
		break;
	case 8:
		st = HAL_GPIO_ReadPin(PKI8_GPIO_Port, PKI8_Pin);
		break;
	}
	return (st != GPIO_PIN_RESET);
}

uint8_t Hdw::getPKs() {
	uint8_t b = 0;
	for (int i = 0; i < 8; i++) {
		if (getPK(i))
			b |= (1 << i);
	}
	return b;
}

void Hdw::setBuzzer(bool state) {
	if (state)
		HAL_GPIO_WritePin(BUZZER_GPIO_Port, BUZZER_Pin, GPIO_PIN_SET);
	else
		HAL_GPIO_WritePin(BUZZER_GPIO_Port, BUZZER_Pin, GPIO_PIN_RESET);
}

