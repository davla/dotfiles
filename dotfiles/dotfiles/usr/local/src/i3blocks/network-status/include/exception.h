#ifndef EXCEPTION_H
#define EXCEPTION_H

#include <netlink/errno.h>

struct exception {
    int err;
    const char* msg;
};

extern struct exception e;

int has_exception();
int print_exception(const char* func);
void set_exception(int err, const char* msg);
void set_exception_err(int err);
void set_exception_msg(const char* msg);

#endif