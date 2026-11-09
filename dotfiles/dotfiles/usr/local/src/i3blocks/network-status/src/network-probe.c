#include <assert.h>
#include <linux/netlink.h>
#include <netlink/errno.h>
#include <netlink/genl/ctrl.h>
#include <netlink/genl/genl.h>
#include <netlink/handlers.h>
#include <netlink/msg.h>
#include <netlink/netlink.h>
#include <netlink/socket.h>

#include "exception.h"
#include "netlink-medium.h"
#include "netlink-utils.h"

#include "network-probe.h"

/**************************************
 * Netlink helper functions
 *************************************/

static int netlink_msg_completed(struct nl_msg* msg, void* arg) {
    unsigned char* completed = (unsigned char*)arg;
    *completed = 1;
    return NL_OK;
}

static void send_netlink_msg(
    struct nl_sock* socket,
    struct nl_msg* msg,
    nl_recvmsg_msg_cb_t callback,
    void* callback_args
) {
    struct nl_cb* cb = nl_cb_alloc(NL_CB_DEFAULT);
    if (cb == NULL) {
        SET_EXCEPTION(NLE_NOMEM, "error when creating nl_cb");
        return;
    }

    set_exception_err(
        nl_cb_set(cb, NL_CB_VALID, NL_CB_CUSTOM, callback, callback_args)
    );
    if (has_exception()) {
        SET_EXCEPTION_MSG("error when setting callback");
        goto catch;
    }

    enum nl_cb_type completion_cb_type =
        nlmsg_hdr(msg)->nlmsg_flags & NLM_F_DUMP
            ? NL_CB_FINISH
            : NL_CB_ACK;
    unsigned char completed = 0;
    set_exception_err(
        nl_cb_set(cb, completion_cb_type, NL_CB_CUSTOM, netlink_msg_completed,
            &completed)
    );
    if (has_exception()) {
        SET_EXCEPTION_MSG("error when setting completion callback");
        goto catch;
    }

    int sent_bytes = nl_send_auto(socket, msg);
    if (sent_bytes == 0) {
        SET_EXCEPTION(NLE_FAILURE, "error when sending nl_msg: no bytes sent");
        goto catch;
    }
    if (sent_bytes < 1) {
        SET_EXCEPTION_MSG("error when sending nl_msg");
        goto catch;
    }

    do {
        /*
         * Save the error code in a temporary variable, rather than straight
         * into set_exception_err, to avoid overwriting exceptions set by the
         * Netlink callback (called upon message reception by nl_recvmsgs).
         */
        int recv_err = nl_recvmsgs(socket, cb);
        // Check for potential exceptions set by the Netlink callback
        if (has_exception()) {
            goto catch;
        }
        set_exception_err(recv_err);
        if (has_exception()) {
            SET_EXCEPTION_MSG("error when receiving responses");
            goto catch;
        }
    } while (!completed);

catch:
    nl_cb_put(cb);
}

/**************************************
 * network_probe
 *************************************/

network_probe network_probe_new() {
    struct nl_sock* socket = nl_socket_alloc();
    if (socket == NULL) {
        SET_EXCEPTION(NLE_NOMEM, "error when creating netlink socket");
        return NULL;
    }

    set_exception_err(genl_connect(socket));
    if (has_exception()) {
        SET_EXCEPTION_MSG("error when connecting netlink socket");
        nl_socket_free(socket);
        return NULL;
    }

    return socket;
}

void network_probe_close(network_probe this) {
    nl_socket_free(this);
}

uint8_t network_probe_get_medium_status(
    network_probe socket,
    enum network_medium medium
) {
    uint8_t status = INTERFACE_STATUS_INACTIVE;

    const struct netlink_network_medium* netlink_medium = NULL;
    switch (medium) {
        case NETWORK_MEDIUM_CABLE:
            netlink_medium = &netlink_cable;
            break;

        case NETWORK_MEDIUM_WIRELESS:
            netlink_medium = &netlink_wireless;
            break;

        default:
            assert(0);
    }

    int nl_family_id = genl_ctrl_resolve(
        socket,
        netlink_medium->netlink_family_name
    );
    if (nl_family_id < 1) {
        SET_EXCEPTION(nl_family_id, "error when resolving family driver");
        return 0;
    }

    struct nl_msg* msg = create_genl_msg(
        nl_family_id,
        NLM_F_DUMP,
        netlink_medium->get_interfaces_cmd
    );
    if (has_exception()) {
        return 0;
    }

    struct status_msgs_context status_msgs_ctx;
    status_msgs_context_init(&status_msgs_ctx, nl_family_id);
    send_netlink_msg(
        socket,
        msg,
        netlink_medium->append_status_msg,
        (void*) &status_msgs_ctx
    );
    if (has_exception()) {
        goto catch;
    }

    for (
        struct nl_msg_list_node* curr = status_msgs_ctx.msgs;
        curr != NULL;
        curr = curr->next
    ) {
        send_netlink_msg(socket, curr->msg, netlink_medium->aggr_status, &status);
        if (has_exception()) {
            goto catch;
        }
    }

    goto cleanup;

catch:
    status = 0;

cleanup:
    nlmsg_free(msg);
    status_msgs_context_free(&status_msgs_ctx);
    return status;
}
