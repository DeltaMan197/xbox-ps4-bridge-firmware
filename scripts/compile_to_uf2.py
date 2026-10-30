#!/usr/bin/env python3
"""
Compile Xbox-PS4 Bridge firmware to UF2 format for Pico 2W

Usage:
    python3 compile_to_uf2.py
    python3 compile_to_uf2.py --elf build/xbox_ps4_bridge.elf
"""

import struct
import subprocess
import sys
from pathlib import Path

def convert_to_uf2(elf_path: str, output_path: str = None) -> bool:
    """
    Convert ELF to UF2 format using uf2tool or elf2uf2
    
    UF2 format specification: https://github.com/raspberrypi/uf2
    """
    
    if output_path is None:
        base_name = Path(elf_path).stem
        output_path = f"{base_name}.uf2"
    
    print(f"Converting {elf_path} to UF2 format...")
    
    # Try uf2tool first (Python-based, cross-platform)
    try:
        import uf2tool
        
        result = subprocess.run([
            'uf2tool', elf_path, '-o', output_path
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"✓ UF2 created: {output_path}")
            return True
        else:
            print(f"uf2tool failed: {result.stderr}")
    except ImportError:
        print("uf2tool not available, trying elf2uf2...")
    
    # Try elf2uf2 (C-based, faster)
    try:
        subprocess.run([
            'elf2uf2', elf_path, output_path
        ], capture_output=True, text=True)
        
        if subprocess.run(['file', output_path]).stdout.strip().startswith('data'):
            print(f"✓ ELF2UF2 completed: {output_path}")
            return True
        else:
            print("elf2uf2 may have failed - checking output...")
    except FileNotFoundError:
        print("elf2uf2 not found. Install via: sudo apt install elf2uf2")
    
    # Fallback: Check if UF2 was created
    if Path(output_path).exists():
        # Verify UF2 magic header
        with open(output_path, 'rb') as f:
            header = f.read(4)
            # Expected: 0x0A100001 (little-endian)
            if struct.unpack('<I', header)[0] == 0x0A100001:
                print(f"✓ Valid UF2 header detected in {output_path}")
                return True
    
    print("⚠ UF2 creation may have failed. Check output file.")
    return False

def main():
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Convert Xbox-PS4 Bridge firmware to UF2 format"
    )
    parser.add_argument(
        '--elf',
        type=str,
        default='build/xbox_ps4_bridge.elf',
        help='Path to ELF file (default: build/xbox_ps4_bridge.elf)'
    )
    parser.add_argument(
        '--output',
        '-o',
        type=str,
        default=None,
        help='Output UF2 filename'
    )
    parser.add_argument(
        '--check',
        action='store_true',
        help='Only verify UF2 file validity'
    )
    
    args = parser.parse_args()
    
    if args.check:
        # Verify existing UF2 file
        if Path(args.output).exists() if args.output else False:
            print("Verifying UF2 file...")
            with open(args.output, 'rb') as f:
                magic = struct.unpack('<I', f.read(4))[0]
                print(f"  Magic header: 0x{magic:08X}")
                if magic == 0x0A100001:
                    print("  ✓ Valid UF2 magic header")
                else:
                    print("  ✗ Invalid UF2 header")
        else:
            print(f"File not found: {args.output}")
    else:
        # Convert to UF2
        if not Path(args.elf).exists():
            print(f"Error: ELF file not found: {args.elf}")
            print("Build firmware first with: make all")
            sys.exit(1)
        
        convert_to_uf2(args.elf, args.output)

if __name__ == '__main__':
    main()