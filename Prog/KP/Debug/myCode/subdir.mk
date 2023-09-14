################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (9-2020-q2-update)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../myCode/Config.cpp \
../myCode/Engine.cpp \
../myCode/Hdw.cpp \
../myCode/KpProcessObj.cpp \
../myCode/ShellInterpreter.cpp \
../myCode/UMain.cpp 

OBJS += \
./myCode/Config.o \
./myCode/Engine.o \
./myCode/Hdw.o \
./myCode/KpProcessObj.o \
./myCode/ShellInterpreter.o \
./myCode/UMain.o 

CPP_DEPS += \
./myCode/Config.d \
./myCode/Engine.d \
./myCode/Hdw.d \
./myCode/KpProcessObj.d \
./myCode/ShellInterpreter.d \
./myCode/UMain.d 


# Each subdirectory must supply rules for building sources it contributes
myCode/%.o: ../myCode/%.cpp myCode/subdir.mk
	arm-none-eabi-g++ "$<" -mcpu=cortex-m4 -std=gnu++14 -g3 -DSTM32F427xx -DUSE_HAL_DRIVER -DDEBUG -c -I../Core/Inc -I../LWIP/App -I../LWIP/Target -I../Middlewares/Third_Party/LwIP/src/include -I../Middlewares/Third_Party/LwIP/system -I../Drivers/STM32F4xx_HAL_Driver/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc/Legacy -I../Middlewares/Third_Party/FreeRTOS/Source/include -I../Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS -I../Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F -I../Middlewares/Third_Party/LwIP/src/include/netif/ppp -I../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../Middlewares/Third_Party/LwIP/src/include/lwip -I../Middlewares/Third_Party/LwIP/src/include/lwip/apps -I../Middlewares/Third_Party/LwIP/src/include/lwip/priv -I../Middlewares/Third_Party/LwIP/src/include/lwip/prot -I../Middlewares/Third_Party/LwIP/src/include/netif -I../Middlewares/Third_Party/LwIP/src/include/compat/posix -I../Middlewares/Third_Party/LwIP/src/include/compat/posix/arpa -I../Middlewares/Third_Party/LwIP/src/include/compat/posix/net -I../Middlewares/Third_Party/LwIP/src/include/compat/posix/sys -I../Middlewares/Third_Party/LwIP/src/include/compat/stdc -I../Middlewares/Third_Party/LwIP/system/arch -I../Drivers/CMSIS/Include -I../myCode -I"Y:/A_Track/PROG/Common/KpHost" -I"Y:/A_Track/PROG/Common/KpHost/Interf" -I"Y:/A_Track/PROG/Common/ssd1306" -I"Y:/A_Track/PROG/Common/Tags" -I"Y:/A_Track/PROG/Common/TrackObj" -O0 -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti -fno-use-cxa-atexit -Wall -fstack-usage -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

