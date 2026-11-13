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
    double status = INTERFACE_STATUS_INACTIVE;
    struct network_interface* curr_interface;
    int socket_id;

    if ((socket_id = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP)) < 0) {
        perror("network_connection_status - error when opening socket");
        exit(EXIT_FAILURE);
    }

    for (
        curr_interface = this->interfaces;
        curr_interface;
        curr_interface = curr_interface->next
    ) {
        status = network_interface_status(
            curr_interface,
            this->type,
            socket_id
        );
        if (status != INTERFACE_STATUS_INACTIVE) {
            break;
        }
    }

    close(socket_id);
    return status;
}


int is_ifnameindex_end(struct if_nameindex* if_name) {
    return !if_name->if_index && !if_name->if_name;
}

int is_cable_name(const char* name) {
    return !(strncmp("en", name, 2) && strncmp("eth", name, 3));
}

int is_wireless_name(const char* name) {
    return !(strncmp("wl", name, 2) && strncmp("wlan", name, 4));
}

void network_connection_add_interface(
    struct network_connection* this,
    const char* sys_name
) {
    struct network_interface** new;
    for (new = &this->interfaces; *new; new = &(*new)->next);
    *new = network_interface_new(sys_name);
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

// https://github.com/Robpol86/libnl/blob/master/example_c/show_wifi_interface.c
int print_ethernet_interfaces(struct nl_msg* msg, void* arg) {
    struct genlmsghdr* msg_header = nlmsg_data(nlmsg_hdr(msg));
    struct nlattr* msg_attrs = genlmsg_attrdata(msg_header, 0);
    int attrs_len = genlmsg_attrlen(msg_header, 0);

    struct nlattr* header_attr = nla_find(
        msg_attrs, attrs_len, ETHTOOL_A_LINKMODES_HEADER
    );
    if (header_attr == NULL) {
        exit(EXIT_FAILURE);
    }
    struct nlattr* dev_name_attr = nla_find(
        (struct nlattr*) nla_data(header_attr),
        nla_len(header_attr),
        ETHTOOL_A_HEADER_DEV_NAME
    );
    if (dev_name_attr == NULL) {
        exit(EXIT_FAILURE);
    }
    printf("Ethernet interface name: %s\n", nla_get_string(dev_name_attr));

    return 0;
}

int print_wifi_interfaces(struct nl_msg* msg, void* arg) {
    struct genlmsghdr* msg_header = nlmsg_data(nlmsg_hdr(msg));
    struct nlattr* msg_attrs = genlmsg_attrdata(msg_header, 0);
    int attrs_len = genlmsg_attrlen(msg_header, 0);

    struct nlattr* name_attr = nla_find(
        msg_attrs, attrs_len, NL80211_ATTR_IFNAME
    );
    if (name_attr == NULL) {
        exit(EXIT_FAILURE);
    }
    printf("Wi-Fi interface name: %s\n", nla_get_string(name_attr));

    return 0;
}

void get_interfaces_of_type(struct nl_sock* socket, const char* type, uint8_t cmd, nl_recvmsg_msg_cb_t callback) {
    NL_ERROR_INIT;

    int driver_id = genl_ctrl_resolve(socket, type);
    if (driver_id < 1) {
        NL_THROW(driver_id, "error when resolving driver");
    }

    struct nl_msg* msg = nlmsg_alloc();
    if (msg == NULL) {
        NL_THROW(NLE_FAILURE, "error when allocating nl_mgs");
    }
    if (genlmsg_put(msg, 0, 0, driver_id, 0, NLM_F_DUMP, cmd, 0) == NULL) {
        NL_THROW(NLE_FAILURE, "error when setting nl_msg header");
    }

    err = nl_socket_modify_cb(socket, NL_CB_VALID, NL_CB_CUSTOM,
        callback, NULL);
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
    fprintf(stderr, "%s(%s) - %s: %s\n", __func__, type, err_msg,
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

    /*
     * • nl80211 Generic Netlink Family. Query the nl80211 family (NL80211_CMD_GET_INTERFACE) with the interface's ifindex. If the kernel returns wireless interface data (such as NL80211_ATTR_WIPHY or NL80211_ATTR_IFTYPE), the device is wireless; if it returns -ENODEV or -EOPNOTSUPP, it is not an nl80211 wireless device.
     • ethtool Generic Netlink Family. Query the ethtool family (ETHTOOL_MSG_LINKMODES_GET or ETHTOOL_MSG_LINKINFO_GET) to inspect ETHTOOL_A_LINKINFO_PORT (which reports physical ports like PORT_TP for twisted pair or PORT_FIBRE) and supported link modes.
     */

    // genl-ctrl-list | cut -f 2 -d ' ' | xargs -I '{}' printf 'get_interfaces_of_type(socket, "{}");\n' | c
    // get_interfaces_of_type(socket, "nlctrl");
    // get_interfaces_of_type(socket, "VFS_DQUOT");
    // get_interfaces_of_type(socket, "dev-energymodel");
    // get_interfaces_of_type(socket, "thermal");
    // get_interfaces_of_type(socket, "dpll");
    // get_interfaces_of_type(socket, "netdev");
    get_interfaces_of_type(socket, "ethtool", ETHTOOL_MSG_LINKSTATE_GET, print_ethernet_interfaces);
    // get_interfaces_of_type(socket, "psp");
    // get_interfaces_of_type(socket, "devlink");
    // get_interfaces_of_type(socket, "NLBL_MGMT");
    // get_interfaces_of_type(socket, "NLBL_CIPSOv4");
    // get_interfaces_of_type(socket, "NLBL_CALIPSO");
    // get_interfaces_of_type(socket, "NLBL_UNLBL");
    // get_interfaces_of_type(socket, "NCSI");
    // get_interfaces_of_type(socket, "net-shaper");
    // get_interfaces_of_type(socket, "acpi_event");
    // get_interfaces_of_type(socket, "reg_event");
    // get_interfaces_of_type(socket, "tcp_metrics");
    // get_interfaces_of_type(socket, "mptcp_pm");
    // get_interfaces_of_type(socket, "drm-ras");
    // get_interfaces_of_type(socket, "NET_DM");
    // get_interfaces_of_type(socket, "SEG6");
    // get_interfaces_of_type(socket, "IOAM6");
    // get_interfaces_of_type(socket, "handshake");
    // get_interfaces_of_type(socket, "TASKSTATS");
    get_interfaces_of_type(socket, "nl80211", NL80211_CMD_GET_INTERFACE, print_wifi_interfaces);
    // get_interfaces_of_type(socket, "wireguard");

    return NULL;

    struct network_connection* res = NULL;
//
//     struct if_nameindex* if_name_beg, * if_name_curr;
//     struct network_connection** next_res = &res;
//
//     /*
//      * Depending on which macros are defined, some of these variables can be
//      * unused. Let the compiler optimize them away.
//      */
//     struct network_connection* __attribute__((unused)) cable = NULL,
//         __attribute__((unused)) * wireless = NULL;
//
//     if (!(if_name_beg = if_nameindex())) {
//         perror("make_network_connections - error when calling if_nameindex");
//         exit(EXIT_FAILURE);
//     }
//
//     for (
//         if_name_curr = if_name_beg;
//         !is_ifnameindex_end(if_name_curr);
//         if_name_curr += 1
//     ) {
//
//         #ifdef CABLE_LABEL
//         if (is_cable_name(if_name_curr->if_name)) {
//             if (!cable) {
//                 cable = network_connection_new(CABLE_LABEL, CABLE);
//                 *next_res = cable;
//                 next_res = &cable->next;
//             }
//             network_connection_add_interface(cable, if_name_curr->if_name);
//             continue;
//         }
//         #endif
//
//         #ifdef WIRELESS_LABEL
//         if (is_wireless_name(if_name_curr->if_name)) {
//             if (!wireless) {
//                 wireless = network_connection_new(WIRELESS_LABEL, WIRELESS);
//                 *next_res = wireless;
//                 next_res = &wireless->next;
//             }
//             network_connection_add_interface(wireless, if_name_curr->if_name);
//             continue;
//         }
//         #endif
//     }
//
//     if_freenameindex(if_name_beg);
    return res;

NL_CATCH_LABEL:
    NL_CLEANUP(socket);
catch_no_socket:
    NL_PRINT_ERR;
    exit(EXIT_FAILURE);
}
