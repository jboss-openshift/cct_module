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

  if [ -n "${HTTPS_PASSWORD}" -a -n "${HTTPS_KEYSTORE_DIR}" -a -n "${HTTPS_KEYSTORE}" -a -n "${HTTPS_KEYSTORE_TYPE}" ]; then

    if [ -n "${HTTPS_KEY_PASSWORD}" ]; then
      key_password="<credential-reference clear-text=\"${HTTPS_KEY_PASSWORD}\"/>"
    fi

    tls="<tls>\n\
        <key-stores>\n\
            <key-store name=\"LocalhostKeyStore\">\n\
                <credential-reference clear-text=\"${HTTPS_PASSWORD}\"/>\n\
                <implementation type=\"${HTTPS_KEYSTORE_TYPE}\"/>\n\
                <file path=\"${HTTPS_KEYSTORE}\" relative-to=\"${HTTPS_KEYSTORE_DIR}\"/>\n\
            </key-store>\n\
        </key-stores>\n\
        <key-managers>\n\
            <key-manager name=\"LocalhostKeyManager\" key-store=\"LocalhostKeyStore\">\n\
                $key_password\n\
            </key-manager>\n\
        </key-managers>\n\
        <server-ssl-contexts>\n\
            <server-ssl-context name=\"LocalhostSslContext\" key-manager=\"LocalhostKeyManager\"/>\n\
        </server-ssl-contexts>\n\
    </tls>"

    https_connector="<https-listener name=\"https\" socket-binding=\"https\" ssl-context=\"LocalhostSslContext\"/>"
  elif [ -n "${HTTPS_PASSWORD}" -o -n "${HTTPS_KEYSTORE_DIR}" -o -n "${HTTPS_KEYSTORE}" -o -n "${HTTPS_KEYSTORE_TYPE}" ]; then
    echo "WARNING! Partial HTTPS configuration, the https connector WILL NOT be configured."
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
    application_security_domains="<application-security-domains>\n\
                <application-security-domain name=\"${SECDOMAIN_NAME}\" http-authentication-factory=\"${SECDOMAIN_NAME}-http\"/>\n\
            </application-security-domains>"
    http_authentication_factory="<http-authentication-factory name=\"${SECDOMAIN_NAME}-http\" http-server-mechanism-factory=\"global\" security-domain=\"${SECDOMAIN_NAME}\">\n\
                    <mechanism-configuration>\n\
                        <mechanism mechanism-name=\"FORM\"/>\n\
                    </mechanism-configuration>\n\
                </http-authentication-factory>"
    elytron_security_domain="<security-domain name=\"${SECDOMAIN_NAME}\" default-realm=\"${SECDOMAIN_NAME}\" permission-mapper=\"default-permission-mapper\">\n\
                    <realm name=\"${SECDOMAIN_NAME}\"/>\n\
                </security-domain>"
  fi

  sed -i "s|<!-- ##ELYTRON_INTEGRATION## -->|${elytron_integration}|" $CONFIG_FILE
  sed -i "s|<!-- ##APPLICATION_SECURITY_DOMAINS## -->|${application_security_domains}|" $CONFIG_FILE
  sed -i "s|<!-- ##HTTP_AUTHENTICATION_FACTORY## -->|${http_authentication_factory}|" $CONFIG_FILE
  sed -i "s|<!-- ##ELYTRON_SECURITY_DOMAIN## -->|${elytron_security_domain}|" $CONFIG_FILE
}
