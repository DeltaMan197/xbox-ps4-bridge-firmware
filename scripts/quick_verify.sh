#!/bin/bash
# Quick ELF verification for Pico 2 firmware
set -e

ELF="xbox_ps4_bridge.elf"

echo "=== Quick ELF Verification ==="
echo ""

# Check if ELF exists and is reasonable size
if [ -f "$ELF" ]; then
    SIZE=$(stat -c%s "$ELF")
    if [ "$SIZE" -ge 10000 ] && [ "$SIZE" -le 200000 ]; then
        echo "✓ ELF exists: $ELF ($((SIZE / 1024)) KB)"
        
        # Check ELF magic
        MAGIC=$(xxd -l 4 "$ELF" | awk '{print $3}')
        if [[ "$MAGIC" == "7f454c46" ]]; then
            echo "✓ Valid ELF magic header"
            echo ""
            echo "=== BUILD SUCCESSFUL ==="
            echo "The ELF is ready to convert to UF2:"
            echo "  uf2tool $ELF -o xbox_ps4_bridge.uf2"
        else
            echo "✗ Invalid ELF header (magic: $MAGIC)"
        fi
    else
        echo "⚠ File size unusual ($((SIZE / 1024)) KB, expected 10-200 KB)"
    fi
else
    echo "✗ ELF not found: $ELF"
    echo "Run: make all"
fi