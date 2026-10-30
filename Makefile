# Pico-UF2 Build System
# Generates .elf and .uf2 for Xbox-PS4 Bridge Firmware

# Target: Raspberry Pi Pico 2 (RP2040)
# Compiler: arm-raspberry-pi-gcc (from Pico SDK)

# Source directory
SRCDIR := $(CURDIR)/src
INCDIR := $(CURDIR)/include

# Object files
OBJS := $(SRCDIR)/main.o \
         $(SRCDIR)/hid_driver.o \
         $(SRCDIR)/input_mapper.o \
         $(SRCDIR)/serial_storage.o

# Compiler flags for Pico 2
CFLAGS := -Wall -Wextra -std=c99 \
          -mcpu=cortex-m0plus \
          -mthumb \
          -D__MICROPY_PY_INT=1 \
          -DARDUINO_ARCH_SAM \
          -I$(INCDIR)

# Build target
TARGET := xbox_ps4_bridge.elf

# Default target
all: $(TARGET)

# Build ELF
$(TARGET): $(OBJS)
	@echo "Linking $(TARGET)..."
	arm-raspberry-pi-gcc $(CFLAGS) -o $@ $^ -lm
	@echo "✓ ELF created: $(TARGET) ($(shell du -h $(TARGET) | cut -f1))"

# Compile object files
$(SRCDIR)/%.o: $(SRCDIR)/%.c $(INCDIR)/%.h
	@echo "Compiling $<"
	arm-raspberry-pi-gcc $(CFLAGS) -c -o $@ $<

# Create src directory if missing
$(SRCDIR):
	mkdir -p $(SRCDIR)

# Create include directory if missing
$(INCDIR):
	mkdir -p $(INCDIR)

# Clean
clean:
	rm -f $(OBJS) $(TARGET)

# Show build info
info:
	@echo "=== Build Configuration ==="
	@echo "Target:    $(TARGET)"
	@echo "Compiler:  arm-raspberry-pi-gcc"
	@echo "Flags:     $(CFLAGS)"
	@echo "Objects:   $(OBJS)"

# Help
help:
	@echo "Xbox-PS4 Bridge Build System"
	@echo "============================"
	@echo "  make          - Build ELF (default)"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make info     - Show build configuration"
	@echo ""
	@echo "Prerequisites:"
	@echo "  sudo apt install arm-raspberry-pi-gcc"
	@echo "  pip install uf2tool elf2uf2"

.PHONY: all clean info help

# Verify ELF output
verify: $(TARGET)
	@echo "Verifying $(TARGET)..."
	@file $(TARGET)
	@echo "ELF header check:"
	@xxd -l 20 $(TARGET) | head -3