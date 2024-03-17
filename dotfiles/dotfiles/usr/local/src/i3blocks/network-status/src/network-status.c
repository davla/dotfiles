#include <stdio.h>

#include "network-connection.h"

#if !defined(CABLE_LABEL) && !defined(WIRELESS_LABEL)
    #error "Neither CABLE_LABEL nor WIRELESS_LABEL is defined, no output will ever be printed"
#endif

void connections_print_indicator(struct network_connection* connections) {
    struct network_connection* curr;
    const char* color;
    double status;

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

        printf("<span color='%s'>%s</span>", color, curr->label);
    }
}

int main() {
    struct network_connection* connections = make_network_connections();
    connections_print_indicator(connections);
    printf("\n");
    network_connection_free(connections);
    return 0;
}
