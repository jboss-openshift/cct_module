#!/bin/sh
# Openshift EAP launch script

source ${JBOSS_HOME}/bin/launch/openshift-common.sh
source $JBOSS_HOME/bin/launch/logging.sh

# TERM signal handler
function clean_shutdown() {
  log_error "*** JBossAS wrapper process ($$) received TERM signal ***"
  $JBOSS_HOME/bin/jboss-cli.sh -c ":shutdown(timeout=60)"
  wait $!
}

# CLOUD-2453 Connect-retry loop to wait for the service to become reachable over network
function wait_for_service() {
  if [ -n "${SERVICE_WAIT_NAME}" ]; then
    local -r retry_period_seconds_default="10"
    local -r connect_retry_message="${SERVICE_WAIT_RETRY_MESSAGE:-"Waiting for the \"${SERVICE_WAIT_NAME}\" service to become available ..."}"
    local service="${SERVICE_WAIT_NAME/-/_}"
    local -r service_host="${service^^}_SERVICE_HOST"
    local -r service_port="${service^^}_SERVICE_PORT"
    if [ -n "${SERVICE_WAIT_RETRY_PERIOD_SECONDS}" ] && [[ ! "${SERVICE_WAIT_RETRY_PERIOD_SECONDS}" =~ '^[0-9]+\.?[0-9]*$' ]]; then
      log_warning "Value of SERVICE_WAIT_RETRY_PERIOD_SECONDS variable can be only arbitrary floating point number. Ignoring \"${SERVICE_WAIT_RETRY_PERIOD_SECONDS}\" setting, defaulting to ${retry_period_seconds_default} seconds."
      unset SERVICE_WAIT_RETRY_PERIOD_SECONDS
    fi
    if [ -z "${!service_host}" -o -z "${!service_port}" ]; then
      log_warning "Unable to determine target host or port of the \"${SERVICE_WAIT_NAME}\" service. The RH-SSO pod will start without waiting for the \"${SERVICE_WAIT_NAME}\" service to become reachable over network. Please make sure you specified correct service name in SERVICE_WAIT_NAME."
    else
      until ( echo > /dev/tcp/"${!service_host}"/"${!service_port}" ) &> /dev/null; do
        if [ -n "${SERVICE_WAIT_INTRO_MESSAGE}" ]; then
          log_warning "${SERVICE_WAIT_INTRO_MESSAGE}"
          unset SERVICE_WAIT_INTRO_MESSAGE
        fi
          log_info "${connect_retry_message}"
          sleep "${SERVICE_WAIT_RETRY_PERIOD_SECONDS:-${retry_period_seconds_default}}s"
      done
    fi
  fi
}

function runServer() {
  local instanceDir=$1
  local count=$2
  export NODE_NAME="${NODE_NAME:-node}-${count}"

  wait_for_service

  source $JBOSS_HOME/bin/launch/configure.sh

  log_info "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION"

  trap "clean_shutdown" TERM

  if [ -n "$SSO_IMPORT_FILE" ] && [ -f $SSO_IMPORT_FILE ]; then
    $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -bmanagement 127.0.0.1 $JBOSS_HA_ARGS -Djboss.server.data.dir="$instanceDir" ${JBOSS_MESSAGING_ARGS} -Dkeycloak.migration.action=import -Dkeycloak.migration.provider=singleFile -Dkeycloak.migration.file=${SSO_IMPORT_FILE} -Dkeycloak.migration.strategy=IGNORE_EXISTING ${JAVA_PROXY_OPTIONS} &
  else
    $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -bmanagement 127.0.0.1 $JBOSS_HA_ARGS -Djboss.server.data.dir="$instanceDir" ${JBOSS_MESSAGING_ARGS} ${JAVA_PROXY_OPTIONS} &
  fi

  PID=$!
  wait $PID 2>/dev/null
  wait $PID 2>/dev/null
}

function init_data_dir() {
  local DATA_DIR="$1"
  if [ -d "${JBOSS_HOME}/standalone/data" ]; then
    cp -rf ${JBOSS_HOME}/standalone/data/* $DATA_DIR
  fi
}

if [ "${SPLIT_DATA^^}" = "TRUE" ]; then
  source /opt/partition/partitionPV.sh

  DATA_DIR="${JBOSS_HOME}/standalone/partitioned_data"

  partitionPV "${DATA_DIR}" "${SPLIT_LOCK_TIMEOUT:-30}"
else
  wait_for_service

  source $JBOSS_HOME/bin/launch/configure.sh

  log_info "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION"

  trap "clean_shutdown" TERM

  if [ -n "$CLI_GRACEFUL_SHUTDOWN" ] ; then
    trap "" TERM
    log_info "Using CLI Graceful Shutdown instead of TERM signal"
  fi

  if [ -n "$SSO_IMPORT_FILE" ] && [ -f $SSO_IMPORT_FILE ]; then
    $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -bmanagement 127.0.0.1 $JBOSS_HA_ARGS ${JBOSS_MESSAGING_ARGS} -Dkeycloak.migration.action=import -Dkeycloak.migration.provider=singleFile -Dkeycloak.migration.file=${SSO_IMPORT_FILE} -Dkeycloak.migration.strategy=IGNORE_EXISTING ${JAVA_PROXY_OPTIONS} &
  else
    $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -bmanagement 127.0.0.1 $JBOSS_HA_ARGS ${JBOSS_MESSAGING_ARGS} ${JAVA_PROXY_OPTIONS} &
  fi

  PID=$!
  wait $PID 2>/dev/null
  wait $PID 2>/dev/null
fi
