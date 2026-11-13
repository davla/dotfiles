#include <netlink/errno.h>
#include <errno.h>
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
#include <linux/nl80211.h>

#include "network-connection.h"

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


void print_rta_type(int type) {
	switch (type) {
		case IFLA_UNSPEC: printf("IFLA_UNSPEC (%d)", IFLA_UNSPEC); break;
		case IFLA_ADDRESS: printf("IFLA_ADDRESS (%d)", IFLA_ADDRESS); break;
		case IFLA_BROADCAST: printf("IFLA_BROADCAST (%d)", IFLA_BROADCAST); break;
		case IFLA_IFNAME: printf("IFLA_IFNAME (%d)", IFLA_IFNAME); break;
		case IFLA_MTU: printf("IFLA_MTU (%d)", IFLA_MTU); break;
		case IFLA_LINK: printf("IFLA_LINK (%d)", IFLA_LINK); break;
		case IFLA_QDISC: printf("IFLA_QDISC (%d)", IFLA_QDISC); break;
		case IFLA_STATS: printf("IFLA_STATS (%d)", IFLA_STATS); break;
		case IFLA_COST: printf("IFLA_COST (%d)", IFLA_COST); break;
		case IFLA_PRIORITY: printf("IFLA_PRIORITY (%d)", IFLA_PRIORITY); break;
		case IFLA_MASTER: printf("IFLA_MASTER (%d)", IFLA_MASTER); break;
		case IFLA_WIRELESS: printf("IFLA_WIRELESS (%d)", IFLA_WIRELESS); break;
		case IFLA_PROTINFO: printf("IFLA_PROTINFO (%d)", IFLA_PROTINFO); break;
		case IFLA_TXQLEN: printf("IFLA_TXQLEN (%d)", IFLA_TXQLEN); break;
		case IFLA_MAP: printf("IFLA_MAP (%d)", IFLA_MAP); break;
		case IFLA_WEIGHT: printf("IFLA_WEIGHT (%d)", IFLA_WEIGHT); break;
		case IFLA_OPERSTATE: printf("IFLA_OPERSTATE (%d)", IFLA_OPERSTATE); break;
		case IFLA_LINKMODE: printf("IFLA_LINKMODE (%d)", IFLA_LINKMODE); break;
		case IFLA_LINKINFO: printf("IFLA_LINKINFO (%d)", IFLA_LINKINFO); break;
		case IFLA_NET_NS_PID: printf("IFLA_NET_NS_PID (%d)", IFLA_NET_NS_PID); break;
		case IFLA_IFALIAS: printf("IFLA_IFALIAS (%d)", IFLA_IFALIAS); break;
		case IFLA_NUM_VF: printf("IFLA_NUM_VF (%d)", IFLA_NUM_VF); break;
		case IFLA_VFINFO_LIST: printf("IFLA_VFINFO_LIST (%d)", IFLA_VFINFO_LIST); break;
		case IFLA_STATS64: printf("IFLA_STATS64 (%d)", IFLA_STATS64); break;
		case IFLA_VF_PORTS: printf("IFLA_VF_PORTS (%d)", IFLA_VF_PORTS); break;
		case IFLA_PORT_SELF: printf("IFLA_PORT_SELF (%d)", IFLA_PORT_SELF); break;
		case IFLA_AF_SPEC: printf("IFLA_AF_SPEC (%d)", IFLA_AF_SPEC); break;
		case IFLA_GROUP: printf("IFLA_GROUP (%d)", IFLA_GROUP); break;
		case IFLA_NET_NS_FD: printf("IFLA_NET_NS_FD (%d)", IFLA_NET_NS_FD); break;
		case IFLA_EXT_MASK: printf("IFLA_EXT_MASK (%d)", IFLA_EXT_MASK); break;
		case IFLA_PROMISCUITY: printf("IFLA_PROMISCUITY (%d)", IFLA_PROMISCUITY); break;
		case IFLA_NUM_TX_QUEUES: printf("IFLA_NUM_TX_QUEUES (%d)", IFLA_NUM_TX_QUEUES); break;
		case IFLA_NUM_RX_QUEUES: printf("IFLA_NUM_RX_QUEUES (%d)", IFLA_NUM_RX_QUEUES); break;
		case IFLA_CARRIER: printf("IFLA_CARRIER (%d)", IFLA_CARRIER); break;
		case IFLA_PHYS_PORT_ID: printf("IFLA_PHYS_PORT_ID (%d)", IFLA_PHYS_PORT_ID); break;
		case IFLA_CARRIER_CHANGES: printf("IFLA_CARRIER_CHANGES (%d)", IFLA_CARRIER_CHANGES); break;
	}
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

static int network_connections_from_nl_msg(struct nl_msg *msg, void* arg) {
    // struct network_connection** res = arg;
    struct nlmsghdr *msg_header = nlmsg_hdr(msg);
    struct ifinfomsg *interfaces_header = NLMSG_DATA(msg_header);
    struct rtattr *next_interface = IFLA_RTA(interfaces_header);
    int remaining = msg_header->nlmsg_len
        - NLMSG_LENGTH(sizeof(*interfaces_header));

    char name[100];
    printf("---------------\n");
    printf("Type: %s\n", nl_llproto2str(interfaces_header -> ifi_type, name, 100));
    printf("Family type: %s\n", nl_nlfamily2str(interfaces_header -> ifi_family, name, 100));
    printf("Flags %s\n", nl_nlmsg_flags2str(interfaces_header -> ifi_flags, name, 100));

    // printf("Got something.\n");
    // nl_msg_dump(msg, stdout);

    while (RTA_OK(next_interface, remaining)) {
        print_rta_type(next_interface -> rta_type);
        // switch (next_interface -> rta_type) {
        //     case
        // }
        printf(" - %d: %s\n", interfaces_header->ifi_index, (char *) RTA_DATA(next_interface));
        next_interface = RTA_NEXT(next_interface, remaining);
    }

    return NL_OK;
}

// https://github.com/Robpol86/libnl/blob/master/example_c/show_wifi_interface.c
int print_interface(struct nl_msg* msg, void* arg) {
    printf("Something\n");
    return 0;
}

int nl_debug = 0;

void get_interfaces_of_type(struct nl_sock* socket, const char* type) {
    int err = NLE_SUCCESS;
    const char* err_msg = "";

    int driver_id = genl_ctrl_resolve(socket, type);
    if (driver_id < 1) {
        err = driver_id;
        err_msg = "error when resolving driver";
        goto catch;
    }

    struct nl_msg* msg = nlmsg_alloc();
    if (msg == NULL) {
        err = NLE_FAILURE;
        err_msg = "error when allocating nl_mgs";
        goto catch;
    }
    // TODO: NL80211_CMD_GET_INTERFACE doesn't look very generic
    if (genlmsg_put(msg, 0, 0, driver_id, 0, NLM_F_DUMP, NL80211_CMD_GET_INTERFACE, 0) == NULL) {
        err = NLE_FAILURE;
        err_msg = "error when setting nl_msg header";
        goto catch;
    }

    err = nl_socket_modify_cb(socket, NL_CB_VALID, NL_CB_CUSTOM,
        print_interface, NULL);
    if (err != 0) {
        err_msg = "error when setting socket callback";
        goto catch;
    }

    err = nl_send_auto(socket, msg);
    if (err == 0) {
        err = NLE_FAILURE;
        err_msg = "no bytes sent when sending nl_msg";
        goto catch;
    } else if (err < 0) {
        err_msg = "error when sending nl_msg";
        goto catch;
    }

    if ((err = nl_recvmsgs_default(socket)) != 0) {
        err_msg = "error when receiving response";
        goto catch;
    }

    return;

catch:
    fprintf(stderr, "get_interfaces_of_type(%s) - %s: %s\n", type, err_msg,
        nl_geterror(err));
    nl_close(socket);
    nl_socket_free(socket);
    exit(EXIT_FAILURE);
}

struct network_connection* make_network_connections() {
    int err = NLE_SUCCESS;
    const char* err_msg = "";

    struct nl_sock* socket = nl_socket_alloc();
    if (socket == NULL) {
        err = NLE_FAILURE;
        err_msg = "make_network_connections - error when creating socket";
        goto catch_no_socket;
    }
    if ((err = genl_connect(socket)) != 0) {
        err_msg = "make_network_connections - somehow the netlink socket is already connected";
        goto catch;
    }

    // genl-ctrl-list | cut -f 2 -d ' ' | xargs -I '{}' printf 'get_interfaces_of_type(socket, "{}");\n' | c
    // get_interfaces_of_type(socket, "nlctrl");
    // get_interfaces_of_type(socket, "VFS_DQUOT");
    // get_interfaces_of_type(socket, "dev-energymodel");
    // get_interfaces_of_type(socket, "thermal");
    // get_interfaces_of_type(socket, "dpll");
    // get_interfaces_of_type(socket, "netdev");
    // get_interfaces_of_type(socket, "ethtool");
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
    get_interfaces_of_type(socket, "nl80211");
    // get_interfaces_of_type(socket, "wireguard");

    return NULL;

    struct rtgenmsg rt_hdr = { .rtgen_family = AF_PACKET, };
    if ((nl_send_simple(socket, RTM_GETLINK, NLM_F_REQUEST | NLM_F_DUMP, &rt_hdr, sizeof(rt_hdr))) < 1) {
        perror("make_network_connections - error when listing network interfaces");
        nl_close(socket);
        nl_socket_free(socket);
        exit(EXIT_FAILURE);
    }

    struct network_connection* res = NULL;
    nl_socket_modify_cb(socket, NL_CB_VALID, NL_CB_CUSTOM, network_connections_from_nl_msg, &res);
    nl_recvmsgs_default(socket);
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

catch:
    nl_close(socket);
    nl_socket_free(socket);
catch_no_socket:
    nl_perror(err, err_msg);
    exit(EXIT_FAILURE);
}
