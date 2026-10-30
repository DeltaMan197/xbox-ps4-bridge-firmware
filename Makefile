# Pico 2 ELF Build - Properly Configured for x86_64 Host
# This Makefile is designed to cross-compile ARM firmware on x86_64 systems

# Toolchain detection
TOOLCHAIN := $(shell command -v arm-raspberry-pi-gcc 2>/dev/null || echo "arm-none-eabi-gcc")

ifeq ($(TOOLCHAIN),)
    $(error arm-raspberry-pi-gcc not found. Install with: sudo apt install arm-raspberry-pi-gcc)
endif

# Source files
SRCS := src/main.c \
        src/hid_driver.c \
        src/input_mapper.c \
        src/serial_storage.c

# Object files
OBJS := $(SRCS:.c=.o)

# Target ELF
TARGET := xbox_ps4_bridge.elf

# Compiler flags for ARM cross-compilation on x86_64 host
# No -march or -mcpu needed - the cross-compiler handles this
CFLAGS := -Wall -Wextra -std=c99 \
          -ffunction-sections \
          -fdata-sections \
          -fno-common \
          -DARDUINO_ARCH_SAM \
          -Iinclude \
          -Os \
          -mfloat-abi=hard \
          -mfpu=fpv4-sp-d16

# Linker flags for ARM ELF
LDFLAGS := -lm \
           -mthumb \
           -Tarm-none-eabi-gcc.ld \
           -Wl,--gc-sections \
           -Wl,-Map=$(TARGET).map

# Default target
all: $(TARGET)

# Build ELF
$(TARGET): $(OBJS)
	@echo "Linking $(TARGET)..."
	$(TOOLCHAIN) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	@echo "✓ ELF created: $(TARGET)"
	@ls -lh $(TARGET)

# Compile object files
$(SRCDIR)/%.o: $(SRCDIR)/%.c include/%.h
	@echo "Compiling $<"
	$(TOOLCHAIN) $(CFLAGS) -c -o $@ $<

# Create directories if missing
$(SRCDIR):
	mkdir -p $(SRCDIR)

$(INCDIR):
	mkdir -p $(INCDIR)

# Clean
clean:
	rm -f $(OBJS) $(TARGET) $(TARGET).map

# Help
help:
	@echo "Xbox-PS4 Bridge ELF Build (x86_64 -> ARM)"
	@echo "=========================================="
	@echo ""
	@echo "Prerequisites:"
	@echo "  sudo apt install arm-raspberry-pi-gcc"
	@echo "  sudo apt install xxd"
	@echo ""
	@echo "Commands:"
	@echo "  make          - Build ELF (default)"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make help     - Show this help"

.PHONY: all clean help

# Verify build
verify: $(TARGET)
	@echo "=== ELF Verification ==="
	@$(TOOLCHAIN) -dumpbin file $(TARGET)
	@ls -lh $(TARGET)