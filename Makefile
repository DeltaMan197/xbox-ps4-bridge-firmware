Makefile
# Makefile for Xbox-PS4 Bridge Firmware

CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -I include
LDFLAGS = -lm

# Target architecture
ARCH = arm
TARGET = xbox_ps4_bridge

# Source files
SRCS = src/main.c \
        src/hid_driver.c \
        src/bluetooth_stack.c \
        src/input_mapper.c \
        src/serial_storage.c

OBJS = $(SRCS:.c=.o)

# Default target
all: $(TARGET).elf

# Build ELF
$(TARGET).elf: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# Compile object files
src/%.o: src/%.c include/%.h
	$(CC) $(CFLAGS) -c -o $@ $<

# Program size
$(TARGET).elf: $(TARGET).size

# Flash via USB
flash: $(TARGET).elf
	python3 scripts/flash_image.py --upload --port /dev/ttyUSB0

# Clean
.PHONY: clean
clean:
	rm -f $(OBJS) $(TARGET).elf

# Help
.PHONY: help
help:
	@echo "Targets:"
	@echo "  all     - Build firmware (default)"
	@echo "  flash   - Build and upload to Pico"
	@echo "  clean   - Remove build artifacts"

.PHONY: all flash clean help