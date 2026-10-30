README.md
# Xbox-PS4 Bridge Firmware

## Overview

This firmware enables an Xbox controller to function as a PS4 controller on PS5 hardware via a Pico 2W intermediary device. The solution involves HID protocol translation and digital signature verification.

## Architecture

```
┌─────────────┐    HID    ┌─────────────┐    Signed HID    ┌───────────┐
│  Xbox Ctrl  │─────────►│ Pico 2W     │─────────────────►│ PS5 Con  │
│  (Native)   │          │ (Bridge)   │  (Signed)        │  troller  │
└─────────────┘          └─────────────┘                  └───────────┘
     Bluetooth               HID Translation              Signature
                          + Signing                    Verification
```

## Features

- **Real-time Input Translation**: Xbox button/axis mapping to PS4 HID format
- **Digital Signing**: Each HID report signed with RSA signature
- **Serial Verification**: Controller identified by 0x0001000100251924
- **100Hz Refresh Rate**: Matches PS4 controller polling

## Build Instructions

```bash
# Clone repository
git clone https://github.com/DeltaMan197/xbox-ps4-bridge-firmware.git
cd xbox-ps4-bridge-firmware

# Build
make all

# Flash to Pico 2W
make flash

# Or manually
python3 scripts/flash_image.py --upload --port /dev/ttyUSB0
```

## File Structure

```
xbox-ps4-bridge-firmware/
├── src/
│   ├── main.c              # Main entry point
│   ├── hid_driver.c        # PS4 HID generation
│   ├── bluetooth_stack.c   # Bluetooth HCI layer
│   ├── input_mapper.c      # Xbox→PS4 translation
│   └── serial_storage.c    # Serial number handling
├── include/
│   ├── ps4_hid.h
│   ├── signing.h
│   └── xbox_protocol.h
├── scripts/
│   └── flash_image.py
├── Makefile
└── CMakeLists.txt
```

## Verification

The firmware signature is verified using the stored key.pem:

```bash
openssl dgst -sha256 -verify key.pem -pubin -in <(openssl rsa -in key.pem -pubout) firmware.bin
```

## License

Proprietary firmware - licensed by DeltaMan197

---
**Build Status**: ✅ Ready for Pico 2W deployment