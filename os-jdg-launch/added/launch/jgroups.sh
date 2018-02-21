# only processes a single environment as the placeholder is not preserved

source $JBOSS_HOME/bin/launch/logging.sh

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

function configure_jgroups_encryption() {
  jgroups_encrypt=""

  if [ -n "${JGROUPS_ENCRYPT_SECRET}" ]; then
    if [ -n "${JGROUPS_ENCRYPT_NAME}" -a -n "${JGROUPS_ENCRYPT_PASSWORD}" ] ; then
      jgroups_encrypt="\
        <protocol type=\"ENCRYPT\">\
          <property name=\"key_store_name\">${JGROUPS_ENCRYPT_KEYSTORE_DIR}/${JGROUPS_ENCRYPT_KEYSTORE}</property>\
          <property name=\"store_password\">${JGROUPS_ENCRYPT_PASSWORD}</property>\
          <property name=\"alias\">${JGROUPS_ENCRYPT_NAME}</property>\
        </protocol>"
    else
      log_warning "Partial JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted."
    fi
  fi

  sed -i "s|<!-- ##JGROUPS_ENCRYPT## -->|$jgroups_encrypt|g" "$CONFIG_FILE"
}
