#include <netlink/errno.h>
#include <netlink/genl/genl.h>
#include <netlink/msg.h>
#include <stdlib.h>

#include "exception.h"

#include "netlink-utils.h"

struct nl_msg* create_genl_msg(
    int nl_family_id,
    int nl_msg_flags,
    uint8_t nl_cmd
) {
    struct nl_msg* msg = nlmsg_alloc();
    if (msg == NULL) {
        SET_EXCEPTION(NLE_NOMEM, "error when allocating nl_mgs");
        return NULL;
    }

    void* msg_header = genlmsg_put(msg, NL_AUTO_PORT, NL_AUTO_SEQ,
        nl_family_id, 0, nl_msg_flags, nl_cmd, 0);
    if (msg_header == NULL) {
        SET_EXCEPTION(NLE_MSG_TOOSHORT, "error when setting nl_msg header");
        nlmsg_free(msg);
        return NULL;
    }

    return msg;
}

void status_msgs_context_init(
    struct status_msgs_context* this,
    int netlink_family_id
) {
    this->netlink_family_id = netlink_family_id;
    this->msgs = NULL;
    this->last_msg = &(this->msgs);
}

void status_msgs_context_add_msg(
    struct status_msgs_context* this,
    struct nl_msg* msg
) {
    #define SIZE (sizeof(struct nl_msg_list_node))
    struct nl_msg_list_node* node = (struct nl_msg_list_node*) malloc(SIZE);
    if (node == NULL) {
        set_exception_errno();
        SET_EXCEPTION_MSG("error when allocating nl_msg_list_item");
        return;
    }

    node->msg = msg;
    node->next = NULL;

    *(this->last_msg) = node;
    this->last_msg = &(node->next);
}

void status_msgs_context_free(struct status_msgs_context* this) {
    struct nl_msg_list_node* curr = this->msgs;
    while (curr != NULL) {
        struct nl_msg_list_node* tmp = curr->next;
        nlmsg_free(curr->msg);
        free(curr);
        curr = tmp;
    }
    this->msgs = NULL;
    this->last_msg = NULL;
}
