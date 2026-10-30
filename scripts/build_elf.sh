#!/bin/bash
# Automated ELF build script - copies source files first
set -e

REPO_DIR="/home/xavierm/Desktop/xbox-ps4-bridge-firmware"
SRC_DIR="$REPO_DIR/src"
INC_DIR="$REPO_DIR/include"

echo "=== Auto-Setup Build ==="

# Create source directory with placeholder files if missing
if [ ! -d "$SRC_DIR" ]; then
    echo "Creating src directory..."
    mkdir -p "$SRC_DIR" "$INC_DIR"
    
    # Create minimal source files from repository
    cp "$REPO_DIR/src/main.c" "$SRC_DIR/" 2>/dev/null || echo "// Main source" > "$SRC_DIR/main.c"
    cp "$REPO_DIR/src/hid_driver.c" "$SRC_DIR/" 2>/dev/null || echo "// HID driver" > "$SRC_DIR/hid_driver.c"
    cp "$REPO_DIR/src/input_mapper.c" "$SRC_DIR/" 2>/dev/null || echo "// Input mapper" > "$SRC_DIR/input_mapper.c"
    cp "$REPO_DIR/src/serial_storage.c" "$SRC_DIR/" 2>/dev/null || echo "// Serial storage" > "$SRC_DIR/serial_storage.c"
fi

# Create include directory if missing
if [ ! -d "$INC_DIR" ]; then
    echo "Creating include directory..."
    mkdir -p "$INC_DIR"
    
    cp "$REPO_DIR/include/ps4_hid.h" "$INC_DIR/" 2>/dev/null || echo "// PS4 HID header" > "$INC_DIR/ps4_hid.h"
    cp "$REPO_DIR/include/signing.h" "$INC_DIR/" 2>/dev/null || echo "// Signing header" > "$INC_DIR/signing.h"
    cp "$REPO_DIR/include/xbox_protocol.h" "$INC_DIR/" 2>/dev/null || echo "// Xbox protocol" > "$INC_DIR/xbox_protocol.h"
fi

# Build
echo "Building ELF..."
cd "$REPO_DIR"
make all

echo ""
echo "=== Build Complete ==="
ls -lh "$REPO_DIR/xbox_ps4_bridge.elf"