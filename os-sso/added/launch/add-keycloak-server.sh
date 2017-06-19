#!/bin/bash

KEYCLOAK_SERVER_FILE=$JBOSS_HOME/standalone/configuration/keycloak-server.json
LOCAL_SOURCE_DIR=${HOME}/source
KEYCLOAK_CACHE_CONTAINER_FILE=$JBOSS_HOME/bin/launch/keycloak-cache-container.xml
KEYCLOAK_LEGACY_CACHE_CONTAINER_FILE=$JBOSS_HOME/bin/launch/legacy-keycloak-cache-container.xml

function add_truststore() {
  if [ -n "$SSO_TRUSTSTORE" ] && [ -n "$SSO_TRUSTSTORE_DIR" ] && [ -n "$SSO_TRUSTSTORE_PASSWORD" ]; then
    if [ ! -f "${LOCAL_SOURCE_DIR}/configuration/keycloak-server.json" ]; then
      cp -f $JBOSS_HOME/bin/launch/keycloak-server.json $KEYCLOAK_SERVER_FILE
    fi

    sed -i "s|##SSO_TRUSTSTORE##|${SSO_TRUSTSTORE_DIR}/${SSO_TRUSTSTORE}|" "${KEYCLOAK_SERVER_FILE}"
    sed -i "s|##SSO_TRUSTSTORE_PASSWORD##|${SSO_TRUSTSTORE_PASSWORD}|" "${KEYCLOAK_SERVER_FILE}"

  fi
}

function add_cache_container() {
  local cache_container
  if [ -n "$LEGACY_KEYCLOAK_CACHE_CONTAINER" ] && [ "$LEGACY_KEYCLOAK_CACHE_CONTAINER" == "false" ]; then 
    cache_container=$(cat "${KEYCLOAK_CACHE_CONTAINER_FILE}" | sed ':a;N;$!ba;s|\n|\\n|g')
  else
    cache_container=$(cat "${KEYCLOAK_LEGACY_CACHE_CONTAINER_FILE}" | sed ':a;N;$!ba;s|\n|\\n|g')
  fi

  sed -i "s|<!-- ##KEYCLOAK_CACHE_CONTAINER## -->|${cache_container}|" "${CONFIG_FILE}"
}
