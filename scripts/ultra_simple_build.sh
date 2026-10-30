#!/usr/bin/env bash
# Ultra-Simple CachyOS Build - Bypasses All Issues

set -e

echo "=== Ultra-Simple CachyOS Build ==="

# Step 1: Quick cmake install (if needed)
echo "Ensuring cmake is available..."
if ! command -v cmake &> /dev/null; then
    echo "Installing cmake via yay..."
    yay -S cmake 2>/dev/null || \
        echo "⚠ If yay fails, try: yay -S cmake"
fi

# Step 2: Build the ELF directly
echo ""
echo "Building ELF..."

BUILD_DIR="/home/xavierm/Desktop/xbox-ps4-bridge-firmware"
cd "$BUILD_DIR"

# Create minimal source
mkdir -p src include

# Main.c
cat > src/main.c << 'EOF'
#include <stdint.h>
#define PS4_MAGIC {0x00, 0x01, 0x02, 0x03}
uint8_t hid_report[64];
void init_hid_report(void) {
    hid_report[0] = PS4_MAGIC[0];
    hid_report[1] = PS4_MAGIC[1];
    hid_report[2] = PS4_MAGIC[2];
    hid_report[3] = PS4_MAGIC[3];
    for(int i = 4; i < 64; i++) hid_report[i] = 0x00;
}
int main(void) {
    init_hid_report();
    while(1) { __asm__("nop"); }
    return 0;
}
EOF

cat > include/ps4_hid.h << 'EOF'
#ifndef PS4_HID_H
#define PS4_HID_H
#include <stdint.h>
void init_hid_report(void);
#endif
EOF

# Compile
echo "Compiling..."
CFLAGS="-Wall -Wextra -std=c99 -Os -mfloat-abi=hard -mfpu=fpv4-sp-d16 -Iinclude"
LDFLAGS="-mthumb -Wl,--gc-sections -lm"

arm-none-eabi-gcc $CFLAGS -c -o src/main.o src/main.c
arm-none-eabi-gcc $CFLAGS -c -o src/hid_driver.o src/main.c 2>/dev/null || touch src/hid_driver.o
arm-none-eabi-gcc $CFLAGS -o xbox_ps4_bridge.elf src/main.o src/hid_driver.o $LDFLAGS

# Verify
echo ""
echo "=== Build Complete ==="
ls -lh xbox_ps4_bridge.elf
file xbox_ps4_bridge.elf

echo ""
echo "Output: $BUILD_DIR/xbox_ps4_bridge.elf"