#include <netlink/errno.h>
#include <stdio.h>
#include "exception.h"

struct exception e = {
    .err = NLE_SUCCESS,
    .msg = "",
    .func = ""
};

int has_exception() {
    return e.err != NLE_SUCCESS;
}

int print_exception() {
    return fprintf(stderr, "%s - %s: %s\n", e.func, e.msg, nl_geterror(e.err));
}

void set_exception_err(int err) {
    e.err = err;
}
