#include <net/if.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "network-connection.h"

struct network_connection* network_connection_new(
    const char* label,
    const enum network_connection_type type
) {
    struct network_connection* new;
    size_t label_byte_len;

    if (!(new = (struct network_connection*) malloc(sizeof(struct network_connection)))) {
        perror("interface_new - error while calling malloc for new");
        exit(EXIT_FAILURE);
    }

    label_byte_len = (strlen(label) + 1) * sizeof(char);
    if (!(new->label = (char*) malloc(label_byte_len))) {
        perror("interface_new - error while calling malloc for label");
        free(new);
        exit(EXIT_FAILURE);
    }

    new->interfaces = NULL;
    strcpy(new->label, label);
    new->type = type;
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

double network_connection_status(struct network_connection* this) {
    double status = INTERFACE_STATUS_INACTIVE;
    struct network_interface* curr_interface;
    int socket_id;

    if ((socket_id = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP)) < 0) {
        perror("interface_check_status - error while calling socket");
        exit(EXIT_FAILURE);
    }

    for (curr_interface = this->interfaces; curr_interface; curr_interface = curr_interface->next) {
        status = network_interface_status(curr_interface, this->type, socket_id);
        if (status != INTERFACE_STATUS_INACTIVE) {
            break;
        }
    }

    close(socket_id);
    return status;
}


int is_ifnameindex_end(struct if_nameindex* if_name) {
    return !if_name->if_index && !if_name->if_name;
}

int is_cable_name(const char* name) {
    return !(strncmp("en", name, 2) && strncmp("eth", name, 3));
}

int is_wireless_name(const char* name) {
    return !(strncmp("wl", name, 2) && strncmp("wlan", name, 4));
}

void network_connection_add_interface(struct network_connection* this, const char* sys_name) {
    struct network_interface** new;
    for (new = &this->interfaces; *new; new = &(*new)->next);
    *new = network_interface_new(sys_name);
}

struct network_connection* make_network_connections() {
    struct if_nameindex* if_name_beg, * if_name_curr;
    struct network_connection* res = NULL;
    struct network_connection** next_res = &res;

    /*
     * Depending on which macros are defined, some of these variables can be
     * unused. Let the compiler optimize them away.
     */
    struct network_connection* __attribute__((unused)) cable = NULL,
        __attribute__((unused)) * wireless = NULL;

    if (!(if_name_beg = if_nameindex())) {
        perror("interfaces_filter - error while calling if_nameindex");
        exit(EXIT_FAILURE);
    }

    for (if_name_curr = if_name_beg; !is_ifnameindex_end(if_name_curr); if_name_curr += 1) {

        #ifdef CABLE_LABEL
        if (is_cable_name(if_name_curr->if_name)) {
            if (!cable) {
                cable = network_connection_new(CABLE_LABEL, CABLE);
                *next_res = cable;
                next_res = &cable->next;
            }
            network_connection_add_interface(cable, if_name_curr->if_name);
            continue;
        }
        #endif

        #ifdef WIRELESS_LABEL
        if (is_wireless_name(if_name_curr->if_name)) {
            if (!wireless) {
                wireless = network_connection_new(WIRELESS_LABEL, WIRELESS);
                *next_res = wireless;
                next_res = &wireless->next;
            }
            network_connection_add_interface(wireless, if_name_curr->if_name);
            continue;
        }
        #endif
    }

    if_freenameindex(if_name_beg);
    return res;
}
