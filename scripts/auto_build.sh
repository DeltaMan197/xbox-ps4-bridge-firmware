#!/bin/bash
# Auto-detect and install proper ARM cross-compiler
set -e

echo "=== Auto-Detecting ARM Toolchain ==="

# Check what's available
if command -v arm-raspberry-pi-gcc &> /dev/null; then
    echo "✓ arm-raspberry-pi-gcc found: $(arm-raspberry-pi-gcc --version)"
    TOOLCHAIN="arm-raspberry-pi-gcc"
elif command -v arm-none-eabi-gcc &> /dev/null; then
    echo "✓ arm-none-eabi-gcc found: $(arm-none-eabi-gcc --version)"
    TOOLCHAIN="arm-none-eabi-gcc"
else
    echo "No ARM cross-compiler found. Installing arm-raspberry-pi-gcc..."
    sudo apt update
    sudo apt install -y arm-raspberry-pi-gcc
fi

echo "Using toolchain: $TOOLCHAIN"

# Build
cd /home/xavierm/Desktop/xbox-ps4-bridge-firmware
make all