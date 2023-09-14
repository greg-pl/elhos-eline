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
#include "stm32f1xx_hal.h"

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
#define RFM69_SHELL_CHAR 1
#define RFM69_SHELL_CMD  0


/* USER CODE END EM */

/* Exported functions prototypes ---------------------------------------------*/
void Error_Handler(void);

/* USER CODE BEGIN EFP */

/* USER CODE END EFP */

/* Private defines -----------------------------------------------------------*/
#define RST_F_Pin GPIO_PIN_1
#define RST_F_GPIO_Port GPIOA
#define CS_F_Pin GPIO_PIN_2
#define CS_F_GPIO_Port GPIOA
#define ES_RST_Pin GPIO_PIN_4
#define ES_RST_GPIO_Port GPIOC
#define ES_GP0_Pin GPIO_PIN_5
#define ES_GP0_GPIO_Port GPIOC
#define ES_PD_Pin GPIO_PIN_0
#define ES_PD_GPIO_Port GPIOB
#define ES_GP2_Pin GPIO_PIN_1
#define ES_GP2_GPIO_Port GPIOB
#define ES_RXD_Pin GPIO_PIN_10
#define ES_RXD_GPIO_Port GPIOB
#define ES_TXD_Pin GPIO_PIN_11
#define ES_TXD_GPIO_Port GPIOB
#define USB_ON_Pin GPIO_PIN_12
#define USB_ON_GPIO_Port GPIOB
#define L_CPU4_Pin GPIO_PIN_13
#define L_CPU4_GPIO_Port GPIOB
#define L_CPU3_Pin GPIO_PIN_14
#define L_CPU3_GPIO_Port GPIOB
#define L_CPU2_Pin GPIO_PIN_15
#define L_CPU2_GPIO_Port GPIOB
#define L_CPU1_Pin GPIO_PIN_6
#define L_CPU1_GPIO_Port GPIOC
#define TEST2_Pin GPIO_PIN_7
#define TEST2_GPIO_Port GPIOC
#define TEST1_Pin GPIO_PIN_8
#define TEST1_GPIO_Port GPIOC
#define L_PC_Pin GPIO_PIN_9
#define L_PC_GPIO_Port GPIOC
#define TXD0_Pin GPIO_PIN_9
#define TXD0_GPIO_Port GPIOA
#define RXD0_Pin GPIO_PIN_10
#define RXD0_GPIO_Port GPIOA
#define LED2_Pin GPIO_PIN_10
#define LED2_GPIO_Port GPIOC
#define LED1_Pin GPIO_PIN_11
#define LED1_GPIO_Port GPIOC
#define R_INT_Pin GPIO_PIN_5
#define R_INT_GPIO_Port GPIOB
#define R_CS_Pin GPIO_PIN_6
#define R_CS_GPIO_Port GPIOB
#define R_RESET_Pin GPIO_PIN_7
#define R_RESET_GPIO_Port GPIOB
/* USER CODE BEGIN Private defines */

/* USER CODE END Private defines */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
