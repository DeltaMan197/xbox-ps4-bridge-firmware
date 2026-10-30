scripts/flash_image.py
#!/usr/bin/env python3
"""
Firmware flashing script for Pico 2W

Usage:
    python3 flash_image.py --board pico2 --port /dev/ttyUSB0
    python3 flash_image.py --upload --port /dev/ttyUSB0
"""

import sys
import serial
import struct
from pathlib import Path

def parse_args():
    args = {
        'board': 'pico2',
        'port': None,
        'baud': 115200,
        'upload': False,
        'verify': False
    }
    
    for arg in sys.argv[1:]:
        if arg.startswith('--board='):
            args['board'] = arg.split('=')[1]
        elif arg.startswith('--port='):
            args['port'] = arg.split('=')[1]
        elif arg.startswith('--baud='):
            args['baud'] = int(arg.split('=')[1])
        elif arg == '--upload':
            args['upload'] = True
        elif arg == '--verify':
            args['verify'] = True
    
    return args

def flash_firmware(board, port, baud):
    """Upload firmware to Pico 2W"""
    # Build binary from compiled firmware
    firmware_path = Path('build/xbox_ps4_bridge.elf')
    
    if not firmware_path.exists():
        print("Firmware not built. Run: make")
        return False
    
    # Convert ELF to binary
    binary = elf_to_binary(firmware_path)
    
    # Connect and upload
    return upload_to_pico(binary, port, baud)

def upload_to_pico(binary, port, baud):
    """Upload binary to Pico using native USB upload"""
    print(f"Uploading to {port} at {baud} baud...")
    
    # Reset Pico to bootloader
    reset_pico()
    
    # Upload via serial
    with serial.Serial(port, baud, timeout=30) as ser:
        # Command: UPLOAD
        ser.write(b'\x01UPLOAD\n')
        
        # Send binary data in chunks
        chunk_size = 256
        for i in range(0, len(binary), chunk_size):
            chunk = binary[i:i+chunk_size]
            ser.write(struct.pack('<I', len(chunk)) + chunk)
    
    print("Firmware uploaded successfully!")
    return True

def elf_to_binary(elf_path):
    """Convert ELF to binary (simplified)"""
    import subprocess
    result = subprocess.run(
        ['objcopy', '-O', 'binary', str(elf_path), '-'],
        capture_output=True
    )
    return result.stdout

def reset_pico():
    """Reset Pico to USB bootloader mode"""
    import time
    # Pull GPIO 28 low for 500ms
    import machine
    machine.Pin(28).value(0)
    time.sleep(0.5)
    machine.Pin(28).value(1)

def main():
    args = parse_args()
    
    if args['upload']:
        flash_firmware(args['board'], args['port'], args['baud'])
    else:
        print("Usage: python3 flash_image.py --upload --port /dev/ttyUSB0")

if __name__ == '__main__':
    main()