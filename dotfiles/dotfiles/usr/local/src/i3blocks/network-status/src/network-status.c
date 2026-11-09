#include <stdint.h>
#include <stdio.h>

#include "exception.h"
#include "network-probe.h"

#if defined(CABLE_LABEL) && defined(WIRELESS_LABEL)
    #define CONNECTION_COUNT (2)
#elif defined(CABLE_LABEL) || defined(WIRELESS_LABEL)
    #define CONNECTION_COUNT (1)
#else
    #error "Neither CABLE_LABEL nor WIRELESS_LABEL is defined, no output will ever be printed"
#endif

struct network_connection {
    const char* label;
    uint8_t status;
};

static void network_connection_print_indicator(
    struct network_connection* conn
) {
    const char* color;
    if (conn->status == INTERFACE_STATUS_INACTIVE) {
        color = INACTIVE_CONNECTION_COLOR;
    }
    else if (conn->status >= GOOD_CONNECTION_QUALITY_THRESHOLD) {
        color = GOOD_CONNECTION_QUALITY_COLOR;
    }
    else if (conn->status >= MEDIUM_CONNECTION_QUALITY_THRESHOLD) {
        color = MEDIUM_CONNECTION_QUALITY_COLOR;
    }
    else {
        color = BAD_CONNECTION_QUALITY_COLOR;
    }

    printf(
        "<span %s foreground='%s'>%s</span>",
        PANGO_PROPS,
        color,
        conn->label
    );
}

void init_connections(
    struct network_connection* connections,
    network_probe probe
) {
    int idx = 0;

    #ifdef CABLE_LABEL

    connections[idx].label = CABLE_LABEL;
    connections[idx].status = network_probe_get_medium_status(
        probe,
        NETWORK_MEDIUM_CABLE
    );
    if (has_exception()) {
        return;
    }
    idx += 1;

    #endif

    #ifdef WIRELESS_LABEL

    connections[idx].label = WIRELESS_LABEL;
    connections[idx].status = network_probe_get_medium_status(
        probe,
        NETWORK_MEDIUM_WIRELESS
    );
    if (has_exception()) {
        return;
    }
    idx += 1;

    #endif
}

int main() {
    int res = 0;

    network_probe probe = network_probe_new();
    if (has_exception()) {
        goto catch;
    }
    struct network_connection connections[CONNECTION_COUNT];
    init_connections(connections, probe);
    if (has_exception()) {
        goto catch;
    }

    /*
     * There is a bug in swaybar that prevents font size from being applied
     * if no other text has been output. Therefore, we print an almost
     * invisible space.
     */
    #ifdef SWAYBAR
    printf("<span size='0.001pt'> </span>");
    #endif

    const struct network_connection* last = connections + CONNECTION_COUNT;
    for (
        struct network_connection* curr = connections;
        curr != last;
        curr += 1
    ) {
        #ifdef LABEL_SEPARATOR
        if (curr != connections) {
            printf(LABEL_SEPARATOR);
        }
        #endif
        network_connection_print_indicator(curr);
    }
    printf("\n");
    goto cleanup;

catch:
    res = 1;
    print_exception();

cleanup:
    network_probe_close(probe);
    return res;
}
