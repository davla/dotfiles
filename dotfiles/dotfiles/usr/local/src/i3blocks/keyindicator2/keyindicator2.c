/*
 * This file prints activation indicators for Caps Lock and Num Lock. It is
 * meant to be used as a command for i3blocks. It outputs text in different
 * colors based on Caps Lock and Num Lock status, in pango markup.
 */

#include <stdlib.h>
#include <stdio.h>
#include <X11/Xlib.h>

#if !defined(CAPS_LABEL) && !defined(NUM_LABEL)
    #error "Neither CAPS_LABEL nor NUM_LABEL is defined, no output will ever be printed"
#endif

static const unsigned char labels_count = 0
#if defined(CAPS_LABEL)
+ 1
#elif defined(NUM_LABEL)
+ 1
#endif
;

/* Bit masks for X11 keyboard leds. */
#define CAPS_MASK (0x1)
#define NUM_MASK (0x2)

unsigned long get_leds() {
    XKeyboardState keyboard;
    Display* display;

    if ((display = XOpenDisplay(NULL)) == NULL) {
        perror("get_leds - error when calling XOpenDisplay");
        exit(EXIT_FAILURE);
    }

    XGetKeyboardControl(display, &keyboard);
    return keyboard.led_mask;
}

void show_indicator(unsigned long led, const char* label, int is_last) {
    printf(
        "<span %s color='%s'>%s</span>%s",
        PANGO_PROPS,
        led ? ACTIVE_KEY_COLOR : INACTIVE_KEY_COLOR,
        label,
        is_last ? "" : LABEL_SEPARATOR
    );
}

int main() {
    unsigned long leds = get_leds();

    #ifdef CAPS_LABEL
        show_indicator(leds & CAPS_MASK, CAPS_LABEL, labels_count == 1);
    #endif

    #ifdef NUM_LABEL
        show_indicator(leds & NUM_MASK, NUM_LABEL, labels_count == 2);
    #endif

    printf("\n");
}
