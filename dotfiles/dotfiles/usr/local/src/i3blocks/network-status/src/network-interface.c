#include <net/if.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

#include "network-interface.h"

#define WIRELESS_STATUS_UNSET (INTERFACE_STATUS_INACTIVE)

#define WIRELESS_QUALITY_FILE "/proc/net/wireless"

struct network_interface* network_interface_new(const char* sys_name) {
    struct network_interface* new;

    if (!(new = (struct network_interface*) malloc(sizeof(struct network_interface)))) {
        perror("network_interface_new - error while calling malloc for new");
        exit(EXIT_FAILURE);
    }

    size_t sys_name_byte_len = (strlen(sys_name) + 1) * sizeof(char);
    if (!(new->name = (char*) malloc(sys_name_byte_len))) {
        perror("network_interface_new - error while calling malloc for name");
        exit(EXIT_FAILURE);
    }

    strcpy(new->name, sys_name);
    new->next = NULL;

    return new;
}

void network_interface_free(struct network_interface* this) {
    struct network_interface* tmp;
    while (this) {
        tmp = this;
        free(this->name);
        this = this->next;
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
                return WIRELESS_STATUS_UNSET;
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

double network_interface_status(
    struct network_interface* this,
    enum network_connection_type connection_type,
    int socket
) {
    struct ifreq if_req;

    strcpy(if_req.ifr_name, this->name);
    if (ioctl(socket, SIOCGIFFLAGS, &if_req) == -1) {
        perror("network_interface_status - error while calling ioctl");
        close(socket);
        exit(EXIT_FAILURE);
    }

    if (!((if_req.ifr_flags & IFF_UP) && (if_req.ifr_flags & IFF_RUNNING))) {
        return INTERFACE_STATUS_INACTIVE;
    }

    return connection_type == WIRELESS
        ? wireless_quality(this->name)
        : 100.0;
}
