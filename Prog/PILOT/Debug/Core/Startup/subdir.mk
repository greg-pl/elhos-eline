################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
../Core/Startup/startup_stm32l031k6ux.s 

S_DEPS += \
./Core/Startup/startup_stm32l031k6ux.d 

OBJS += \
./Core/Startup/startup_stm32l031k6ux.o 


# Each subdirectory must supply rules for building sources it contributes
Core/Startup/startup_stm32l031k6ux.o: ../Core/Startup/startup_stm32l031k6ux.s
	arm-none-eabi-gcc -mcpu=cortex-m0plus -g3 -c -I../myCode -I"Y:/A_Track/PROG/Common/RFM69" -x assembler-with-cpp -MMD -MP -MF"Core/Startup/startup_stm32l031k6ux.d" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@" "$<"

