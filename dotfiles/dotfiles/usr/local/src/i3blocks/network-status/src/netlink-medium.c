#include <linux/ethtool_netlink.h>
#include <linux/genetlink.h>
#include <linux/nl80211.h>
#include <netlink/attr.h>
#include <netlink/errno.h>
#include <netlink/genl/genl.h>
#include <netlink/handlers.h>
#include <netlink/msg.h>
#include <netlink/netlink.h>
#include <stdint.h>

#ifdef DEBUG
#include <stdio.h>
#endif

#include "exception.h"
#include "netlink-utils.h"

#include "netlink-medium.h"

/**************************************
 * netlink_attrs
 *************************************/

struct netlink_attrs {
    struct nlattr* attrs;
    int len;
};

static struct netlink_attrs netlink_attrs_new(struct nl_msg* msg) {
    struct genlmsghdr* msg_header = nlmsg_data(nlmsg_hdr(msg));
    return (struct netlink_attrs) {
        .attrs = genlmsg_attrdata(msg_header, 0),
        .len = genlmsg_attrlen(msg_header, 0),
    };
}

static struct netlink_attrs netlink_attrs_find_nested_attr(
    const struct netlink_attrs* this,
    int attr_type
) {
    struct nlattr* attr = nla_find(this -> attrs, this -> len, attr_type);
    if (attr == NULL) {
        set_exception_err(NLE_MISSING_ATTR);
        return (struct netlink_attrs) {};
    }
    if (!nla_is_nested(attr)) {
        set_exception_err(NLE_FAILURE);
        return (struct netlink_attrs) {};
    }

    return (struct netlink_attrs) {
        .attrs = (struct nlattr*) nla_data(attr),
        .len = nla_len(attr),
    };
}

#ifdef DEBUG
static const char* netlink_attrs_find_string_attr(
    const struct netlink_attrs* this,
    int attr_type
) {
    struct nlattr* attr = nla_find(this -> attrs, this -> len, attr_type);
    if (attr == NULL) {
        set_exception_err(NLE_MISSING_ATTR);
        return NULL;
    }
    return nla_get_string(attr);
}
#endif

static uint8_t netlink_attrs_find_u8_attr(
    const struct netlink_attrs* this,
    int attr_type
) {
    struct nlattr* attr = nla_find(this -> attrs, this -> len, attr_type);
    if (attr == NULL) {
        set_exception_err(NLE_MISSING_ATTR);
        return 0;
    }
    return nla_get_u8(attr);
}

static uint32_t netlink_attrs_find_u32_attr(
    const struct netlink_attrs* this,
    int attr_type
) {
    struct nlattr* attr = nla_find(this -> attrs, this -> len, attr_type);
    if (attr == NULL) {
        set_exception_err(NLE_MISSING_ATTR);
        return 0;
    }
    return nla_get_u32(attr);
}

/**************************************
 * Cable interfaces
 *************************************/

static int append_cable_status_msg(struct nl_msg* msg, void* arg) {
    struct netlink_attrs attrs = netlink_attrs_new(msg);

    struct netlink_attrs header_attr = netlink_attrs_find_nested_attr(
        &attrs,
        ETHTOOL_A_LINKMODES_HEADER
    );
    if (has_exception()) {
        SET_EXCEPTION_MSG(
            get_exception_err() == NLE_MISSING_ATTR
                ? "ethtool nl_msg has no header attribute"
                : "ethtool nl_msg header attribute is not nested"
        );
        return NL_STOP;
    }

    uint32_t index = netlink_attrs_find_u32_attr(
        &header_attr,
        ETHTOOL_A_HEADER_DEV_INDEX
    );
    if (has_exception()) {
        SET_EXCEPTION_MSG("ethtool header has no device index attribute");
        return NL_STOP;
    }

    #ifdef DEBUG
    const char* name = netlink_attrs_find_string_attr(
        &header_attr,
        ETHTOOL_A_HEADER_DEV_NAME
    );
    if (has_exception()) {
        SET_EXCEPTION_MSG("ethtool header has no device name attribute");
        return NL_STOP;
    }
    printf("Detected cable interface: %s (#%d)\n", name, index);
    #endif

    struct status_msgs_context* ctx = (struct status_msgs_context*)arg;
    struct nl_msg* status_msg = create_genl_msg(
        ctx->netlink_family_id,
        NLM_F_REQUEST,
        ETHTOOL_MSG_LINKSTATE_GET
    );
    if (has_exception()) {
        return NL_STOP;
    }

    struct nlattr* header = nla_nest_start(
        status_msg,
        ETHTOOL_A_LINKSTATE_HEADER
    );
    if (header == NULL) {
        SET_EXCEPTION(NLE_NOMEM, "error when creating nested header nl_attr");
        goto catch;
    }

    set_exception_err(
        nla_put_u32(status_msg, ETHTOOL_A_HEADER_DEV_INDEX, index)
    );
    if (has_exception()) {
        SET_EXCEPTION_MSG("error when setting interface index");
        goto catch;
    }

    nla_nest_end(status_msg, header);

    status_msgs_context_add_msg(ctx, status_msg);
    if (has_exception()) {
        goto catch;
    }

    return NL_OK;

catch:
    nlmsg_free(status_msg);
    return NL_STOP;
}

#define CABLE_UP_STATUS (100)

static int aggr_cable_status(struct nl_msg* msg, void* arg) {
    struct netlink_attrs attrs = netlink_attrs_new(msg);
    uint8_t is_interface_up = netlink_attrs_find_u8_attr(
        &attrs,
        ETHTOOL_A_LINKSTATE_LINK
    );
    if (has_exception()) {
        SET_EXCEPTION_MSG("ethtool nl_msg has no link attribute");
        return NL_STOP;
    }

    #ifdef DEBUG
    struct netlink_attrs header_attr = netlink_attrs_find_nested_attr(
        &attrs,
        ETHTOOL_A_LINKMODES_HEADER
    );
    if (has_exception()) {
        SET_EXCEPTION_MSG(
            get_exception_err() == NLE_MISSING_ATTR
                ? "ethtool nl_msg has no header attribute"
                : "ethtool nl_msg header attribute is not nested"
        );
        return NL_STOP;
    }

    const char* name = netlink_attrs_find_string_attr(
        &header_attr,
        ETHTOOL_A_HEADER_DEV_NAME
    );
    if (has_exception()) {
        SET_EXCEPTION_MSG("ethtool header has no device name attribute");
        return NL_STOP;
    }
    printf("Cable interface %s is up: %d\n", name, is_interface_up);
    #endif

    uint8_t* target = (uint8_t*)arg;
    /*
     * TODO: reword
     * Since we're only tracking whether the interface is up, rather than
     * actual connection speed, we map up -> 100 and down -> 0.
     * Hence the only thing that makes sense is whether at least one interface
     * is up.
     * This is equivalent to *target ||= is_interface_up;
     */
    if (is_interface_up) {
        *target = CABLE_UP_STATUS;
    }

    return NL_OK;
}

const struct netlink_network_medium netlink_cable = {
    .netlink_family_name = ETHTOOL_GENL_NAME,
    .get_interfaces_cmd = ETHTOOL_MSG_LINKMODES_GET,
    .append_status_msg = append_cable_status_msg,
    .aggr_status = aggr_cable_status
};

/**************************************
 * Wireless interfaces
 *************************************/

static int append_wireless_status_msg(struct nl_msg* msg, void* arg) {
    struct netlink_attrs attrs = netlink_attrs_new(msg);

    uint32_t type = netlink_attrs_find_u32_attr(&attrs, NL80211_ATTR_IFTYPE);
    if (has_exception()) {
        SET_EXCEPTION_MSG("nl80211 nl_msg has no interface type attribute");
        return NL_STOP;
    }
    if (type != NL80211_IFTYPE_STATION) {
        return NL_SKIP;
    }

    uint32_t index = netlink_attrs_find_u32_attr(&attrs, NL80211_ATTR_IFINDEX);
    if (has_exception()) {
        SET_EXCEPTION_MSG("nl80211 nl_msg has no interface index attribute");
        return NL_STOP;
    }

    #ifdef DEBUG
    const char* name = netlink_attrs_find_string_attr(
        &attrs,
        NL80211_ATTR_IFNAME
    );
    if (has_exception()) {
        SET_EXCEPTION_MSG("nl80211 nl_msg has no interface name attribute");
        return NL_STOP;
    }
    printf("Detected wireless interface: %s (#%d)\n", name, index);
    #endif

    struct status_msgs_context* ctx = (struct status_msgs_context*)arg;
    struct nl_msg* status_msg = create_genl_msg(
        ctx->netlink_family_id,
        NLM_F_DUMP,
        NL80211_CMD_GET_STATION
    );
    if (has_exception()) {
        return NL_STOP;
    }

    set_exception_err(nla_put_u32(status_msg, NL80211_ATTR_IFINDEX, index));
    if (has_exception()) {
        SET_EXCEPTION_MSG("error while setting interface name");
        goto catch;
    }

    status_msgs_context_add_msg(ctx, status_msg);
    if (has_exception()) {
        goto catch;
    }

    return NL_OK;

catch:
    nlmsg_free(status_msg);
    return NL_STOP;
}

static int aggr_wireless_status(struct nl_msg* msg, void* arg) {
    struct netlink_attrs attrs = netlink_attrs_new(msg);
    struct netlink_attrs sta_info_attrs = netlink_attrs_find_nested_attr(
        &attrs, NL80211_ATTR_STA_INFO);
    if (has_exception()) {
        SET_EXCEPTION_MSG(
            get_exception_err() == NLE_MISSING_ATTR
                ? "nl80211 nl_msg has no sta-info attribute"
                : "nl80211 nl_msg sta-info attribute is not nested"
        );
        return NL_STOP;
    }

    int8_t signal_dbm = (int8_t) netlink_attrs_find_u8_attr(
        &sta_info_attrs, NL80211_STA_INFO_SIGNAL);
    if (has_exception()) {
        SET_EXCEPTION_MSG("nl80211 sta-info has no signal attribute");
        return NL_STOP;
    }

    #ifdef DEBUG
    uint32_t index = netlink_attrs_find_u32_attr(&attrs, NL80211_ATTR_IFINDEX);
    if (has_exception()) {
        SET_EXCEPTION_MSG("nl80211 nl_msg has no interface index attribute");
        return NL_STOP;
    }
    printf("Wireless interface #%d has dBm: %d\n", index, signal_dbm);
    #endif

    // TODO: smarter conversion
    uint8_t signal_strength = 100 + signal_dbm;
    uint8_t* target = (uint8_t*)arg;
    /*
     * I honestly don't know what makes sense as aggregation of Wi-Fi signal
     * strength from multiple interfaces. Since I only usually have one
     * available anyway, I probably will never know.
     * For the time being, the strongest signal is good enough.
     */
    if (*target < signal_strength) {
        *target = signal_strength;
    }

    return NL_OK;
}

const struct netlink_network_medium netlink_wireless = {
    .netlink_family_name = NL80211_GENL_NAME,
    .get_interfaces_cmd = NL80211_CMD_GET_INTERFACE,
    .append_status_msg = append_wireless_status_msg,
    .aggr_status = aggr_wireless_status
};
