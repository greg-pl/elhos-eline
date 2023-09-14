################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (9-2020-q2-update)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
../Core/Startup/startup_stm32f427vgtx.s 

S_DEPS += \
./Core/Startup/startup_stm32f427vgtx.d 

OBJS += \
./Core/Startup/startup_stm32f427vgtx.o 


# Each subdirectory must supply rules for building sources it contributes
Core/Startup/%.o: ../Core/Startup/%.s Core/Startup/subdir.mk
	arm-none-eabi-gcc -mcpu=cortex-m4 -g3 -c -I../myCode -I"Y:/A_Track/PROG/Common/KpHost" -I"Y:/A_Track/PROG/Common/KpHost/Interf" -I"Y:/A_Track/PROG/Common/ssd1306" -I"Y:/A_Track/PROG/Common/Tags" -I"Y:/A_Track/PROG/Common/TrackObj" -x assembler-with-cpp -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@" "$<"

