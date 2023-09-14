################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include myCode/subdir.mk
-include KeyLogDef/subdir.mk
-include Drivers/STM32L0xx_HAL_Driver/Src/subdir.mk
-include Core/Startup/subdir.mk
-include Core/Src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(S_DEPS)),)
-include $(S_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
EXECUTABLES += \
LOCK_KEY.elf \

SIZE_OUTPUT += \
default.size.stdout \

OBJDUMP_LIST += \
LOCK_KEY.list \

OBJCOPY_BIN += \
LOCK_KEY.bin \


# All Target
all:
	+@make --no-print-directory main-build && make --no-print-directory post-build

# Main-build Target
main-build: LOCK_KEY.elf secondary-outputs

# Tool invocations
LOCK_KEY.elf: $(OBJS) $(USER_OBJS) Y:\A_Track\PROG\LOCK_KEY\STM32L011F4PX_FLASH.ld
	arm-none-eabi-gcc -o "LOCK_KEY.elf" @"objects.list" $(USER_OBJS) $(LIBS) -mcpu=cortex-m0plus -T"Y:\A_Track\PROG\LOCK_KEY\STM32L011F4PX_FLASH.ld" --specs=nosys.specs -Wl,-Map="LOCK_KEY.map" -Wl,--gc-sections -static --specs=nano.specs -mfloat-abi=soft -mthumb -Wl,--start-group -lc -lm -Wl,--end-group
	@echo 'Finished building target: $@'
	@echo ' '

default.size.stdout: $(EXECUTABLES)
	arm-none-eabi-size  $(EXECUTABLES)
	@echo 'Finished building: $@'
	@echo ' '

LOCK_KEY.list: $(EXECUTABLES)
	arm-none-eabi-objdump -h -S $(EXECUTABLES) > "LOCK_KEY.list"
	@echo 'Finished building: $@'
	@echo ' '

LOCK_KEY.bin: $(EXECUTABLES)
	arm-none-eabi-objcopy  -O binary $(EXECUTABLES) "LOCK_KEY.bin"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) *
	-@echo ' '

post-build:
	d6setdate C0 LOCK_KEY.bin -R -CRC
	-@echo ' '

secondary-outputs: $(SIZE_OUTPUT) $(OBJDUMP_LIST) $(OBJCOPY_BIN)

.PHONY: all clean dependents
.SECONDARY: post-build

-include ../makefile.targets
