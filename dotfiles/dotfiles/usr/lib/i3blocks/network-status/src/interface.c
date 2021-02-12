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

double wireless_quality(const char* if_name);

const char* interface_type_str(const enum interface_type this) {
    switch (this) {
        case UNSET:
            return "UNSET";

        case CABLE:
            return "CABLE";

        case WIRELESS:
            return "WIRELESS";

        case UNNECESSARY:
            return "UNNECESSARY";

        default:
            return "";
    }
}

struct interface* interface_new() {
    struct interface* new;

    if (!(new = (struct interface*) malloc(sizeof(struct interface)))) {
        perror("interface_new - error while calling malloc for new interface");
        exit(EXIT_FAILURE);
    }
    if (!(new->name = (char*) malloc(sizeof(char)))) {
        perror("interface_new - error while calling malloc for interface "
            "name");

        free(new);
        exit(EXIT_FAILURE);
    }

    *new->name = '\0';
    new->type = UNSET;
    new->status = UNSET_STATUS;
    new->label = "";

    return new;
}

void interface_free(struct interface* this) {
    struct interface* tmp;
    for (tmp = this; this; tmp = this) {
        this = this->next;
        free(tmp->name);
        free(tmp);
    }
}

int interface_has_name(struct interface* this) {
    return *this->name != '\0';
}
int interface_has_type(struct interface* this) {
    return this->type != UNSET;
}
int interface_has_status(struct interface* this) {
    return this->status != UNSET_STATUS;
}
int interface_has_label(struct interface* this) {
    return *this->label != '\0';
}

void interface_set_name(struct interface* this, const char* value) {
    size_t new_bytes = sizeof(char) * (strlen(value) + 1);
    if (!(this->name = (char *) realloc(this->name, new_bytes))) {
        perror("interface_set_name - error while calling realloc");
        exit(EXIT_FAILURE);
    }
    strcpy(this->name, value);
    interface_infer_type(this);
}
void interface_set_label(struct interface* this, const char* value) {
    this->label = value;
}

double interface_check_status(struct interface* this) {
    struct ifreq if_req;
    int socket_id;

    if ((socket_id = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP)) < 0) {
        perror("interface_check_status - error while calling socket");
        exit(EXIT_FAILURE);
    }

    strcpy(if_req.ifr_name, this->name);

    if (ioctl(socket_id, SIOCGIFFLAGS, &if_req) == -1) {
        perror("interface_check_status - error while calling ioctl");
        close(socket_id);
        exit(EXIT_FAILURE);
    }

    close(socket_id);

    if ((if_req.ifr_flags & IFF_UP) && (if_req.ifr_flags & IFF_RUNNING)) {
        this->status = this->type == WIRELESS
            ? wireless_quality(this->name)
            : 100.0;
    }
    else {
        this->status = STATUS_DOWN;
    }

    return this->status;
}

void interface_infer_type(struct interface* this) {
    if (!(strcmp("ethernet", this->name) && strcmp("cable", this->name))
        || is_cable_name(this->name)) {
        this->type = CABLE;
    }
    else if (!(strcmp("wireless", this->name) && strcmp("wifi", this->name))
        || is_wireless_name(this->name)) {
        this->type = WIRELESS;
    }
    else if (interface_has_name(this)) {
        this->type = UNNECESSARY;
    }
}
void interface_infer_label(struct interface* this) {
    if (!interface_has_label(this)) {
        switch (this->type) {
            case CABLE:
                interface_set_label(this, "C");
                break;

            case WIRELESS:
                interface_set_label(this, "W");
                break;

            default:
                break;
        }
    }
}
void interface_infer(struct interface* this) {
    interface_infer_type(this);
    interface_infer_label(this);
}

int interface_match(struct interface* this, const char* name) {
    return !strcmp(name, this->name)
        || (this->type == CABLE && is_cable_name(name))
        || (this->type == WIRELESS && is_wireless_name(name));
}

void interface_validate(struct interface* this) {
    if (!interface_has_label(this)) {
        fprintf(stderr, "Interface lacks label (name: %s, type: %s)\n",
            this->name, interface_type_str(this->type));
        free(this->name);
        exit(EXIT_FAILURE);
    }

    if (!(interface_has_type(this) || interface_has_name(this))) {
        fprintf(stderr, "Interface lacks both type and name (label :%s)\n",
            this->label);
        free(this->name);
        exit(EXIT_FAILURE);
    }
}

int is_cable_name(const char* name) {
    return !(strncmp("en", name, 2) && strncmp("eth", name, 3));
}
int is_wireless_name(const char* name) {
    return !(strncmp("wl", name, 2) && strncmp("wlan", name, 4));
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
