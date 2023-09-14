/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.h
  * @brief          : Header for main.c file.
  *                   This file contains the common defines of the application.
  ******************************************************************************
  * @attention
  *
  * <h2><center>&copy; Copyright (c) 2021 STMicroelectronics.
  * All rights reserved.</center></h2>
  *
  * This software component is licensed by ST under BSD 3-Clause license,
  * the "License"; You may not use this file except in compliance with the
  * License. You may obtain a copy of the License at:
  *                        opensource.org/licenses/BSD-3-Clause
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __MAIN_H
#define __MAIN_H

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "stm32l0xx_hal.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Exported types ------------------------------------------------------------*/
/* USER CODE BEGIN ET */

/* USER CODE END ET */

/* Exported constants --------------------------------------------------------*/
/* USER CODE BEGIN EC */

/* USER CODE END EC */

/* Exported macro ------------------------------------------------------------*/
/* USER CODE BEGIN EM */

/* USER CODE END EM */

/* Exported functions prototypes ---------------------------------------------*/
void Error_Handler(void);

/* USER CODE BEGIN EFP */

/* USER CODE END EFP */

/* Private defines -----------------------------------------------------------*/
#define ROW1_Pin GPIO_PIN_0
#define ROW1_GPIO_Port GPIOA
#define ROW2_Pin GPIO_PIN_2
#define ROW2_GPIO_Port GPIOA
#define R_RESET_Pin GPIO_PIN_3
#define R_RESET_GPIO_Port GPIOA
#define R_INT_Pin GPIO_PIN_4
#define R_INT_GPIO_Port GPIOA
#define R_SCK_Pin GPIO_PIN_5
#define R_SCK_GPIO_Port GPIOA
#define R_MISO_Pin GPIO_PIN_6
#define R_MISO_GPIO_Port GPIOA
#define R_MOSI_Pin GPIO_PIN_7
#define R_MOSI_GPIO_Port GPIOA
#define R_CS_Pin GPIO_PIN_0
#define R_CS_GPIO_Port GPIOB
#define COL5_Pin GPIO_PIN_8
#define COL5_GPIO_Port GPIOA
#define COL4_Pin GPIO_PIN_9
#define COL4_GPIO_Port GPIOA
#define COL3_Pin GPIO_PIN_10
#define COL3_GPIO_Port GPIOA
#define COL2_Pin GPIO_PIN_11
#define COL2_GPIO_Port GPIOA
#define COL1_Pin GPIO_PIN_12
#define COL1_GPIO_Port GPIOA
#define LED1_Pin GPIO_PIN_15
#define LED1_GPIO_Port GPIOA
#define GND1_Pin GPIO_PIN_4
#define GND1_GPIO_Port GPIOB
#define GND2_Pin GPIO_PIN_5
#define GND2_GPIO_Port GPIOB
#define PIN_TX_Pin GPIO_PIN_6
#define PIN_TX_GPIO_Port GPIOB
#define PIN_RX_Pin GPIO_PIN_7
#define PIN_RX_GPIO_Port GPIOB

/* USER CODE BEGIN Private defines */

/* USER CODE END Private defines */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */
