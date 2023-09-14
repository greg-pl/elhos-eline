/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.h
  * @brief          : Header for main.c file.
  *                   This file contains the common defines of the application.
  ******************************************************************************
  * @attention
  *
  * <h2><center>&copy; Copyright (c) 2020 STMicroelectronics.
  * All rights reserved.</center></h2>
  *
  * This software component is licensed by ST under Ultimate Liberty license
  * SLA0044, the "License"; You may not use this file except in compliance with
  * the License. You may obtain a copy of the License at:
  *                             www.st.com/SLA0044
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

/* USER CODE END EM */

/* Exported functions prototypes ---------------------------------------------*/
void Error_Handler(void);

/* USER CODE BEGIN EFP */

/* USER CODE END EFP */

/* Private defines -----------------------------------------------------------*/
#define KY1_Pin GPIO_PIN_13
#define KY1_GPIO_Port GPIOC
#define ADC_DD0_Pin GPIO_PIN_0
#define ADC_DD0_GPIO_Port GPIOC
#define ETH_RST_Pin GPIO_PIN_2
#define ETH_RST_GPIO_Port GPIOC
#define ADC_DD1_Pin GPIO_PIN_0
#define ADC_DD1_GPIO_Port GPIOA
#define ADC_DD2_Pin GPIO_PIN_3
#define ADC_DD2_GPIO_Port GPIOA
#define ADC_DD3_Pin GPIO_PIN_4
#define ADC_DD3_GPIO_Port GPIOA
#define ADC_DD4_Pin GPIO_PIN_5
#define ADC_DD4_GPIO_Port GPIOA
#define ADC_DD5_Pin GPIO_PIN_6
#define ADC_DD5_GPIO_Port GPIOA
#define ADC_DD6_Pin GPIO_PIN_0
#define ADC_DD6_GPIO_Port GPIOB
#define ADC_DD7_Pin GPIO_PIN_1
#define ADC_DD7_GPIO_Port GPIOB
#define DL2_Pin GPIO_PIN_9
#define DL2_GPIO_Port GPIOE
#define DL3_Pin GPIO_PIN_10
#define DL3_GPIO_Port GPIOE
#define DL4_Pin GPIO_PIN_11
#define DL4_GPIO_Port GPIOE
#define DL5_Pin GPIO_PIN_12
#define DL5_GPIO_Port GPIOE
#define DL6_Pin GPIO_PIN_13
#define DL6_GPIO_Port GPIOE
#define DL7_Pin GPIO_PIN_14
#define DL7_GPIO_Port GPIOE
#define DL1_Pin GPIO_PIN_15
#define DL1_GPIO_Port GPIOE
#define DL0_Pin GPIO_PIN_10
#define DL0_GPIO_Port GPIOB
#define D_TXD_Pin GPIO_PIN_8
#define D_TXD_GPIO_Port GPIOD
#define D_RXD_Pin GPIO_PIN_9
#define D_RXD_GPIO_Port GPIOD
#define JP1_Pin GPIO_PIN_10
#define JP1_GPIO_Port GPIOD
#define JP2_Pin GPIO_PIN_11
#define JP2_GPIO_Port GPIOD
#define JP3_Pin GPIO_PIN_12
#define JP3_GPIO_Port GPIOD
#define JP4_Pin GPIO_PIN_13
#define JP4_GPIO_Port GPIOD
#define ETH_OSC_Pin GPIO_PIN_8
#define ETH_OSC_GPIO_Port GPIOA
#define LED2_Pin GPIO_PIN_9
#define LED2_GPIO_Port GPIOA
#define LED1_Pin GPIO_PIN_10
#define LED1_GPIO_Port GPIOA
#define AC_CS_Pin GPIO_PIN_15
#define AC_CS_GPIO_Port GPIOA
#define PL7_Pin GPIO_PIN_11
#define PL7_GPIO_Port GPIOC
#define PL6_Pin GPIO_PIN_12
#define PL6_GPIO_Port GPIOC
#define PL5_Pin GPIO_PIN_0
#define PL5_GPIO_Port GPIOD
#define PL4_Pin GPIO_PIN_1
#define PL4_GPIO_Port GPIOD
#define PL3_Pin GPIO_PIN_2
#define PL3_GPIO_Port GPIOD
#define PL2_Pin GPIO_PIN_3
#define PL2_GPIO_Port GPIOD
#define PL1_Pin GPIO_PIN_4
#define PL1_GPIO_Port GPIOD
#define PL0_Pin GPIO_PIN_5
#define PL0_GPIO_Port GPIOD
#define AC_SHDN_Pin GPIO_PIN_6
#define AC_SHDN_GPIO_Port GPIOD
#define AC_BUSY_Pin GPIO_PIN_7
#define AC_BUSY_GPIO_Port GPIOD
/* USER CODE BEGIN Private defines */

/* USER CODE END Private defines */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
