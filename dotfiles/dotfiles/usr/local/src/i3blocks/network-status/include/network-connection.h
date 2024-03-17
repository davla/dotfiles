#ifndef CONNECTION_H
#define CONNECTION_H

#include "network-interface.h"

struct network_connection {
    struct network_interface* interfaces;
    enum network_connection_type type;
    char* label;

    struct network_connection* next;
};

struct network_connection* make_network_connections();
void network_connection_free(struct network_connection* this);

double network_connection_status(struct network_connection* this);

#endif
