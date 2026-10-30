#!/bin/bash
# Verify Xbox-PS4 Bridge ELF build
set -e

ELF="build/xbox_ps4_bridge.elf"

echo "=== ELF Verification Script ==="
echo ""

# Check if ELF exists
if [ ! -f "$ELF" ]; then
    echo "✗ ELF not found: $ELF"
    echo "Run: make all"
    exit 1
fi

# Check file size (should be ~40-60KB for this firmware)
SIZE=$(stat -c%s "$ELF")
echo "✓ File size: $((SIZE / 1024)) KB"

if [ "$SIZE" -lt 10000 ] || [ "$SIZE" -gt 200000 ]; then
    echo "⚠ Warning: File size seems unusual (10-200KB expected)"
fi

# Check ELF magic number
echo "Checking ELF magic header..."
MAGIC=$(xxd -l 4 "$ELF" | awk '{print $3}')
if [[ "$MAGIC" == "7f454c46" ]]; then
    echo "✓ Valid ELF magic number (0x7f 0x45 0x4c 0x46)"
else
    echo "✗ Invalid ELF header"
    exit 1
fi

# Check architecture
echo ""
echo "Architecture details:"
file "$ELF" | grep -i "arm\|cortex" || echo "  (file info may need arm elfutils)"

# Extract program headers (entry point)
echo ""
echo "Program headers (first 4 bytes):"
xxd -l 16 "$ELF" | head -1

# Count sections
SECTIONS=$(readelf -S "$ELF" 2>/dev/null | tail -n +3 | wc -l)
echo ""
echo "Number of sections: $SECTIONS"

# Display section headers
echo ""
echo "Key sections:"
readelf -S "$ELF" 2>/dev/null | grep -E "text|data|rodata|bss|\.got|\.got.plt" || echo "  (use 'readelf -S' for full output)"

echo ""
echo "=== Build Verification Complete ==="