#!/bin/bash

function prepareEnv() {
  unset SSO_TRUSTSTORE
  unset SSO_TRUSTSTORE_DIR
  unset SSO_TRUSTSTORE_PASSWORD
}

function configure() {
  add_truststore
}

function add_truststore() {
  
  if [ -n "$SSO_TRUSTSTORE" ] && [ -n "$SSO_TRUSTSTORE_DIR" ] && [ -n "$SSO_TRUSTSTORE_PASSWORD" ]; then

    local truststore="<spi name=\"truststore\"><provider name=\"file\" enabled=\"true\"><properties><property name=\"file\" value=\"${SSO_TRUSTSTORE_DIR}/${SSO_TRUSTSTORE}\"/><property name=\"password\" value=\"${SSO_TRUSTSTORE_PASSWORD}\"/><property name=\"hostname-verification-policy\" value=\"WILDCARD\"/><property name=\"disabled\" value=\"false\"/></properties></provider></spi>"

    sed -i "s|<!-- ##SSO_TRUSTSTORE## -->|${truststore}|" "${CONFIG_FILE}"

  fi
}

