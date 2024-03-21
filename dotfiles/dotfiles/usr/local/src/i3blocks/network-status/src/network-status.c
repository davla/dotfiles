#include <stdio.h>

#include "network-connection.h"

#if !defined(CABLE_LABEL) && !defined(WIRELESS_LABEL)
    #error "Neither CABLE_LABEL nor WIRELESS_LABEL is defined, no output will ever be printed"
#endif

void connections_print_indicator(struct network_connection* connections) {
    struct network_connection* curr;
    const char* color;
    double status;

    #ifdef SWAYBAR
    /*
     * There is a bug in swaybar that prevents font size from being applied
     * if no other text has been output. Therefore, we print an almost
     * invisible space.
     */
    printf("<span size='0.001pt'> </span>");
    #endif

    for (curr = connections; curr; curr = curr->next) {
        status = network_connection_status(curr);

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

        printf(
            "<span %s foreground='%s'>%s</span>%s",
            PANGO_PROPS,
            color,
            curr->label,
            curr->next ? LABEL_SEPARATOR : ""
        );
    }
    printf("\n");
}

int main() {
    struct network_connection* connections = make_network_connections();
    connections_print_indicator(connections);
    network_connection_free(connections);
    return 0;
}
