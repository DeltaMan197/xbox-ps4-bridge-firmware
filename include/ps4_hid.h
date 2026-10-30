#ifndef PS4_HID_H
#define PS4_HID_H

#include <stdint.h>

// PS4 HID Report Constants
#define PS4_VENDOR_ID 0x1234
#define PS4_PRODUCT_ID 0x5544
#define PS4_REPORT_ID 0x01

// Button mapping
enum ps4_buttons {
    PS4_CROSS,
    PS4_CIRCLE,
    PS4_SQUARE,
    PS4_TRIANGLE,
    PS4_OPTIONS,
    PS4_SHARE,
    PS4_L1,
    PS4_R1,
    PS4_L2,
    PS4_R2,
    PS4_L3,
    PS4_R3,
};

// HID Report Structure
typedef struct {
    uint8_t header[4];
    uint16_t vendor;  // Big-endian
    uint16_t product; // Big-endian
    uint8_t  buttons;
    int8_t   lx, ly;
    int8_t   rx, ry;
    uint8_t  lt, rt;
    uint8_t  battery;
    uint8_t  status;
    uint8_t  reserved[16];
    uint8_t  signature[256];
} __attribute__((packed)) ps4_hid_report_t;

// Report generation
void generate_report(ps4_hid_report_t *report, uint16_t buttons);
void apply_signature(ps4_hid_report_t *report, size_t sig_size);
int  verify_signature(ps4_hid_report_t *report, size_t sig_size);

// HID transmission
int send_hid_report(const ps4_hid_report_t *report);
int hid_init(void);

#endif // PS4_HID_H