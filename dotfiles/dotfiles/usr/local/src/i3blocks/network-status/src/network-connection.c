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

struct netlink_attrs netlink_attrs_find_nested_attr(struct netlink_attrs* this,
    int attr_type, const char* err_msg) {
    struct nlattr* attr = nla_find(this -> attrs, this -> len, attr_type);
    if (attr == NULL) {
        fprintf(stderr, "%s: %s\n", err_msg, nl_geterror(NLE_FAILURE));
        exit(EXIT_FAILURE);
    }
    return (struct netlink_attrs) {
        .attrs = (struct nlattr*) nla_data(attr),
        .len = nla_len(this -> attrs),
    };
}

char* netlink_attrs_find_string_attr(struct netlink_attrs* this, int attr_type,
    const char* err_msg) {
    struct nlattr* attr = nla_find(this -> attrs, this -> len, attr_type);
    if (attr == NULL) {
        fprintf(stderr, "%s: %s\n", err_msg, nl_geterror(NLE_FAILURE));
        exit(EXIT_FAILURE);
    }
    return nla_get_string(attr);
}

int nl_debug = 0;

#define NL_ERROR_INIT \
    int err = NLE_SUCCESS; \
    const char* err_msg = "";

#define NL_SET_ERR(error, error_message) \
    err = error; \
    err_msg = error_message;

#define NL_THROW_ERR(error_message) \
    err_msg = error_message; \
    goto catch;

#define NL_THROW(error, error_message) \
    err = error; \
    NL_THROW_ERR(error_message);

#define NL_CATCH_LABEL catch

#define NL_PRINT_ERR \
    fprintf(stderr, "%s - %s: %s\n", __func__, err_msg, nl_geterror(err));

#define NL_CLEANUP(socket) \
    nl_close(socket); \
    nl_socket_free(socket);

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
        ETHTOOL_A_LINKMODES_HEADER,
        "ethtool nl_msg has no header attribute"
    );
    char* interface_name = netlink_attrs_find_string_attr(
        &header_attr,
        ETHTOOL_A_HEADER_DEV_NAME,
        "ethtool header has no device name attribute"
    );

    interface_list* dst = (interface_list*)arg;
    interface_list_append(dst, network_interface_new(interface_name));

    return NL_OK;
}

int make_wireless_interfaces(struct nl_msg* msg, void* arg) {
    struct netlink_attrs attrs = netlink_attrs_new(msg);
    char* name = netlink_attrs_find_string_attr(
        &attrs,
        NL80211_ATTR_IFNAME,
        "nl80211 nl_msg has no interface name attribute"
    );

    interface_list* dst = (interface_list*)arg;
    interface_list_append(dst, network_interface_new(name));

    return NL_OK;
}

void get_interfaces_of_type(
    struct nl_sock* socket,
    const char* nl_family,
    uint8_t nl_cmd,
    nl_recvmsg_msg_cb_t make_interface,
    interface_list* dst
) {
    NL_ERROR_INIT;

    int driver_id = genl_ctrl_resolve(socket, nl_family);
    if (driver_id < 1) {
        NL_THROW(driver_id, "error when resolving driver");
    }

    struct nl_msg* msg = nlmsg_alloc();
    if (msg == NULL) {
        NL_THROW(NLE_FAILURE, "error when allocating nl_mgs");
    }
    if (genlmsg_put(msg, 0, 0, driver_id, 0, NLM_F_DUMP, nl_cmd, 0) == NULL) {
        NL_THROW(NLE_FAILURE, "error when setting nl_msg header");
    }

    err = nl_socket_modify_cb(socket, NL_CB_VALID, NL_CB_CUSTOM,
        make_interface, (void*) dst);
    if (err != 0) {
        NL_THROW_ERR("error when setting socket callback");
    }

    err = nl_send_auto(socket, msg);
    if (err == 0) {
        NL_THROW(NLE_FAILURE, "no bytes sent when sending nl_msg");
        goto catch;
    } else if (err < 0) {
        NL_THROW_ERR("error when sending nl_msg");
    }

    if ((err = nl_recvmsgs_default(socket)) != 0) {
        NL_THROW(err, "error when receiving response");
    }

    return;

NL_CATCH_LABEL:
    fprintf(stderr, "%s(%s) - %s: %s\n", __func__, nl_family, err_msg,
        nl_geterror(err)),
    NL_CLEANUP(socket);
    exit(EXIT_FAILURE);
}

struct network_connection* make_network_connections() {
    NL_ERROR_INIT;

    struct nl_sock* socket = nl_socket_alloc();
    if (socket == NULL) {
        NL_SET_ERR(NLE_FAILURE, "error when creating netlink socket");
        goto catch_no_socket;
    }
    if ((err = genl_connect(socket)) != 0) {
        NL_THROW_ERR("error when connecting netlink socket");
    }

    struct network_connection* res = NULL;
    struct network_connection** next_connection = &res;
    interface_list interfaces = NULL;

    #ifdef CABLE_LABEL
    *next_connection = network_connection_new(CABLE_LABEL, CABLE);
    struct network_connection* cable = *next_connection;
    next_connection = &(cable -> next);

    interfaces = &(cable -> interfaces);
    get_interfaces_of_type(socket, "ethtool", ETHTOOL_MSG_LINKMODES_GET,
        make_cable_interface, &interfaces);
    #endif

    #ifdef WIRELESS_LABEL
    *next_connection = network_connection_new(WIRELESS_LABEL, WIRELESS);
    struct network_connection* wireless = *next_connection;
    next_connection = &(wireless -> next);

    interfaces = &(wireless -> interfaces);
    get_interfaces_of_type(socket, "nl80211", NL80211_CMD_GET_INTERFACE,
        make_wireless_interfaces, &interfaces);
    #endif

    for (struct network_connection* c = res; c != NULL; c = c -> next) {
        for (struct network_interface* i = c -> interfaces; i != NULL; i = i -> next) {
            printf("%s\n", i -> name);
        }
    }
    return res;

NL_CATCH_LABEL:
    NL_CLEANUP(socket);
catch_no_socket:
    NL_PRINT_ERR;
    exit(EXIT_FAILURE);
}
