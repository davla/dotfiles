#ifndef CONNECTION_H
#define CONNECTION_H

#include "network-interface.h"

struct network_connection {
    struct network_interface* interfaces;
    enum network_medium medium;
    char* label;

    struct network_connection* next;
};

struct network_connection* detect_network_connections();
void network_connection_free(struct network_connection* this);

double network_connection_status(struct network_connection* this);

#endif
