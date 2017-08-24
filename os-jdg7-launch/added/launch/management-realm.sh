#!/bin/bash

function prepareEnv() {
  unset MGMT_IFACE_REALM
}

function configure() {
  add_management_interface_realm
}

function add_management_interface_realm() {
  if [ -n "$MGMT_IFACE_REALM" ]; then
    local mgmt_iface_replace_str="security-realm=\"$MGMT_IFACE_REALM\" "

    sed -i "s|><!-- ##MGMT_IFACE_REALM## -->| ${mgmt_iface_replace_str}>|" "$CONFIG_FILE"

    sed -i "s|<http-interface http-upgrade-enabled=\"true\" console-enabled=\"false\" security-realm=\"ManagementRealm\">|<http-interface http-upgrade-enabled=\"true\" console-enabled=\"false\" ${mgmt_iface_replace_str}>|" "$CONFIG_FILE"
  fi    
}
