# only processes a single environment as the placeholder is not preserved

function prepareEnv() {
  unset JGROUPS_ENCRYPT_SECRET
  unset JGROUPS_ENCRYPT_PASSWORD
  unset JGROUPS_ENCRYPT_KEYSTORE_DIR
  unset JGROUPS_ENCRYPT_KEYSTORE
  unset JGROUPS_ENCRYPT_NAME
}

function configure() {
  configure_jgroups_encryption
}

function configureEnv() {
  configure
}

function version_compare() {
  [ "$1" = "`echo -e \"$1\n$2\" | sort -V | head -n1`" ] && echo "older" || echo "newer"
}

function configure_jgroups_encryption() {
  jgroups_encrypt=""

  if [ -n "${JGROUPS_ENCRYPT_SECRET}" ]; then
    if [ -n "${JGROUPS_ENCRYPT_NAME}" -a -n "${JGROUPS_ENCRYPT_PASSWORD}" ] ; then
      jgroups_encrypt="\
        <protocol type=\"SYM_ENCRYPT\">\
          <property name=\"provider\">SunJCE</property>\
          <property name=\"sym_algorithm\">AES</property>\
          <property name=\"encrypt_entire_message\">true</property>\
          <property name=\"keystore_name\">${JGROUPS_ENCRYPT_KEYSTORE_DIR}/${JGROUPS_ENCRYPT_KEYSTORE}</property>\
          <property name=\"store_password\">${JGROUPS_ENCRYPT_PASSWORD}</property>\
          <property name=\"alias\">${JGROUPS_ENCRYPT_NAME}</property>\
        </protocol>"
    else
      echo "WARNING! Partial JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted."
    fi
  fi

  sed -i "s|<!-- ##JGROUPS_ENCRYPT## -->|$jgroups_encrypt|g" "$CONFIG_FILE"
}
