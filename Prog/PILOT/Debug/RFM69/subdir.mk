################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
Y:/A_Track/PROG/Common/RFM69/RFM69.cpp \
Y:/A_Track/PROG/Common/RFM69/RadioTypes.cpp 

OBJS += \
./RFM69/RFM69.o \
./RFM69/RadioTypes.o 

CPP_DEPS += \
./RFM69/RFM69.d \
./RFM69/RadioTypes.d 


# Each subdirectory must supply rules for building sources it contributes
RFM69/RFM69.o: Y:/A_Track/PROG/Common/RFM69/RFM69.cpp
	arm-none-eabi-g++ "$<" -mcpu=cortex-m0plus -std=gnu++14 -g3 -DUSE_HAL_DRIVER -DSTM32L031xx -DDEBUG -c -I../Core/Inc -I../Drivers/STM32L0xx_HAL_Driver/Inc -I../Drivers/STM32L0xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32L0xx/Include -I../Drivers/CMSIS/Include -I../myCode -I"Y:/A_Track/PROG/Common/RFM69" -O0 -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti -fno-threadsafe-statics -fno-use-cxa-atexit -Wall -fstack-usage -MMD -MP -MF"RFM69/RFM69.d" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
RFM69/RadioTypes.o: Y:/A_Track/PROG/Common/RFM69/RadioTypes.cpp
	arm-none-eabi-g++ "$<" -mcpu=cortex-m0plus -std=gnu++14 -g3 -DUSE_HAL_DRIVER -DSTM32L031xx -DDEBUG -c -I../Core/Inc -I../Drivers/STM32L0xx_HAL_Driver/Inc -I../Drivers/STM32L0xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32L0xx/Include -I../Drivers/CMSIS/Include -I../myCode -I"Y:/A_Track/PROG/Common/RFM69" -O0 -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti -fno-threadsafe-statics -fno-use-cxa-atexit -Wall -fstack-usage -MMD -MP -MF"RFM69/RadioTypes.d" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

