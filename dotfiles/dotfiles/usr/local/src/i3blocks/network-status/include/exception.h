#ifndef EXCEPTION_H
#define EXCEPTION_H

int get_exception_err();
int has_exception();
int print_exception();
void set_exception(int err, const char* msg, const char* func);
void set_exception_err(int err);
void set_exception_errno();
void set_exception_msg(const char* msg, const char* func);

#define SET_EXCEPTION_MSG(msg) (set_exception_msg(msg, __func__))
#define SET_EXCEPTION(err, msg) (set_exception(err, msg, __func__))

#endif