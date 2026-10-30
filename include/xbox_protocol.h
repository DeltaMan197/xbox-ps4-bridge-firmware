#ifndef XBOX_PROTOCOL_H
#define XBOX_PROTOCOL_H

#include <stdint.h>

// Xbox One S Controller Protocol
#define XBOX_VENDOR_ID 0x057E
#define XBOX_PRODUCT_ID 0x2009

// Button definitions
enum xbox_buttons {
    XBOX_A    = 0x01,
    XBOX_B    = 0x02,
    XBOX_X    = 0x04,
    XBOX_Y    = 0x08,
    XBOX_LB   = 0x10,
    XBOX_RB   = 0x20,
    XBOX_LT   = 0x40,
    XBOX_RT   = 0x80,
};

// Xbox input report structure (12 bytes + 6 bytes analog)
typedef struct {
    uint8_t  header[4];
    uint8_t  buttons;     // Bitmask of pressed buttons
    int8_t   left_x, left_y;
    int8_t   right_x, right_y;
    int8_t   trigger_l, trigger_r;
    uint8_t  battery;
    uint8_t  sequence;
} xbox_input_report_t;

// Xbox state structure for translation
struct xbox_state {
    uint16_t buttons;
    int8_t   lx, ly;
    int8_t   rx, ry;
    uint8_t  lt, rt;
    uint8_t  battery;
    uint8_t  sequence;
};

// Xbox input reading
xbox_state_t read_xbox_input(void);
xbox_input_report_t read_xbox_report(void);

#endif // XBOX_PROTOCOL_H