#ifndef INTERFACE_H
#define INTERFACE_H

#define INTERFACE_STATUS_INACTIVE (0.0)

enum network_connection_type {
    CABLE,
    WIRELESS,
};

struct network_interface {
    char* name;
    double status;

    struct network_interface* next;
};

struct network_interface* network_interface_new(const char* sys_name);
void network_interface_free(struct network_interface* this);

#endif
