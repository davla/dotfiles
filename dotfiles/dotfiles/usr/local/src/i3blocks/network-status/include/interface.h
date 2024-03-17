#ifndef INTERFACE_H
#define INTERFACE_H

#define INTERFACE_STATUS_INACTIVE (0.0)

enum interface_type {
    UNSET,
    CABLE,
    WIRELESS,
    UNNECESSARY
};

struct interface {
    char* sys_name;
    enum interface_type type;
    char* label;

    struct interface* next;
};

struct interface* interface_new(const char* sys_name, const char* label, enum interface_type type);
void interface_free(struct interface* this);
double interface_check_status(struct interface* this);

struct interface* make_interfaces();

#endif
