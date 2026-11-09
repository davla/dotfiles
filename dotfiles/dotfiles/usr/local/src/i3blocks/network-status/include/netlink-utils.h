#ifndef NETLINK_UTILS_H
#define NETLINK_UTILS_H

#include <netlink/msg.h>

struct nl_msg* create_genl_msg(
    int nl_family_id,
    int nl_msg_flags,
    uint8_t nl_cmd
);

// TODO: Triple pointer, same memory and clock cycles, but more readable
struct nl_msg_list_node {
    struct nl_msg* msg;
    struct nl_msg_list_node* next;
};

struct status_msgs_context {
    int netlink_family_id;
    struct nl_msg_list_node* msgs;
    struct nl_msg_list_node** last_msg;
};

void status_msgs_context_init(
    struct status_msgs_context* this,
    int netlink_family_id
);
void status_msgs_context_free(struct status_msgs_context* this);
void status_msgs_context_add_msg(
    struct status_msgs_context* this,
    struct nl_msg* msg
);

#endif