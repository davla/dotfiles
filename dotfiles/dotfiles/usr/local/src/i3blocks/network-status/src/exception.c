#include <netlink/errno.h>
#include <stdio.h>
#include "exception.h"

struct exception e = {
    .err = NLE_SUCCESS,
    .msg = ""
};

int has_exception() {
    return e.err != NLE_SUCCESS;
}

int print_exception(const char* func) {
    return fprintf(stderr, "%s - %s: %s\n", func, e.msg, nl_geterror(e.err));
}

void set_exception(int err, const char* msg) {
    e.err = err;
    e.msg = msg;
}

void set_exception_err(int err) {
    e.err = err;
}

void set_exception_msg(const char* msg) {
    e.msg = msg;
}
