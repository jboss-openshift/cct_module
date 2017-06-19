#!/bin/bash

source $JBOSS_HOME/bin/launch/launch-common.sh

# Arguments:
# $1 - realm
function add_management_interface_realm() {
    local mgmt_iface_realm="${1}"
    local mgmt_iface_replace_str
    if [ "x${mgmt_iface_realm}" != "x" ]; then
        mgmt_iface_replace_str=" security-realm=\"$mgmt_iface_realm\">"
    else
        mgmt_iface_replace_str=" security-realm=\"ManagementRealm\">"
    fi
    sed -i "s|><!-- ##MGMT_IFACE_REALM## -->|${mgmt_iface_replace_str}|" "$CONFIG_FILE"
}
