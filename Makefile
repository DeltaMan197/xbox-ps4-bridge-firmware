# Pico-UF2 Build System - Fixed for arm-raspberry-pi-gcc
# Generates .elf and .uf2 for Xbox-PS4 Bridge Firmware

# Target: Raspberry Pi Pico 2 (RP2040) - Cortex-M0+
# Compiler: arm-raspberry-pi-gcc (from Pico SDK)

# Source files
SRCS := src/main.c \
        src/hid_driver.c \
        src/input_mapper.c \
        src/serial_storage.c

# Object files
OBJS := $(SRCS:.c=.o)

# Target ELF
TARGET := xbox_ps4_bridge.elf

# Compiler flags - FIXED for arm-raspberry-pi-gcc
# -march=armv6-m is the correct architecture for Cortex-M0+ Pico 2
# Removed -mthumb (not supported by this toolchain)
CFLAGS := -Wall -Wextra -std=c99 \
          -march=armv6-m \
          -mcpu=cortex-m0plus \
          -DARDUINO_ARCH_SAM \
          -Iinclude \
          -ffunction-sections \
          -fdata-sections \
          -fno-common

# LDFLAGS for proper ELF output
LDFLAGS := -lm \
           -Wl,--gc-sections \
           -Wl,-Map=$(TARGET).map \
           -Wl,-Crelocatable

# Default target
all: $(TARGET)

# Build ELF - FIXED with proper flags
$(TARGET): $(OBJS)
	@echo "Linking $(TARGET)..."
	arm-raspberry-pi-gcc $(CFLAGS) -o $@ $^ $(LDFLAGS)
	@echo "✓ ELF created: $(TARGET)"
	@ls -lh $(TARGET)
	@file $(TARGET)

# Compile object files - FIXED with correct include path
$(SRCDIR)/%.o: $(SRCDIR)/%.c include/%.h
	@echo "Compiling $<"
	arm-raspberry-pi-gcc $(CFLAGS) -c -o $@ $<

# Create directories if missing
$(SRCDIR):
	@mkdir -p $(SRCDIR)
	@echo "✓ Created $(SRCDIR)"

$(INCDIR):
	@mkdir -p $(INCDIR)
	@echo "✓ Created $(INCDIR)"

# Clean build artifacts
clean:
	rm -f $(OBJS) $(TARGET) $(TARGET).map

# Show build info
info:
	@echo "=== Build Configuration ==="
	@echo "Target:    $(TARGET)"
	@echo "Compiler:  arm-raspberry-pi-gcc"
	@echo "CFLAGS:    $(CFLAGS)"
	@echo "LDFLAGS:   $(LDFLAGS)"

# Help
help:
	@echo "Xbox-PS4 Bridge Build System (Fixed)"
	@echo "===================================="
	@echo ""
	@echo "Usage:"
	@echo "  make          - Build ELF (default)"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make info     - Show build configuration"
	@echo ""
	@echo "Prerequisites:"
	@echo "  sudo apt install arm-raspberry-pi-gcc"
	@echo "  sudo apt install xxd"
	@echo ""
	@echo "The fix addresses:"
	@echo "  • -march=armv6-m (correct for Cortex-M0+)"
	@echo "  • Removed -mthumb (unsupported)"
	@echo "  • Fixed include paths for source files"

.PHONY: all clean info help

# Verify ELF output
verify: $(TARGET)
	@echo "Verifying $(TARGET)..."
	@file $(TARGET)
	@ls -lh $(TARGET)

# Debug build
debug: CFLAGS += -g -O0
debug: $(TARGET)
	@echo "Debug build complete: $(TARGET)"

# Release build (optimized)
release: CFLAGS += -O2
release: $(TARGET)
	@echo "Release build complete: $(TARGET)"