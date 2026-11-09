#ifndef NETWORK_PROBE_H
#define NETWORK_PROBE_H

#include <netlink/handlers.h>
#include <stdint.h>

#define INTERFACE_STATUS_INACTIVE (0)

/*
 * TODO: reword
 * nl_sock is needed in network_probe_get_medium_status.
 * It's less performant if we recreate it internally.
 * It can't be a static, as it needs to be freed.
 * basically a 0-cost abstraction, I'd have network_probe_new anyway.
 */
typedef struct nl_sock* network_probe;

enum network_medium {
    NETWORK_MEDIUM_CABLE,
    NETWORK_MEDIUM_WIRELESS,
};

network_probe network_probe_new();

/*
 * Releases network_probe resources.
 *
 * @arg this    The network_probe resources.
 */
void network_probe_close(network_probe this);

uint8_t network_probe_get_medium_status(
    network_probe this,
    enum network_medium medium
);

#endif
