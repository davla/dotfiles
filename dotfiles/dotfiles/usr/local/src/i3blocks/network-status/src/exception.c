#include <errno.h>
#include <netlink/errno.h>
#include <stdio.h>

#include "exception.h"

static struct {
    int err;
    const char* msg;
    const char* func;
} e = {
    .err = NLE_SUCCESS,
    .msg = "",
    .func = ""
};

int get_exception_err() {
    return e.err;
}

int has_exception() {
    return e.err != NLE_SUCCESS;
}

int print_exception() {
    return fprintf(stderr, "%s - %s: %s\n", e.func, e.msg, nl_geterror(e.err));
}

void set_exception(int err, const char* msg, const char* func) {
    e.err = err;
    e.msg = msg;
    e.func = func;
}

void set_exception_err(int err) {
    e.err = err;
}

void set_exception_errno() {
    e.err = nl_syserr2nlerr(errno);
}

void set_exception_msg(const char* msg, const char* func) {
    e.msg = msg;
    e.func = func;
}
