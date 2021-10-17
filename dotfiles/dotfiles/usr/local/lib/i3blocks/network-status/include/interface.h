#ifndef INTERFACE_H
#define INTERFACE_H

#define STATUS_DOWN (0.0)

enum interface_type {
    UNSET,
    CABLE,
    WIRELESS,
    UNNECESSARY
};

struct interface {
    char* name;
    enum interface_type type;
    const char* label;
    double status;
    struct interface* next;
};

const char* interface_type_str(const enum interface_type this);

struct interface* interface_new();
void interface_free(struct interface* this);

int interface_has_name(struct interface* this);
int interface_has_type(struct interface* this);
int interface_has_status(struct interface* this);
int interface_has_label(struct interface* this);

void interface_set_name(struct interface* this, const char* value);
void interface_set_label(struct interface* this, const char* value);

double interface_check_status(struct interface* this);
void interface_infer_type(struct interface* this);
void interface_infer_label(struct interface* this);
void interface_infer(struct interface* this);
int interface_match(struct interface* this, const char* name);
void interface_validate(struct interface* this);

int is_cable_name(const char* name);
int is_wireless_name(const char* name);

#endif
