################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (10.3-2021.10)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../myCode/UMain.cpp \
../myCode/dbgUart.cpp 

OBJS += \
./myCode/UMain.o \
./myCode/dbgUart.o 

CPP_DEPS += \
./myCode/UMain.d \
./myCode/dbgUart.d 


# Each subdirectory must supply rules for building sources it contributes
myCode/%.o myCode/%.su: ../myCode/%.cpp myCode/subdir.mk
	arm-none-eabi-g++ "$<" -mcpu=cortex-m3 -std=gnu++14 -g3 -DUSE_HAL_DRIVER -DSTM32F103xB -DDEBUG -c -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -I../USB_DEVICE/App -I../USB_DEVICE/Target -I../Middlewares/ST/STM32_USB_Device_Library/Core/Inc -I../myCode -I../Middlewares/ST/STM32_USB_Device_Library/Class/CDC/Inc -I"D:/!!Work/A_eLine/Prog/Dongle/Middlewares/ST/STM32_USB_Device_Library/Class/WINUSB/Inc" -O0 -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti -fno-use-cxa-atexit -Wall -fstack-usage -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-myCode

clean-myCode:
	-$(RM) ./myCode/UMain.d ./myCode/UMain.o ./myCode/UMain.su ./myCode/dbgUart.d ./myCode/dbgUart.o ./myCode/dbgUart.su

.PHONY: clean-myCode

