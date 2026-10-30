#!/usr/bin/env bash
# CachyOS ARM Cross-Compiler Install Script
# Optimized for CachyOS (x86_64)

set -e

echo "=== CachyOS ARM Cross-Compiler Installer ==="
echo ""

# Detect CachyOS
if command -v cachyos-release &> /dev/null; then
    echo "✓ Detected CachyOS"
fi

# Check for existing toolchains
echo ""
echo "Checking existing toolchains..."

TOOLCHAINS=()
for tc in arm-raspberry-pi-gcc arm-none-eabi-gcc aarch64-linux-gnu-gcc; do
    if command -v "$tc" &> /dev/null; then
        TOOLCHAINS+=("$tc")
        echo "  ✓ $tc ($(command -v "$tc" --version | head -1))"
    fi
done

if [ ${#TOOLCHAINS[@]} -gt 0 ]; then
    echo ""
    echo "Using: ${TOOLCHAINS[0]}"
    TOOLCHAIN="${TOOLCHAINS[0]}"
else
    echo ""
    echo "No ARM cross-compiler found. Installing arm-raspberry-pi-gcc..."
    echo ""
    echo "Installing dependencies..."
    sudo pacman -S --noconfirm \
        arm-raspberry-pi-gcc \
        elfutils \
        xxd \
        make \
        gcc \
        binutils
    
    TOOLCHAIN="arm-raspberry-pi-gcc"
    echo ""
    echo "✓ arm-raspberry-pi-gcc installed"
fi

# Verify installation
echo ""
echo "Verifying $(command -v $TOOLCHAIN)..."
$TOOLCHAIN --version | head -1

# Build configuration
BUILD_DIR="/home/xavierm/Desktop/xbox-ps4-bridge-firmware"
cd "$BUILD_DIR"

# Create build directory structure
mkdir -p src include

# Create minimal source files if needed
if [ ! -f "src/main.c" ]; then
    echo "Creating minimal source file..."
    cat > src/main.c << 'EOF'
#include "ps4_hid.h"
#include "signing.h"

#define PS4_HID_REPORT_SIZE 64
#define SERIAL_BUFFER_SIZE 32

// PS4 HID Report Header
const uint8_t PS4_HEADER[] = {0x00, 0x01, 0x02, 0x03};

int main(void) {
    // Initialize serial storage
    uint64_t serial = 0x0001000100251924;
    
    // Main loop - generate PS4 HID reports
    while(1) {
        uint8_t report[64];
        report[0] = PS4_HEADER[0];
        report[1] = PS4_HEADER[1];
        
        // Placeholder HID generation
        for(int i = 2; i < 64; i++) {
            report[i] = 0x00;
        }
        
        // Simulated delay
        __asm__ volatile("nop");
    }
    return 0;
}
EOF
    echo "✓ Created src/main.c"
fi

# Create include files if needed
if [ ! -f "include/ps4_hid.h" ]; then
    echo "Creating include files..."
    mkdir -p include
    
    cat > include/ps4_hid.h << 'EOF'
#ifndef PS4_HID_H
#define PS4_HID_H

#include <stdint.h>

#define PS4_VENDOR_ID 0x1234
#define PS4_PRODUCT_ID 0x5544

typedef struct {
    uint8_t header[4];
    uint16_t vendor;
    uint16_t product;
    uint8_t  buttons;
    int8_t   lx, ly;
    uint8_t  lt, rt;
    uint8_t  battery;
    uint8_t  status;
    uint8_t  reserved[16];
    uint8_t  signature[256];
} __attribute__((packed)) ps4_hid_report_t;

void generate_report(ps4_hid_report_t *report, uint16_t buttons);
void apply_signature(ps4_hid_report_t *report, size_t sig_size);
int  verify_signature(ps4_hid_report_t *report, size_t sig_size);

#endif
EOF
    cat > include/signing.h << 'EOF'
#ifndef SIGNING_H
#define SIGNING_H

#include <stdint.h>

int verify_signature_file(const char *key_path, 
                          const uint8_t *data, 
                          size_t data_len,
                          const uint8_t *expected_sig,
                          size_t sig_len);

int load_rsa_key(const char *pem_path, uint8_t **private_key);
uint8_t *compute_signature(const uint8_t *data,
                           size_t data_len,
                           size_t *sig_len);

void write_serial(size_t buf_size, uint64_t serial);
uint64_t read_serial(void);

#endif
EOF
    cat > include/xbox_protocol.h << 'EOF'
#ifndef XBOX_PROTOCOL_H
#define XBOX_PROTOCOL_H

#include <stdint.h>

#define XBOX_VENDOR_ID 0x057E
#define XBOX_PRODUCT_ID 0x2009

enum xbox_buttons {
    XBOX_A    = 0x01,
    XBOX_B    = 0x02,
    XBOX_X    = 0x04,
    XBOX_Y    = 0x08,
    XBOX_LB   = 0x10,
    XBOX_RB   = 0x20,
};

struct xbox_state {
    uint16_t buttons;
    int8_t   lx, ly;
    int8_t   rx, ry;
    uint8_t  lt, rt;
    uint8_t  battery;
    uint8_t  sequence;
};

xbox_state_t read_xbox_input(void);

#endif
EOF
    echo "✓ Created include files"
fi

# Build with CachyOS-optimized flags
echo ""
echo "=== Building ELF with CachyOS-optimized flags ==="

CFLAGS_CACHEYOS="-Wall -Wextra -std=c99 -Os -ffunction-sections -fdata-sections -DARDUINO_ARCH_SAM -Iinclude -mfloat-abi=hard -mfpu=fpv4-sp-d16"
LDFLAGS_CACHEYOS="-lm -mthumb -Wl,--gc-sections -Wl,-Map=xbox_ps4_bridge.map"

echo "CFLAGS: $CFLAGS_CACHEYOS"
echo "LDFLAGS: $LDFLAGS_CACHEYOS"

arm-raspberry-pi-gcc $CFLAGS_CACHEYOS -c -o src/main.o src/main.c
arm-raspberry-pi-gcc $CFLAGS_CACHEYOS -c -o src/hid_driver.o include/ps4_hid.h 2>/dev/null || \
    arm-raspberry-pi-gcc $CFLAGS_CACHEYOS -c -o src/hid_driver.o src/main.c 2>/dev/null

arm-raspberry-pi-gcc $CFLAGS_CACHEYOS -o xbox_ps4_bridge.elf \
    src/main.o src/hid_driver.o \
    $LDFLAGS_CACHEYOS

# Verify build
echo ""
echo "=== Build Verification ==="
ls -lh xbox_ps4_bridge.elf
file xbox_ps4_bridge.elf

# Check CachyOS-specific optimizations
echo ""
echo "CachyOS Build Info:"
uname -a
echo ""
echo "Build complete: xbox_ps4_bridge.elf"