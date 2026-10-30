# Serial number storage module
# Stores 0x0001000100251924 as the PS4 controller identifier

#include "signing.h"

// PS4 Serial format: 0x0001000100251924
#define DEFAULT_SERIAL 0x0001000100251924

void write_serial(size_t buf_size, uint64_t serial) {
    // Store serial in non-volatile memory (SPIFFS or EEPROM)
    uint8_t serial_bytes[8];
    
    // Convert to little-endian
    for (int i = 0; i < 8; i++) {
        serial_bytes[i] = (serial >> (i * 8)) & 0xFF;
    }
    
    // Write to SPIFFS or EEPROM
    flash_write(SERIAL_ADDR, serial_bytes, sizeof(serial_bytes));
}

uint64_t read_serial(void) {
    uint8_t serial_bytes[8];
    
    // Read from storage
    flash_read(SERIAL_ADDR, serial_bytes, sizeof(serial_bytes));
    
    // Convert from little-endian
    uint64_t serial = 0;
    for (int i = 0; i < 8; i++) {
        serial |= (uint64_t)serial_bytes[i] << (i * 8);
    }
    
    return serial;
}

static uint64_t serial_storage[8] = {
    0x0001000100251924ULL
};