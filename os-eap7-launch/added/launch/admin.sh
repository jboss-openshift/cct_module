
function prepareEnv() {
  unset ADMIN_PASSWORD
  unset ADMIN_USERNAME
  unset EAP_ADMIN_PASSWORD
  unset EAP_ADMIN_USERNAME
}

function configure() {
  configure_administration
}

function configureEnv() {
  configure
}

function configure_administration() {
  if [ -n "${ADMIN_USERNAME}" -a -n "$ADMIN_PASSWORD" ]; then
    $JBOSS_HOME/bin/add-user.sh -u "$ADMIN_USERNAME" -p "$ADMIN_PASSWORD"
    if [ "$?" -ne "0" ]; then
        echo "Failed to create the management realm user $ADMIN_USERNAME"
        echo "Exiting..."
        exit
    fi

    local mgmt_iface_replace_str="security-realm=\"ManagementRealm\""
    sed -i "s|><!-- ##MGMT_IFACE_REALM## -->| ${mgmt_iface_replace_str}>|" "$CONFIG_FILE"
  else
    sed -i "s|##MGMT_IFACE_REALM##||" "$CONFIG_FILE"
  fi
}
