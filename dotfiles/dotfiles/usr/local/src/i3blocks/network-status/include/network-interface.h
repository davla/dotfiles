#ifndef INTERFACE_H
#define INTERFACE_H

#include <netlink/socket.h>

#define INTERFACE_STATUS_INACTIVE (0.0)

enum network_medium {
    CABLE,
    WIRELESS,
};

struct network_interface {
    double status;
    char* name;
    enum network_medium medium;

    struct network_interface* next;
};

struct network_interface* detect_network_interfaces(
    struct nl_sock* socket,
    enum network_medium medium
);
void network_interface_free(struct network_interface* this);

#endif
