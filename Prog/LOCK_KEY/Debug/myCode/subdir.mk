################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../myCode/CrcFunc.c \
../myCode/UMain.c 

OBJS += \
./myCode/CrcFunc.o \
./myCode/UMain.o 

C_DEPS += \
./myCode/CrcFunc.d \
./myCode/UMain.d 


# Each subdirectory must supply rules for building sources it contributes
myCode/CrcFunc.o: ../myCode/CrcFunc.c
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32L011xx -DDEBUG -c -I../Core/Inc -I../Drivers/STM32L0xx_HAL_Driver/Inc -I../Drivers/STM32L0xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32L0xx/Include -I../Drivers/CMSIS/Include -I../myCode -I"Y:/A_Track/PROG/Common/KeyLogDef" -O1 -ffunction-sections -fdata-sections -Wall -fstack-usage -MMD -MP -MF"myCode/CrcFunc.d" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
myCode/UMain.o: ../myCode/UMain.c
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32L011xx -DDEBUG -c -I../Core/Inc -I../Drivers/STM32L0xx_HAL_Driver/Inc -I../Drivers/STM32L0xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32L0xx/Include -I../Drivers/CMSIS/Include -I../myCode -I"Y:/A_Track/PROG/Common/KeyLogDef" -O1 -ffunction-sections -fdata-sections -Wall -fstack-usage -MMD -MP -MF"myCode/UMain.d" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

