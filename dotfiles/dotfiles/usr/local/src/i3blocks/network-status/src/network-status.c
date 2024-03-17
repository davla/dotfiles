#include <stdio.h>

#include "common.h"
#include "interface.h"

#if !defined(CABLE_LABEL) && !defined(WIRELESS_LABEL)
    #error "Neither CABLE_LABEL nor WIRELESS_LABEL is defined, no output will ever be printed"
#endif

void interfaces_print_indicator(struct interface* interfaces) {
    struct interface* if_curr;
    const char* color;
    double status;

    for (if_curr = interfaces; if_curr; if_curr = if_curr->next) {
        status = interface_check_status(if_curr);

        if (status == INTERFACE_STATUS_INACTIVE) {
            color = INACTIVE_CONNECTION_COLOR;
        }
        else if (status >= GOOD_CONNECTION_QUALITY_THRESHOLD) {
            color = GOOD_CONNECTION_QUALITY_COLOR;
        }
        else if (status >= MEDIUM_CONNECTION_QUALITY_THRESHOLD) {
            color = MEDIUM_CONNECTION_QUALITY_COLOR;
        }
        else {
            color = BAD_CONNECTION_QUALITY_COLOR;
        }

        printf("<span color='%s'>%s</span>", color, if_curr->label);
    }
}

int main() {
    struct interface* interfaces = make_interfaces();
    interfaces_print_indicator(interfaces);
    printf("\n");
    interface_free(interfaces);
    return 0;
}
