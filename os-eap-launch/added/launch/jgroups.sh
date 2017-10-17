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

function version_compare() {
  [ "$1" = "`echo -e \"$1\n$2\" | sort -V | head -n1`" ] && echo "older" || echo "newer"
}

function read_product_name() {
  cat $JBOSS_HOME/version.txt | awk -F'- Version' '{ print $1 }' | xargs
}

function read_product_version() {
  cat $JBOSS_HOME/version.txt | awk -F'- Version' '{ print $2 }' | xargs
}

function configure_jgroups_encryption() {
  jgroups_encrypt=""

  if [ -n "${JGROUPS_ENCRYPT_SECRET}" ]; then
    if [ -n "${JGROUPS_ENCRYPT_NAME}" -a -n "${JGROUPS_ENCRYPT_PASSWORD}" ] ; then
      product=`read_product_name`
      version=`read_product_version`

      if [ "$product" == "Red Hat JBoss Enterprise Application Platform" -a "$(version_compare $version '6.4.4.GA')" == "newer" ]; then
        # For new JGroups we need to use SYM_ENCRYPT protocol
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
        # All other products use older JGroups ENCRYPT protocol
        jgroups_encrypt="\
          <protocol type=\"ENCRYPT\">\
            <property name=\"key_store_name\">${JGROUPS_ENCRYPT_KEYSTORE_DIR}/${JGROUPS_ENCRYPT_KEYSTORE}</property>\
            <property name=\"store_password\">${JGROUPS_ENCRYPT_PASSWORD}</property>\
            <property name=\"alias\">${JGROUPS_ENCRYPT_NAME}</property>\
          </protocol>"
      fi
    else
      log_warning "Partial JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted."
    fi
  fi

  sed -i "s|<!-- ##JGROUPS_ENCRYPT## -->|$jgroups_encrypt|g" "$CONFIG_FILE"
}
