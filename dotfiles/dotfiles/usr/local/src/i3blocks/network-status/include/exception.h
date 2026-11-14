#ifndef EXCEPTION_H
#define EXCEPTION_H

#include <netlink/errno.h>

struct exception {
    int err;
    const char* msg;
    const char* func;
};

extern struct exception e;

int has_exception();
int print_exception();
void set_exception_err(int err);
#define SET_EXCEPTION_MSG(message) \
    e.msg = message; \
    e.func = __func__;
#define SET_EXCEPTION(error, message) \
    set_exception_err(error); \
    SET_EXCEPTION_MSG(message);

#endif