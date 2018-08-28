# only processes a single environment as the placeholder is not preserved

function prepareEnv() {
  unset HTTPS_NAME
  unset HTTPS_PASSWORD
  unset HTTPS_KEY_PASSWORD
  unset HTTPS_KEYSTORE_DIR
  unset HTTPS_KEYSTORE
  unset HTTPS_KEYSTORE_TYPE
}

function configure() {
  configure_https
  configure_security_domains
}

function configureEnv() {
  configure
}

function configure_https() {
  local ssl="<!-- No SSL configuration discovered -->"
  local https_connector="<!-- No HTTPS configuration discovered -->"

  if [ "${CONFIGURE_ELYTRON_SSL}" != "true" ]; then
    echo "Using PicketBox SSL configuration."
    return 
  fi

  if [ -n "${HTTPS_PASSWORD}" -a -n "${HTTPS_KEYSTORE}" -a -n "${HTTPS_KEYSTORE_TYPE}" ]; then

    if [ -n "${HTTPS_KEY_PASSWORD}" ]; then
      key_password="${HTTPS_KEY_PASSWORD}"
    else
      echo "No HTTPS_KEY_PASSWORD was provided; using HTTPS_PASSWORD for Elytron LocalhostKeyManager."
      key_password="${HTTPS_PASSWORD}"
    fi

    if [ -z "${HTTPS_KEYSTORE_DIR}"  ]; then
      # Documented behavior; HTTPS_KEYSTORE is relative to the config dir
      # Use case is the user puts their keystore in their source's 'configuration' dir and s2i pulls it in
      keystore_path="path=\"${HTTPS_KEYSTORE}\""
      keystore_rel_to="relative-to=\"jboss.server.config.dir\""
    elif [[ "${HTTPS_KEYSTORE_DIR}" =~ ^/ ]]; then
      # Assume leading '/' means the value is a FS path
      # Standard template behavior where the template sets this var to /etc/eap-secret-volume
      keystore_path="path=\"${HTTPS_KEYSTORE_DIR}/${HTTPS_KEYSTORE}\""
      keystore_rel_to=""
    else
      # Compatibility edge case. Treat no leading '/' as meaning HTTPS_KEYSTORE_DIR is the name of a config model path
      keystore_path="path=\"${HTTPS_KEYSTORE}\""
      keystore_rel_to="relative-to=\"${HTTPS_KEYSTORE_DIR}\""
    fi

    tls="<tls>\n\
        <key-stores>\n\
            <key-store name=\"LocalhostKeyStore\">\n\
                <credential-reference clear-text=\"${HTTPS_PASSWORD}\"/>\n\
                <implementation type=\"${HTTPS_KEYSTORE_TYPE}\"/>\n\
                <file $keystore_path $keystore_rel_to/>\n\
            </key-store>\n\
        </key-stores>\n\
        <key-managers>\n\
            <key-manager name=\"LocalhostKeyManager\" key-store=\"LocalhostKeyStore\">\n\
                <credential-reference clear-text=\"$key_password\"/>\n\
            </key-manager>\n\
        </key-managers>\n\
        <server-ssl-contexts>\n\
            <server-ssl-context name=\"LocalhostSslContext\" key-manager=\"LocalhostKeyManager\"/>\n\
        </server-ssl-contexts>\n\
    </tls>"

    https_connector="<https-listener name=\"https\" socket-binding=\"https\" ssl-context=\"LocalhostSslContext\" proxy-address-forwarding=\"true\"/>"
  elif [ -n "${HTTPS_PASSWORD}" -o -n "${HTTPS_KEYSTORE}" -o -n "${HTTPS_KEYSTORE_TYPE}" ]; then
    local missing_msg="WARNING! Partial HTTPS configuration, the https connector WILL NOT be configured. Missing:"
    if [ -z "${HTTPS_PASSWORD}" ]; then
      missing_msg="$missing_msg HTTPS_PASSWORD"
    fi
    if [ -z "${HTTPS_KEYSTORE}" ]; then
      missing_msg="$missing_msg HTTPS_KEYSTORE"
    fi
    if [ -z "${HTTPS_KEYSTORE_TYPE}" ]; then
      missing_msg="$missing_msg HTTPS_KEYSTORE_TYPE"
    fi
    echo $missing_msg
  fi

  sed -i "s|<!-- ##TLS## -->|${tls}|" $CONFIG_FILE
  sed -i "s|<!-- ##HTTPS_CONNECTOR## -->|${https_connector}|" $CONFIG_FILE
}

function configure_security_domains() {
  if [ -n "${SECDOMAIN_NAME}" ]; then
    elytron_integration="<elytron-integration>\n\
                <security-realms>\n\
                    <elytron-realm name=\"${SECDOMAIN_NAME}\" legacy-jaas-config=\"${SECDOMAIN_NAME}\"/>\n\
                </security-realms>\n\
            </elytron-integration>"
    ejb_application_security_domains="<application-security-domains>\n\
                <application-security-domain name=\"${SECDOMAIN_NAME}\" security-domain=\"${SECDOMAIN_NAME}\"/>\n\
            </application-security-domains>"
    http_application_security_domains="<application-security-domains>\n\
                <application-security-domain name=\"${SECDOMAIN_NAME}\" http-authentication-factory=\"${SECDOMAIN_NAME}-http\"/>\n\
            </application-security-domains>"
    http_authentication_factory="<http-authentication-factory name=\"${SECDOMAIN_NAME}-http\" http-server-mechanism-factory=\"global\" security-domain=\"${SECDOMAIN_NAME}\">\n\
                    <mechanism-configuration>\n\
                        <mechanism mechanism-name=\"BASIC\"/>\n\
                        <mechanism mechanism-name=\"FORM\"/>\n\
                    </mechanism-configuration>\n\
                </http-authentication-factory>"
    elytron_security_domain="<security-domain name=\"${SECDOMAIN_NAME}\" default-realm=\"${SECDOMAIN_NAME}\" permission-mapper=\"default-permission-mapper\">\n\
                    <realm name=\"${SECDOMAIN_NAME}\"/>\n\
                </security-domain>"
  fi

  sed -i "s|<!-- ##ELYTRON_INTEGRATION## -->|${elytron_integration}|" $CONFIG_FILE
  sed -i "s|<!-- ##EJB_APPLICATION_SECURITY_DOMAINS## -->|${ejb_application_security_domains}|" $CONFIG_FILE
  sed -i "s|<!-- ##HTTP_APPLICATION_SECURITY_DOMAINS## -->|${http_application_security_domains}|" $CONFIG_FILE
  sed -i "s|<!-- ##HTTP_AUTHENTICATION_FACTORY## -->|${http_authentication_factory}|" $CONFIG_FILE
  sed -i "s|<!-- ##ELYTRON_SECURITY_DOMAIN## -->|${elytron_security_domain}|" $CONFIG_FILE
}
