#include <errno.h>
#include <net/if.h>
#include <netinet/in.h>
#include <stdio.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <unistd.h>

#include "common.h"
#include "interface.h"

#define UNSET_STATUS (-1.0)

#define WIRELESS_QUALITY_FILE "/proc/net/wireless"

struct interface* interface_new(const char* sys_name, const char* label, enum interface_type type) {
    struct interface* new;
    size_t sys_name_byte_len, label_byte_len;

    if (!(new = (struct interface*) malloc(sizeof(struct interface)))) {
        perror("interface_new - error while calling malloc for new interface");
        exit(EXIT_FAILURE);
    }

    sys_name_byte_len = (strlen(sys_name) + 1) * sizeof(char);
    if (!(new->sys_name = (char*) malloc(sys_name_byte_len))) {
        perror("interface_new - error while calling malloc for interface "
            "name");

        free(new);
        exit(EXIT_FAILURE);
    }

    label_byte_len = (strlen(label) + 1) * sizeof(char);
    if (!(new->label = (char*) malloc(label_byte_len))) {
        perror("interface_new - error while calling malloc for interface "
            "label");

        free(new->label);
        free(new);
        exit(EXIT_FAILURE);
    }

    strcpy(new->sys_name, sys_name);
    strcpy(new->label, label);
    new->type = type;
    new->next = NULL;

    return new;
}

void interface_free(struct interface* this) {
    struct interface* tmp;
    for (tmp = this; this; tmp = this) {
        this = this->next;
        free(tmp->sys_name);
        free(tmp->label);
        free(tmp);
    }
}

double wireless_quality(const char* if_name) {
    FILE* quality_file;
    double quality;
    size_t n;
    char* line = NULL;
    size_t if_name_length = strlen(if_name);

    if (!(quality_file = fopen(WIRELESS_QUALITY_FILE, "r"))) {
        perror("wireless_quality - couldn't open " WIRELESS_QUALITY_FILE);
        exit(EXIT_FAILURE);
    }

    do {
        free(line);
        line = NULL;
        n = 0;

        if (getline(&line, &n, quality_file) == -1) {
            if (feof(quality_file)) {
                fprintf(stderr, "Reached EOF while scanning for interface %s "
                    "in " WIRELESS_QUALITY_FILE "\n", if_name);

                fclose(quality_file);
                free(line);
                return UNSET_STATUS;
            }

            perror("Couldn't read line from " WIRELESS_QUALITY_FILE);

            fclose(quality_file);
            free(line);
            exit(EXIT_FAILURE);
        }

    } while (strncmp(if_name, line, if_name_length));

    sscanf(line, "%*s %*d %lf", &quality);

    fclose(quality_file);
    free(line);

    return quality * 100.0 / 70.0;
}

double interface_check_status(struct interface* this) {
    struct ifreq if_req;
    int socket_id;

    if ((socket_id = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP)) < 0) {
        perror("interface_check_status - error while calling socket");
        exit(EXIT_FAILURE);
    }

    strcpy(if_req.ifr_name, this->sys_name);

    if (ioctl(socket_id, SIOCGIFFLAGS, &if_req) == -1) {
        perror("interface_check_status - error while calling ioctl");
        close(socket_id);
        exit(EXIT_FAILURE);
    }

    close(socket_id);

    if ((if_req.ifr_flags & IFF_UP) && (if_req.ifr_flags & IFF_RUNNING)) {
        return this->type == WIRELESS
            ? wireless_quality(this->sys_name)
            : 100.0;
    }
    else {
        return INTERFACE_STATUS_INACTIVE;
    }
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

struct interface* make_interfaces() {
    struct if_nameindex* if_name_beg, * if_name_curr;
    struct interface* res = NULL, * tmp = NULL;
    struct interface** next_new = &res;

    if (!(if_name_beg = if_nameindex())) {
        perror("interfaces_filter - error while calling if_nameindex");
        exit(EXIT_FAILURE);
    }

    for (if_name_curr = if_name_beg; !is_ifnameindex_end(if_name_curr); if_name_curr += 1) {
        #ifdef CABLE_LABEL

        if (is_cable_name(if_name_curr->if_name)) {
            tmp = interface_new(if_name_curr->if_name, CABLE_LABEL, CABLE);
            *next_new = tmp;
            next_new = &tmp->next;
            continue;
        }

        #endif

        #ifdef WIRELESS_LABEL

        if (is_wireless_name(if_name_curr->if_name)) {
            tmp = interface_new(if_name_curr->if_name, WIRELESS_LABEL, WIRELESS);
            *next_new = tmp;
            next_new = &tmp->next;
            continue;
        }

        #endif
    }

    if_freenameindex(if_name_beg);
    return res;
}

// int interface_match(struct interface* this, const char* name) {
//     return !strcmp(name, this->name)
//         || (this->type == CABLE && is_cable_name(name))
//         || (this->type == WIRELESS && is_wireless_name(name));
// }
