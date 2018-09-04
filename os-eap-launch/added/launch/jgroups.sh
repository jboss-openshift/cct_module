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

  JGROUPS_ENCRYPT_PROTOCOL="${JGROUPS_ENCRYPT_PROTOCOL:=SYM_ENCRYPT}"

  case "${JGROUPS_ENCRYPT_PROTOCOL}" in
    "SYM_ENCRYPT")
      log_info "Configuring JGroups cluster traffic encryption protocol to SYM_ENCRYPT."
      if [ -z "${JGROUPS_CLUSTER_PASSWORD}" ]; then
        log_warning "No password defined for JGroups cluster. AUTH protocol will be disabled. Please define JGROUPS_CLUSTER_PASSWORD."
      fi
      local JGROUPS_UNENCRYPTED_MESSAGE="Detected <STATE> JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted."
      local KEYSTORE_WARNING_MESSAGE=""
      [ -n "${JGROUPS_ENCRYPT_SECRET}"       -a \
        -n "${JGROUPS_ENCRYPT_NAME}"         -a \
        -n "${JGROUPS_ENCRYPT_PASSWORD}"     -a \
        -n "${JGROUPS_ENCRYPT_KEYSTORE_DIR}" -a \
        -n "${JGROUPS_ENCRYPT_KEYSTORE}" ]
      local KEYSTORE_DEFINITION_VALID="$?"
      if [ "${KEYSTORE_DEFINITION_VALID}" -eq "0" ]; then
        # For new JGroups we need to use SYM_ENCRYPT protocol
        jgroups_encrypt="<protocol type=\"SYM_ENCRYPT\">\n\
                        <property name=\"provider\">SunJCE</property>\n\
                        <property name=\"sym_algorithm\">AES</property>\n\
                        <property name=\"encrypt_entire_message\">true</property>\n\
                        <property name=\"keystore_name\">${JGROUPS_ENCRYPT_KEYSTORE_DIR}/${JGROUPS_ENCRYPT_KEYSTORE}</property>\n\
                        <property name=\"store_password\">${JGROUPS_ENCRYPT_PASSWORD}</property>\n\
                        <property name=\"alias\">${JGROUPS_ENCRYPT_NAME}</property>\n\
                    </protocol>"
      elif [ -n "${JGROUPS_ENCRYPT_SECRET}" ]; then
        KEYSTORE_WARNING_MESSAGE="${JGROUPS_UNENCRYPTED_MESSAGE//<STATE>/partial}"
      else
        KEYSTORE_WARNING_MESSAGE="${JGROUPS_UNENCRYPTED_MESSAGE//<STATE>/missing}"
      fi
      if [ -n "${KEYSTORE_WARNING_MESSAGE}" ]; then
        log_warning "${KEYSTORE_WARNING_MESSAGE}"
      fi
      ;;
    "ASYM_ENCRYPT")
      log_info "Configuring JGroups cluster traffic encryption protocol to ASYM_ENCRYPT."
      if [ -n "${JGROUPS_ENCRYPT_SECRET}"       -o \
           -n "${JGROUPS_ENCRYPT_NAME}"         -o \
           -n "${JGROUPS_ENCRYPT_PASSWORD}"     -o \
           -n "${JGROUPS_ENCRYPT_KEYSTORE_DIR}" -o \
           -n "${JGROUPS_ENCRYPT_KEYSTORE}" ] ; then
        log_warning "The specified JGroups SYM_ENCRYPT JCEKS keystore definition will be ignored when using ASYM_ENCRYPT."
      fi
      # CLOUD-2437 AUTH protocol is required when using ASYM_ENCRYPT protocol: https://github.com/belaban/JGroups/blob/master/conf/asym-encrypt.xml#L23
      if [ -z "${JGROUPS_CLUSTER_PASSWORD}" ]; then
        local NL=$'\n'
        log_warning "No password defined for JGroups cluster. AUTH protocol is required when using JGroups ASYM_ENCRYPT cluster traffic encryption protocol. \
                     ${NL}The communication within the cluster WILL NOT be encrypted."
      else
        # Asymmetric encryption using public/private encryption to fetch the shared secret key
        jgroups_encrypt="<protocol type=\"ASYM_ENCRYPT\">\n\
                        <property name=\"encrypt_entire_message\">true</property>\n\
                        <property name=\"sym_keylength\">128</property>\n\
                        <property name=\"sym_algorithm\">AES/ECB/PKCS5Padding</property>\n\
                        <property name=\"asym_keylength\">512</property>\n\
                        <property name=\"asym_algorithm\">RSA</property>\n\
                        <property name=\"change_key_on_leave\">true</property>\n\
                    </protocol>"
      fi
      ;;
  esac

  sed -i "s|<!-- ##JGROUPS_ENCRYPT## -->|$jgroups_encrypt|g" "$CONFIG_FILE"
}
