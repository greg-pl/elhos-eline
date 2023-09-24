################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (10.3-2021.10)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../USB_DEVICE/App/usb_device.c \
../USB_DEVICE/App/usbd_cdc_if.c \
../USB_DEVICE/App/usbd_desc.c \
../USB_DEVICE/App/usbd_desc_winusb.c \
../USB_DEVICE/App/usbd_winusb_if.c 

C_DEPS += \
./USB_DEVICE/App/usb_device.d \
./USB_DEVICE/App/usbd_cdc_if.d \
./USB_DEVICE/App/usbd_desc.d \
./USB_DEVICE/App/usbd_desc_winusb.d \
./USB_DEVICE/App/usbd_winusb_if.d 

OBJS += \
./USB_DEVICE/App/usb_device.o \
./USB_DEVICE/App/usbd_cdc_if.o \
./USB_DEVICE/App/usbd_desc.o \
./USB_DEVICE/App/usbd_desc_winusb.o \
./USB_DEVICE/App/usbd_winusb_if.o 


# Each subdirectory must supply rules for building sources it contributes
USB_DEVICE/App/%.o USB_DEVICE/App/%.su: ../USB_DEVICE/App/%.c USB_DEVICE/App/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DUSE_HAL_DRIVER -DSTM32F103xB -DDEBUG -c -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -I../USB_DEVICE/App -I../USB_DEVICE/Target -I../Middlewares/ST/STM32_USB_Device_Library/Core/Inc -I../myCode -I../Middlewares/ST/STM32_USB_Device_Library/Class/CDC/Inc -I"D:/!!Work/A_eLine/Prog/Dongle/Middlewares/ST/STM32_USB_Device_Library/Class/WINUSB/Inc" -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-USB_DEVICE-2f-App

clean-USB_DEVICE-2f-App:
	-$(RM) ./USB_DEVICE/App/usb_device.d ./USB_DEVICE/App/usb_device.o ./USB_DEVICE/App/usb_device.su ./USB_DEVICE/App/usbd_cdc_if.d ./USB_DEVICE/App/usbd_cdc_if.o ./USB_DEVICE/App/usbd_cdc_if.su ./USB_DEVICE/App/usbd_desc.d ./USB_DEVICE/App/usbd_desc.o ./USB_DEVICE/App/usbd_desc.su ./USB_DEVICE/App/usbd_desc_winusb.d ./USB_DEVICE/App/usbd_desc_winusb.o ./USB_DEVICE/App/usbd_desc_winusb.su ./USB_DEVICE/App/usbd_winusb_if.d ./USB_DEVICE/App/usbd_winusb_if.o ./USB_DEVICE/App/usbd_winusb_if.su

.PHONY: clean-USB_DEVICE-2f-App

