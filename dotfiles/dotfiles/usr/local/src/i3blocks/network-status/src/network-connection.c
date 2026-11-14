#include <netlink/errno.h>
#include <netlink/genl/genl.h>
#include <netlink/netlink.h>
#include <netlink/socket.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "exception.h"
#include "network-interface.h"

#include "network-connection.h"

struct network_connection* network_connection_new(
    const char* label,
    const enum network_medium medium
) {
    struct network_connection* new;
    size_t label_byte_len;

    if (
        !(new = (struct network_connection*)
            malloc(sizeof(struct network_connection)))
    ) {
        perror("network_connection_new - error when calling malloc for new");
        exit(EXIT_FAILURE);
    }

    label_byte_len = (strlen(label) + 1) * sizeof(char);
    if (!(new->label = (char*) malloc(label_byte_len))) {
        perror("network_connection_new - error when calling malloc for label");
        free(new);
        exit(EXIT_FAILURE);
    }

    new->interfaces = NULL;
    strcpy(new->label, label);
    new->medium = medium;
    new->next = NULL;

    return new;
}

void network_connection_free(struct network_connection* this) {
    struct network_connection* tmp;
    while (this) {
        tmp = this;
        network_interface_free(this->interfaces);
        free(this->label);
        this = this->next;
        free(tmp);
    }
}

int nl_debug = 0;

struct network_connection* detect_network_connections() {
    SET_EXCEPTION(NLE_FAILURE, "testytest");
    return NULL;

    struct nl_sock* socket = nl_socket_alloc();
    if (socket == NULL) {
        SET_EXCEPTION(NLE_FAILURE, "error when creating netlink socket");
        return NULL;
    }
    set_exception_err(genl_connect(socket));
    if (has_exception()) {
        SET_EXCEPTION_MSG("error when connecting netlink socket");
        goto cleanup_socket;
    }

    struct network_connection* res = NULL;
    struct network_connection** next_connection = &res;

    #ifdef CABLE_LABEL
    *next_connection = network_connection_new(CABLE_LABEL, CABLE);
    struct network_connection* cable = *next_connection;
    next_connection = &(cable->next);

    cable->interfaces = detect_network_interfaces(socket, CABLE);
    if (has_exception()) {
        goto cleanup_res;
    }
    #endif

    #ifdef WIRELESS_LABEL
    *next_connection = network_connection_new(WIRELESS_LABEL, WIRELESS);
    struct network_connection* wireless = *next_connection;
    next_connection = &(wireless->next);

    wireless->interfaces = detect_network_interfaces(socket, WIRELESS);
    if (has_exception()) {
        goto cleanup_res;
    }
    #endif

    for (struct network_connection* c = res; c != NULL; c = c->next) {
        for (struct network_interface* i = c->interfaces; i != NULL; i = i->next) {
            printf("%s\n", i->name);
        }
    }
    return res;

cleanup_res:
    network_connection_free(res);

cleanup_socket:
    nl_close(socket);
    nl_socket_free(socket);
    return NULL;
}

double network_connection_status(struct network_connection* this) {
    double sum = 0;
    size_t len = 0;
    struct network_interface* curr_interface;

    for (
        curr_interface = this->interfaces;
        curr_interface != NULL;
        curr_interface = curr_interface->next
    ) {
        sum += curr_interface->status;
        len += 1;
    }

    return sum / len;
}