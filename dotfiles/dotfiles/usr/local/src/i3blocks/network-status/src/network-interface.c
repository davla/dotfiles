#include <linux/ethtool_netlink.h>
#include <linux/nl80211.h>
#include <netlink/attr.h>
#include <netlink/errno.h>
#include <netlink/genl/ctrl.h>
#include <netlink/genl/genl.h>
#include <netlink/handlers.h>
#include <netlink/msg.h>
#include <netlink/netlink.h>
#include <netlink/socket.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "exception.h"

#include "network-interface.h"

/**************************************
 * netlink_attrs
 *************************************/

struct netlink_attrs {
    struct nlattr* attrs;
    int len;
};

struct netlink_attrs netlink_attrs_new(struct nl_msg* msg) {
    struct genlmsghdr* msg_header = nlmsg_data(nlmsg_hdr(msg));
    return (struct netlink_attrs) {
        .attrs = genlmsg_attrdata(msg_header, 0),
        .len = genlmsg_attrlen(msg_header, 0),
    };
}

struct netlink_attrs netlink_attrs_find_nested_attr(
    const struct netlink_attrs* this,
    int attr_type
) {
    struct nlattr* attr = nla_find(this -> attrs, this -> len, attr_type);
    if (attr == NULL) {
        set_exception_err(NLE_FAILURE);
        return (struct netlink_attrs) {};
    }
    return (struct netlink_attrs) {
        .attrs = (struct nlattr*) nla_data(attr),
        .len = nla_len(this -> attrs),
    };
}

const char* netlink_attrs_find_string_attr(
    const struct netlink_attrs* this,
    int attr_type
) {
    struct nlattr* attr = nla_find(this -> attrs, this -> len, attr_type);
    if (attr == NULL) {
        set_exception_err(NLE_FAILURE);
        return NULL;
    }
    return nla_get_string(attr);
}

/**************************************
 * network_interface
 *************************************/

struct network_interface* network_interface_new(const char* sys_name) {
    struct network_interface* new;

    if (
        !(new = (struct network_interface*)
            malloc(sizeof(struct network_interface)))
    ) {
        perror("network_interface_new - error when calling malloc for new");
        exit(EXIT_FAILURE);
    }

    size_t sys_name_byte_len = (strlen(sys_name) + 1) * sizeof(char);
    if (!(new->name = (char*) malloc(sys_name_byte_len))) {
        perror("network_interface_new - error when calling malloc for name");
        exit(EXIT_FAILURE);
    }

    strcpy(new->name, sys_name);
    new->next = NULL;

    return new;
}

void network_interface_free(struct network_interface* this) {
    struct network_interface* tmp;
    while (this) {
        tmp = this;
        free(this->name);
        this = this->next;
        free(tmp);
    }
}

/**************************************
 * Interface detection
 *************************************/

typedef struct network_interface** interface_dst;

void interface_dst_set(interface_dst* this, struct network_interface* new) {
    **this = new;
    *this = &(new -> next);
}

int make_cable_interface(struct nl_msg* msg, void* arg) {
    struct netlink_attrs attrs = netlink_attrs_new(msg);

    struct netlink_attrs header_attr = netlink_attrs_find_nested_attr(
        &attrs,
        ETHTOOL_A_LINKMODES_HEADER
    );
    if (has_exception()) {
        SET_EXCEPTION_MSG("ethtool nl_msg has no header attribute");
        return NL_SKIP;
    }

    const char* interface_name = netlink_attrs_find_string_attr(
        &header_attr,
        ETHTOOL_A_HEADER_DEV_NAME
    );
    if (has_exception()) {
        SET_EXCEPTION_MSG("ethtool header has no device name attribute");
        return NL_SKIP;
    }

    interface_dst* dst = (interface_dst*)arg;
    interface_dst_set(dst, network_interface_new(interface_name));

    return NL_OK;
}

int make_wireless_interfaces(struct nl_msg* msg, void* arg) {
    struct netlink_attrs attrs = netlink_attrs_new(msg);
    const char* name = netlink_attrs_find_string_attr(
        &attrs,
        NL80211_ATTR_IFNAME
    );
    if (has_exception()) {
        SET_EXCEPTION_MSG("nl80211 nl_msg has no interface name attribute");
        return NL_SKIP;
    }

    interface_dst* dst = (interface_dst*)arg;
    interface_dst_set(dst, network_interface_new(name));

    return NL_OK;
}

struct network_interface* detect_network_interfaces(
    struct nl_sock* socket,
    enum network_medium medium
) {
    const char* nl_family;
    uint8_t nl_cmd;
    nl_recvmsg_msg_cb_t make_interface;
    switch (medium) {
        case CABLE: {
            nl_family = "ethtool";
            nl_cmd = ETHTOOL_MSG_LINKMODES_GET;
            make_interface = make_cable_interface;
            break;
        }

        case WIRELESS: {
            nl_family = "nl80211";
            nl_cmd = NL80211_CMD_GET_INTERFACE;
            make_interface = make_wireless_interfaces;
            break;
        }

        default: {
            // Exit immediately, as this should be caught at compile-time.
            fprintf(stderr, "%s - unknown network medium: %d\n",
                __func__, medium);
            exit(EXIT_FAILURE);
        }
    }

    struct network_interface* res = NULL;
    interface_dst dst = &res;

    int driver_id = genl_ctrl_resolve(socket, nl_family);
    if (driver_id < 1) {
        SET_EXCEPTION(driver_id, "error when resolving driver");
        return NULL;
    }

    struct nl_msg* msg = nlmsg_alloc();
    if (msg == NULL) {
        SET_EXCEPTION(NLE_FAILURE, "error when allocating nl_mgs");
        goto cleanup;
    }
    if (genlmsg_put(msg, 0, 0, driver_id, 0, NLM_F_DUMP, nl_cmd, 0) == NULL) {
        SET_EXCEPTION(NLE_FAILURE, "error when setting nl_msg header");
        goto cleanup;
    }

    set_exception_err(
        nl_socket_modify_cb(socket, NL_CB_VALID, NL_CB_CUSTOM, make_interface,
            (void*) &dst)
    );
    if (has_exception()) {
        SET_EXCEPTION_MSG("error when setting socket callback");
        goto cleanup;
    }

    int sent_bytes = nl_send_auto(socket, msg);
    if (sent_bytes == 0) {
        SET_EXCEPTION(NLE_FAILURE, "no bytes sent when sending nl_msg");
        goto cleanup_res;
    } else if (sent_bytes < 0) {
        SET_EXCEPTION(sent_bytes, "error when sending nl_msg");
        goto cleanup_res;
    }

    set_exception_err(nl_recvmsgs_default(socket));
    if (has_exception()) {
        SET_EXCEPTION_MSG("error when receiving response");
        goto cleanup_res;
    }

    return res;

cleanup:
    nlmsg_free(msg);

cleanup_res:
    if (res != NULL) {
        network_interface_free(res);
    }
    return NULL;
}


#define WIRELESS_STATUS_UNSET (INTERFACE_STATUS_INACTIVE)

#define WIRELESS_QUALITY_FILE "/proc/net/wireless"
