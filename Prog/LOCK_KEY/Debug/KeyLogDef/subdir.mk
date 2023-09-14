################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
Y:/A_Track/PROG/Common/KeyLogDef/KeyLogDef.c 

OBJS += \
./KeyLogDef/KeyLogDef.o 

C_DEPS += \
./KeyLogDef/KeyLogDef.d 


# Each subdirectory must supply rules for building sources it contributes
KeyLogDef/KeyLogDef.o: Y:/A_Track/PROG/Common/KeyLogDef/KeyLogDef.c
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32L011xx -DDEBUG -c -I../Core/Inc -I../Drivers/STM32L0xx_HAL_Driver/Inc -I../Drivers/STM32L0xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32L0xx/Include -I../Drivers/CMSIS/Include -I../myCode -I"Y:/A_Track/PROG/Common/KeyLogDef" -O1 -ffunction-sections -fdata-sections -Wall -fstack-usage -MMD -MP -MF"KeyLogDef/KeyLogDef.d" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

