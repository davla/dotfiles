#include "exception.h"
#include <linux/ethtool_netlink_generated.h>
#include <linux/netlink.h>
#include <netlink/errno.h>
#include <net/if.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <netlink/socket.h>
#include <netlink/netlink.h>
#include <netlink/genl/genl.h>
#include <netlink/handlers.h>
#include <netlink/msg.h>
#include <netlink/genl/ctrl.h>
#include <linux/ethtool_netlink.h>
#include <linux/nl80211.h>

#include "network-connection.h"
#include "netlink/attr.h"
#include "network-interface.h"

struct network_connection* network_connection_new(
    const char* label,
    const enum network_connection_type type
) {
    struct network_connection* new;
    size_t label_byte_len;

    if (
        !(new = (struct network_connection*)
            malloc(sizeof(struct network_connection)))
    ) {
        perror("network_connection_new - error when calling malloc for new");
        exit(EXIT_FAILURE);
    }

    label_byte_len = (strlen(label) + 1) * sizeof(char);
    if (!(new->label = (char*) malloc(label_byte_len))) {
        perror("network_connection_new - error when calling malloc for label");
        free(new);
        exit(EXIT_FAILURE);
    }

    new->interfaces = NULL;
    strcpy(new->label, label);
    new->type = type;
    new->next = NULL;

    return new;
}

void network_connection_free(struct network_connection* this) {
    struct network_connection* tmp;
    while (this) {
        tmp = this;
        network_interface_free(this->interfaces);
        free(this->label);
        this = this->next;
        free(tmp);
    }
}

double network_connection_status(struct network_connection* this) {
    return 0;
}

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

int nl_debug = 0;

typedef struct network_interface** interface_list;

void interface_list_append(
    interface_list* this,
    struct network_interface* new
) {
    **this = new;
    *this = &(new -> next);
}

// https://github.com/Robpol86/libnl/blob/master/example_c/show_wifi_interface.c
int make_cable_interface(struct nl_msg* msg, void* arg) {
    struct netlink_attrs attrs = netlink_attrs_new(msg);

    struct netlink_attrs header_attr = netlink_attrs_find_nested_attr(
        &attrs,
        ETHTOOL_A_LINKMODES_HEADER
    );
    if (has_exception()) {
        set_exception_msg("ethtool nl_msg has no header attribute");
        return NL_SKIP;
    }

    const char* interface_name = netlink_attrs_find_string_attr(
        &header_attr,
        ETHTOOL_A_HEADER_DEV_NAME
    );
    if (has_exception()) {
        set_exception_msg("ethtool header has no device name attribute");
        return NL_SKIP;
    }

    interface_list* dst = (interface_list*)arg;
    interface_list_append(dst, network_interface_new(interface_name));

    return NL_OK;
}

int make_wireless_interfaces(struct nl_msg* msg, void* arg) {
    struct netlink_attrs attrs = netlink_attrs_new(msg);
    const char* name = netlink_attrs_find_string_attr(
        &attrs,
        NL80211_ATTR_IFNAME
    );
    if (has_exception()) {
        set_exception_msg("nl80211 nl_msg has no interface name attribute");
        return NL_SKIP;
    }

    interface_list* dst = (interface_list*)arg;
    interface_list_append(dst, network_interface_new(name));

    return NL_OK;
}

void get_interfaces_of_family(
    struct nl_sock* socket,
    const char* nl_family,
    uint8_t nl_cmd,
    nl_recvmsg_msg_cb_t make_interface,
    interface_list* dst
) {
    char err_msg_func[strlen(__func__) + strlen(nl_family) + 2 + 1];

    int driver_id = genl_ctrl_resolve(socket, nl_family);
    if (driver_id < 1) {
        set_exception(driver_id, "error when resolving driver");
        goto catch;
    }

    struct nl_msg* msg = nlmsg_alloc();
    if (msg == NULL) {
        set_exception(NLE_FAILURE, "error when allocating nl_mgs");
        goto catch;
    }
    if (genlmsg_put(msg, 0, 0, driver_id, 0, NLM_F_DUMP, nl_cmd, 0) == NULL) {
        set_exception(NLE_FAILURE, "error when setting nl_msg header");
        goto catch;
    }

    set_exception_err(
        nl_socket_modify_cb(socket, NL_CB_VALID, NL_CB_CUSTOM, make_interface,
            (void*) dst)
    );
    if (has_exception()) {
        set_exception_msg("error when setting socket callback");
        goto catch;
    }

    int sent_bytes = nl_send_auto(socket, msg);
    if (sent_bytes == 0) {
        set_exception(NLE_FAILURE, "no bytes sent when sending nl_msg");
        goto catch;
    } else if (sent_bytes < 0) {
        set_exception(sent_bytes, "error when sending nl_msg");
        goto catch;
    }

    set_exception_err(nl_recvmsgs_default(socket));
    if (has_exception()) {
        set_exception_msg("error when receiving response");
        goto catch;
    }

    return;

catch:
    sprintf(err_msg_func, "%s(%s)", __func__, nl_family);
    print_exception(err_msg_func);
}

struct network_connection* make_network_connections() {
    struct nl_sock* socket = nl_socket_alloc();
    if (socket == NULL) {
        set_exception(NLE_FAILURE, "error when creating netlink socket");
        goto catch;
    }
    set_exception_err(genl_connect(socket));
    if (has_exception()) {
        set_exception_msg("error when connecting netlink socket");
        goto cleanup;
    }

    struct network_connection* res = NULL;
    struct network_connection** next_connection = &res;
    interface_list interfaces = NULL;

    #ifdef CABLE_LABEL
    *next_connection = network_connection_new(CABLE_LABEL, CABLE);
    struct network_connection* cable = *next_connection;
    next_connection = &(cable -> next);

    interfaces = &(cable -> interfaces);
    get_interfaces_of_family(socket, "ethtool", ETHTOOL_MSG_LINKMODES_GET,
        make_cable_interface, &interfaces);
    if (has_exception()) {
        goto cleanup;
    }
    #endif

    #ifdef WIRELESS_LABEL
    *next_connection = network_connection_new(WIRELESS_LABEL, WIRELESS);
    struct network_connection* wireless = *next_connection;
    next_connection = &(wireless -> next);

    interfaces = &(wireless -> interfaces);
    get_interfaces_of_family(socket, "nl80211", NL80211_CMD_GET_INTERFACE,
        make_wireless_interfaces, &interfaces);
    if (has_exception()) {
        goto cleanup;
    }
    #endif

    for (struct network_connection* c = res; c != NULL; c = c -> next) {
        for (struct network_interface* i = c -> interfaces; i != NULL; i = i -> next) {
            printf("%s\n", i -> name);
        }
    }
    return res;

cleanup:
    nl_close(socket);
    nl_socket_free(socket);
catch:
    print_exception(__func__);
    return NULL;
}
