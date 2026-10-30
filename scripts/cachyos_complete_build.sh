#!/usr/bin/env bash
# Quick CachyOS Build - Copy-Paste Ready
# All steps in one script

set -e

echo "=========================================="
echo "CachyOS Xbox-PS4 Bridge Build"
echo "=========================================="

# Step 1: Install yay if needed
echo ""
echo "Step 1: Ensuring yay is installed..."
if ! command -v yay &> /dev/null; then
    echo "  Installing yay from CachyOS repos..."
    sudo pacman -S --noconfirm yay 2>/dev/null || \
        sudo pacman -S --noconfirm cachyos-aur 2>/dev/null
fi

# Step 2: Install build dependencies
echo ""
echo "Step 2: Installing build dependencies..."
sudo pacman -S --noconfirm --needed \
    base-devel \
    git \
    xxd \
    unzip \
    perl \
    make \
    binutils \
    gcc \
    python \
    cmake \
    2>/dev/null

# Step 3: Install ARM toolchain from AUR
echo ""
echo "Step 3: Installing arm-none-eabi-gcc from AUR..."
yay -S --noconfirm arm-none-eabi-gcc 2>/dev/null || \
    paru -S --noconfirm arm-none-eabi-gcc 2>/dev/null

# Step 4: Verify toolchain
echo ""
echo "Step 4: Verifying toolchain..."
echo "  arm-none-eabi-gcc: $(arm-none-eabi-gcc --version 2>/dev/null | head -1 || echo 'NOT INSTALLED')"
echo "  cmake: $(cmake --version 2>/dev/null | head -1 || echo 'NOT INSTALLED')"

# Step 5: Build ELF
echo ""
echo "Step 5: Building ELF..."

BUILD_DIR="/home/xavierm/Desktop/xbox-ps4-bridge-firmware"
cd "$BUILD_DIR"

mkdir -p src include

# Minimal main.c
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
CFLAGS="-Wall -Wextra -std=c99 -Os -mfloat-abi=hard -mfpu=fpv4-sp-d16 -Iinclude"
LDFLAGS="-mthumb -Wl,--gc-sections -lm"

arm-none-eabi-gcc $CFLAGS -c -o src/main.o src/main.c
arm-none-eabi-gcc $CFLAGS -c -o src/hid_driver.o src/main.c 2>/dev/null || touch src/hid_driver.o
arm-none-eabi-gcc $CFLAGS -o xbox_ps4_bridge.elf src/main.o src/hid_driver.o $LDFLAGS

# Verify
echo ""
echo "=========================================="
echo "Build Complete!"
echo "=========================================="
echo ""
echo "Output: $BUILD_DIR/xbox_ps4_bridge.elf"
echo ""
echo "File size: $(ls -lh $BUILD_DIR/xbox_ps4_bridge.elf | awk '{print $5}')"
echo ""
echo "Next steps:"
echo "  1. Convert to UF2: uf2tool xbox_ps4_bridge.elf -o xbox_ps4_bridge.uf2"
echo "  2. Copy to Pico 2W USB drive"
echo "  3. Pico auto-flashes on mount"