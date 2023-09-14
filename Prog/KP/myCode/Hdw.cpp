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
uint8_t Hdw::mDinMode = 0xff;

void Hdw::setPinAsInpNoPull(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin) {
	GPIO_InitTypeDef R = {
			0 };
	R.Pin = GPIO_Pin;
	R.Mode = GPIO_MODE_INPUT;
	R.Pull = GPIO_NOPULL;
	R.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOx, &R);
}

void Hdw::setPinAsInpPullUp(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin) {
	GPIO_InitTypeDef R = {
			0 };
	R.Pin = GPIO_Pin;
	R.Mode = GPIO_MODE_INPUT;
	R.Pull = GPIO_PULLUP;
	R.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOx, &R);
}

void Hdw::setPinAsInpPullDn(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin) {
	GPIO_InitTypeDef R = {
			0 };
	R.Pin = GPIO_Pin;
	R.Mode = GPIO_MODE_INPUT;
	R.Pull = GPIO_PULLDOWN;
	R.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOx, &R);
}

void Hdw::setPinAsOutputPP(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin) {
	GPIO_InitTypeDef R = {
			0 };
	R.Pin = GPIO_Pin;
	R.Mode = GPIO_MODE_OUTPUT_PP;
	R.Pull = GPIO_NOPULL;
	R.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOx, &R);
}

ST3 Hdw::getPinCfg(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin) {
	setPinAsInpPullUp(GPIOx, GPIO_Pin);
	bool qu = HAL_GPIO_ReadPin(GPIOx, GPIO_Pin);
	setPinAsInpPullDn(GPIOx, GPIO_Pin);
	bool qd = HAL_GPIO_ReadPin(GPIOx, GPIO_Pin);
	setPinAsInpNoPull(GPIOx, GPIO_Pin);
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

typedef struct {
	GPIO_TypeDef *port;
	uint16_t pin;
} PinDef;

const PinDef PLOutTab[] = { //
		{ PL0_GPIO_Port, PL0_Pin }, //
		{ PL1_GPIO_Port, PL1_Pin }, //
		{ PL2_GPIO_Port, PL2_Pin }, //
		{ PL3_GPIO_Port, PL3_Pin }, //
		{ PL4_GPIO_Port, PL4_Pin }, //
		{ PL5_GPIO_Port, PL5_Pin }, //
		{ PL6_GPIO_Port, PL6_Pin }, //
		{ PL7_GPIO_Port, PL7_Pin }, //
		};

void Hdw::setPL(int pknr, bool q) {
	if (pknr >= 0 && pknr < AN_CNT) {
		if (q)
			HAL_GPIO_WritePin(PLOutTab[pknr].port, PLOutTab[pknr].pin, GPIO_PIN_SET);
		else
			HAL_GPIO_WritePin(PLOutTab[pknr].port, PLOutTab[pknr].pin, GPIO_PIN_RESET);
	}
}

bool Hdw::getPL(int pknr) {
	GPIO_PinState st = GPIO_PIN_RESET;
	if (pknr >= 0 && pknr < AN_CNT) {
		st = HAL_GPIO_ReadPin(PLOutTab[pknr].port, PLOutTab[pknr].pin);
	}
	return (st != GPIO_PIN_RESET);

}
uint8_t Hdw::getPLs() {
	uint8_t b = 0;
	for (int i = 0; i < AN_CNT; i++) {
		if (getPL(i))
			b |= (1 << i);
	}
	return b;
}

const PinDef JmpTab[] = { //
		{ JP1_GPIO_Port, JP1_Pin }, //
		{ JP2_GPIO_Port, JP2_Pin }, //
		{ JP3_GPIO_Port, JP3_Pin }, //
		{ JP4_GPIO_Port, JP4_Pin }, //
		};

uint8_t Hdw::getJMP() {
	uint8_t b = 0;
	for (int i = 0; i < 4; i++) {
		if (HAL_GPIO_ReadPin(JmpTab[i].port, JmpTab[i].pin) == GPIO_PIN_RESET)
			b |= (1 << i);
	}
	return b;
}

const PinDef DgInpTab[] = { //
		{ ADC_DD0_GPIO_Port, ADC_DD0_Pin }, //
		{ ADC_DD1_GPIO_Port, ADC_DD1_Pin }, //
		{ ADC_DD2_GPIO_Port, ADC_DD2_Pin }, //
		{ ADC_DD3_GPIO_Port, ADC_DD3_Pin }, //
		{ ADC_DD4_GPIO_Port, ADC_DD4_Pin }, //
		{ ADC_DD5_GPIO_Port, ADC_DD5_Pin }, //
		{ ADC_DD6_GPIO_Port, ADC_DD6_Pin }, //
		{ ADC_DD7_GPIO_Port, ADC_DD7_Pin }, //
		};

void Hdw::setDINAsAnalog(int inpNr, bool asAnalog) {
	if (inpNr >= 0 && inpNr < DIN_CNT) {
		GPIO_InitTypeDef GPIO_InitStruct = {
				0 };

		GPIO_InitStruct.Pin = DgInpTab[inpNr].pin;
		if (asAnalog)
			GPIO_InitStruct.Mode = GPIO_MODE_ANALOG;
		else
			GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
		GPIO_InitStruct.Pull = GPIO_NOPULL;
		HAL_GPIO_Init(DgInpTab[inpNr].port, &GPIO_InitStruct);

		if (asAnalog)
			mDinMode |= (1 << inpNr);
		else
			mDinMode &= ~(1 << inpNr);
	}
}

void Hdw::setDINAsAnalogs(uint8_t asAnalog) {
	for (int i = 0; i < DIN_CNT; i++) {
		uint8_t mask = 1 << i;
		setDINAsAnalog(i, (asAnalog & mask) != 0);
	}
}

bool Hdw::getDIN(int inpNr) {
	GPIO_PinState st = GPIO_PIN_RESET;
	if (inpNr >= 0 && inpNr < DIN_CNT) {
		st = HAL_GPIO_ReadPin(DgInpTab[inpNr].port, DgInpTab[inpNr].pin);
	}
	return (st != GPIO_PIN_RESET);
}

uint8_t Hdw::getDINs() {
	uint8_t b = 0;
	for (int i = 0; i < DIN_CNT; i++) {
		if (getDIN(i))
			b |= (1 << i);
	}
	return b;
}

//diody LED sgnalizujące wejścia cyfrowe
const PinDef DLOutTab[] = { //
		{ DL0_GPIO_Port, DL0_Pin }, //
		{ DL1_GPIO_Port, DL1_Pin }, //
		{ DL2_GPIO_Port, DL2_Pin }, //
		{ DL3_GPIO_Port, DL3_Pin }, //
		{ DL4_GPIO_Port, DL4_Pin }, //
		{ DL5_GPIO_Port, DL5_Pin }, //
		{ DL6_GPIO_Port, DL6_Pin }, //
		{ DL7_GPIO_Port, DL7_Pin }, //
		};

void Hdw::setDL(int lednr, bool state) {
	if (lednr >= 0 && lednr < DIN_CNT) {
		if (state)
			HAL_GPIO_WritePin(DLOutTab[lednr].port, DLOutTab[lednr].pin, GPIO_PIN_SET);
		else
			HAL_GPIO_WritePin(DLOutTab[lednr].port, DLOutTab[lednr].pin, GPIO_PIN_RESET);
	}
}

void Hdw::setDLs(uint8_t dls) {
	for (int i = 0; i < DIN_CNT; i++) {
		setDL(i, (dls & (1 << i)) != 0);
	}
}

void Hdw::setAcCs(bool cs) {
	if (cs)
		HAL_GPIO_WritePin(AC_CS_GPIO_Port, AC_CS_Pin, GPIO_PIN_RESET);
	else
		HAL_GPIO_WritePin(AC_CS_GPIO_Port, AC_CS_Pin, GPIO_PIN_SET);
}

void Hdw::setJMPAsOut() {
	for (int i = 0; i < 4; i++) {
		setPinAsOutputPP(JmpTab[i].port, JmpTab[i].pin);
	}
}

void Hdw::setJMP(int nr, bool q) {
	if (nr >= 0 && nr < 4) {
		if (q)
			HAL_GPIO_WritePin(JmpTab[nr].port, JmpTab[nr].pin, GPIO_PIN_SET);
		else
			HAL_GPIO_WritePin(JmpTab[nr].port, JmpTab[nr].pin, GPIO_PIN_RESET);
	}
}
