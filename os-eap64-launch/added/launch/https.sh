# only processes a single environment as the placeholder is not preserved

source $JBOSS_HOME/bin/launch/logging.sh

function prepareEnv() {
  unset HTTPS_NAME
  unset HTTPS_PASSWORD
  unset HTTPS_KEYSTORE_DIR
  unset HTTPS_KEYSTORE
  unset HTTPS_KEYSTORE_TYPE
}

function configure() {
  configure_https
}

function configureEnv() {
  configure
}

function configure_https() {
  https="<!-- No HTTPS configuration discovered -->"
  if [ -n "${HTTPS_NAME}" -a -n "${HTTPS_PASSWORD}" -a -n "${HTTPS_KEYSTORE_DIR}" -a -n "${HTTPS_KEYSTORE}" ] ; then

    if [ -n "$HTTPS_KEYSTORE_TYPE" ]; then
      keystore_type="keystore-type=\"${HTTPS_KEYSTORE_TYPE}\""
    fi

    https="<connector name=\"https\" protocol=\"HTTP/1.1\" socket-binding=\"https\" scheme=\"https\" secure=\"true\"> \
                <ssl name=\"${HTTPS_NAME}\" password=\"${HTTPS_PASSWORD}\" certificate-key-file=\"${HTTPS_KEYSTORE_DIR}/${HTTPS_KEYSTORE}\" ${keystore_type}/> \
            </connector>"
  elif [ -n "${HTTPS_NAME}" -o -n "${HTTPS_PASSWORD}" -o -n "${HTTPS_KEYSTORE_DIR}" -o -n "${HTTPS_KEYSTORE}" ] ; then
    log_warning "Partial HTTPS configuration, the https connector WILL NOT be configured."
  fi
  sed -i "s|<!-- ##HTTPS## -->|${https}|" $CONFIG_FILE
}
