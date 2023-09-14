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
#include "stm32f4xx_hal.h"

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
#define RFM69_SHELL_CHAR 0
#define RFM69_SHELL_CMD  1

/* USER CODE END EM */

/* Exported functions prototypes ---------------------------------------------*/
void Error_Handler(void);

/* USER CODE BEGIN EFP */

/* USER CODE END EFP */

/* Private defines -----------------------------------------------------------*/
#define PKI4_Pin GPIO_PIN_2
#define PKI4_GPIO_Port GPIOE
#define PKI5_Pin GPIO_PIN_3
#define PKI5_GPIO_Port GPIOE
#define PKI6_Pin GPIO_PIN_4
#define PKI6_GPIO_Port GPIOE
#define PKI7_Pin GPIO_PIN_5
#define PKI7_GPIO_Port GPIOE
#define PKI8_Pin GPIO_PIN_6
#define PKI8_GPIO_Port GPIOE
#define R_INT_Pin GPIO_PIN_13
#define R_INT_GPIO_Port GPIOC
#define R_RESET_Pin GPIO_PIN_14
#define R_RESET_GPIO_Port GPIOC
#define BUZZER_Pin GPIO_PIN_15
#define BUZZER_GPIO_Port GPIOC
#define ETH_RST_Pin GPIO_PIN_2
#define ETH_RST_GPIO_Port GPIOC
#define ADC_HD_VER_Pin GPIO_PIN_0
#define ADC_HD_VER_GPIO_Port GPIOA
#define KY1_Pin GPIO_PIN_4
#define KY1_GPIO_Port GPIOA
#define LED2_Pin GPIO_PIN_5
#define LED2_GPIO_Port GPIOA
#define LED1_Pin GPIO_PIN_6
#define LED1_GPIO_Port GPIOA
#define TX48_EN_Pin GPIO_PIN_14
#define TX48_EN_GPIO_Port GPIOB
#define TX48_TX_Pin GPIO_PIN_8
#define TX48_TX_GPIO_Port GPIOD
#define TX48_RX_Pin GPIO_PIN_9
#define TX48_RX_GPIO_Port GPIOD
#define K_IRQ_Pin GPIO_PIN_15
#define K_IRQ_GPIO_Port GPIOD
#define K_TX_Pin GPIO_PIN_6
#define K_TX_GPIO_Port GPIOC
#define K_RX_Pin GPIO_PIN_7
#define K_RX_GPIO_Port GPIOC
#define E_OSC_Pin GPIO_PIN_8
#define E_OSC_GPIO_Port GPIOA
#define DBG_TX_Pin GPIO_PIN_10
#define DBG_TX_GPIO_Port GPIOC
#define DBG_RX_Pin GPIO_PIN_11
#define DBG_RX_GPIO_Port GPIOC
#define INP1_Pin GPIO_PIN_5
#define INP1_GPIO_Port GPIOD
#define INP2_Pin GPIO_PIN_6
#define INP2_GPIO_Port GPIOD
#define R_CS_Pin GPIO_PIN_7
#define R_CS_GPIO_Port GPIOD
#define R_SCK_Pin GPIO_PIN_3
#define R_SCK_GPIO_Port GPIOB
#define R_MISO_Pin GPIO_PIN_4
#define R_MISO_GPIO_Port GPIOB
#define R_MOSI_Pin GPIO_PIN_5
#define R_MOSI_GPIO_Port GPIOB
#define KY_IRQ_Pin GPIO_PIN_8
#define KY_IRQ_GPIO_Port GPIOB
#define PKI1_Pin GPIO_PIN_9
#define PKI1_GPIO_Port GPIOB
#define PKI2_Pin GPIO_PIN_0
#define PKI2_GPIO_Port GPIOE
#define PKI3_Pin GPIO_PIN_1
#define PKI3_GPIO_Port GPIOE
/* USER CODE BEGIN Private defines */

/* USER CODE END Private defines */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
