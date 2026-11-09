#ifndef NETLINK_MEDIUM_H
#define NETLINK_MEDIUM_H

#include <netlink/msg.h>
#include <stdint.h>

struct netlink_network_medium {
    const char* netlink_family_name;
    uint8_t get_interfaces_cmd;
    nl_recvmsg_msg_cb_t append_status_msg;
    nl_recvmsg_msg_cb_t aggr_status;
};

extern const struct netlink_network_medium netlink_cable;
extern const struct netlink_network_medium netlink_wireless;

#endif
