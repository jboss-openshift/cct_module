#!/bin/bash

# Import logging module
source $JBOSS_HOME/bin/launch/logging.sh

function prepareEnv() {
  unset X509_CA_BUNDLE
}

function configure() {
  autogenerate_keystores
}

function autogenerate_keystores() {
  # Keystore infix notation as used in templates to keystore name mapping
  declare -A KEYSTORES=( ["https"]="HTTPS" ["jgroups"]="JGroups" )

  local KEYSTORES_STORAGE="${JBOSS_HOME}/keystores"
  if [ ! -d "${KEYSTORES_STORAGE}" ]; then
    mkdir -p "${KEYSTORES_STORAGE}"
  fi

  # Auto-generate the HTTPS and JGroups keystores if volumes for OpenShift's
  # serving x509 certificate secrets service were properly mounted
  for KEYSTORE_TYPE in "${!KEYSTORES[@]}"; do

    local X509_KEYSTORE_DIR="/etc/x509/${KEYSTORE_TYPE}"
    local X509_CRT="tls.crt"
    local X509_KEY="tls.key"
    local NAME="rh-sso-${KEYSTORE_TYPE}-key"
    local PASSWORD=$(openssl rand -base64 32)
    local JKS_KEYSTORE_FILE="${KEYSTORE_TYPE}-keystore.jks"
    local PKCS12_KEYSTORE_FILE="${KEYSTORE_TYPE}-keystore.pk12"

    if [ -d "${X509_KEYSTORE_DIR}" ]; then

      log_info "Creating ${KEYSTORES[$KEYSTORE_TYPE]} keystore via OpenShift's service serving x509 certificate secrets.."

      openssl pkcs12 -export \
      -name "${NAME}" \
      -inkey "${X509_KEYSTORE_DIR}/${X509_KEY}" \
      -in "${X509_KEYSTORE_DIR}/${X509_CRT}" \
      -out "${KEYSTORES_STORAGE}/${PKCS12_KEYSTORE_FILE}" \
      -password pass:"${PASSWORD}" >& /dev/null

      keytool -importkeystore -noprompt \
      -srcalias "${NAME}" -destalias "${NAME}" \
      -srckeystore "${KEYSTORES_STORAGE}/${PKCS12_KEYSTORE_FILE}" \
      -srcstoretype pkcs12 \
      -destkeystore "${KEYSTORES_STORAGE}/${JKS_KEYSTORE_FILE}" \
      -storepass "${PASSWORD}" -srcstorepass "${PASSWORD}" >& /dev/null

      if [ -f "${KEYSTORES_STORAGE}/${JKS_KEYSTORE_FILE}" ]; then
        log_info "${KEYSTORES[$KEYSTORE_TYPE]} keystore successfully created at: ${KEYSTORES_STORAGE}/${JKS_KEYSTORE_FILE}"
      fi

      # Propagate values of NAME, PASSWORD, KEYSTORES_STORAGE, and JKS_KEYSTORE_FILE variables
      # to appropriate variables used by subsequent modules depending on KEYSTORE_TYPE
      # (IOW either set HTTPS_ or JGROUPS_ENCRYPT_ variables)
      [ "${KEYSTORE_TYPE}" == "https" ] && HTTPS_NAME="${NAME}" || JGROUPS_ENCRYPT_NAME="${NAME}"
      [ "${KEYSTORE_TYPE}" == "https" ] && HTTPS_PASSWORD="${PASSWORD}" || JGROUPS_ENCRYPT_PASSWORD="${PASSWORD}"
      [ "${KEYSTORE_TYPE}" == "https" ] && HTTPS_KEYSTORE_DIR="${KEYSTORES_STORAGE}" || JGROUPS_ENCRYPT_KEYSTORE_DIR="${KEYSTORES_STORAGE}"
      [ "${KEYSTORE_TYPE}" == "https" ] && HTTPS_KEYSTORE="${JKS_KEYSTORE_FILE}" || JGROUPS_ENCRYPT_KEYSTORE="${JKS_KEYSTORE_FILE}"

    fi

  done

  # Auto-generate the RH-SSO truststore if X509_CA_BUNDLE was provided
  local -r X509_CRT_DELIMITER="/-----BEGIN CERTIFICATE-----/"
  local JKS_TRUSTSTORE_FILE="truststore.jks"
  local JKS_TRUSTSTORE_PATH="${KEYSTORES_STORAGE}/${JKS_TRUSTSTORE_FILE}"
  local PASSWORD=$(openssl rand -base64 32)
  if [ -n "${X509_CA_BUNDLE}" ]; then
    log_info "Creating RH-SSO truststore.."
    csplit -s -z -f crt- "${X509_CA_BUNDLE}" "${X509_CRT_DELIMITER}" '{*}'
    for CERT_FILE in crt-*; do
      keytool -import -noprompt -keystore "${JKS_TRUSTSTORE_PATH}" -file "${CERT_FILE}" \
      -storepass "${PASSWORD}" -alias "service-${CERT_FILE}" >& /dev/null
    done

    if [ -f "${JKS_TRUSTSTORE_PATH}" ]; then
      log_info "RH-SSO truststore successfully created at: ${JKS_TRUSTSTORE_PATH}"
    fi

    # Import existing system CA certificates into the newly generated truststore
    local SYSTEM_CACERTS=$(readlink -e $(dirname $(readlink -e $(which keytool)))"/../lib/security/cacerts")
    if keytool -v -list -keystore "${SYSTEM_CACERTS}" -storepass "changeit" > /dev/null; then
      log_info "Importing certificates from system's Java CA certificate bundle into RH-SSO truststore.."
      keytool -importkeystore -noprompt \
      -srckeystore "${SYSTEM_CACERTS}" \
      -destkeystore "${JKS_TRUSTSTORE_PATH}" \
      -srcstoretype jks -deststoretype jks \
      -storepass "${PASSWORD}" -srcstorepass "changeit" >& /dev/null
      if [ "$?" -eq "0" ]; then
        log_info "Successfully imported certificates from system's Java CA certificate bundle into RH-SSO truststore at: ${JKS_TRUSTSTORE_PATH}"
      else
        log_error "Failed to import certificates from system's Java CA certificate bundle into RH-SSO truststore!"
      fi
    fi

    # Propagate the trustore related variables to subsequent modules
    SSO_TRUSTSTORE_PASSWORD="${PASSWORD}"
    SSO_TRUSTSTORE_DIR="${KEYSTORES_STORAGE}"
    SSO_TRUSTSTORE="${JKS_TRUSTSTORE_FILE}"
  fi
}
