#!/bin/sh
# Openshift EAP launch script

source ${JBOSS_HOME}/bin/launch/openshift-common.sh
source $JBOSS_HOME/bin/launch/logging.sh

# TERM signal handler
function clean_shutdown() {
  log_error "*** JBossAS wrapper process ($$) received TERM signal ***"
  $JBOSS_HOME/bin/jboss-cli.sh -c "shutdown --timeout=60"
  wait $!
}

function runServer() {
  local instanceDir=$1

  source $JBOSS_HOME/bin/launch/configure.sh

  log_info "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION"

  trap "clean_shutdown" TERM
  trap "clean_shutdown" INT

  if [ -n "$CLI_GRACEFUL_SHUTDOWN" ] ; then
    trap "" TERM
    log_info "Using CLI Graceful Shutdown instead of TERM signal"
  fi

  $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -bmanagement 127.0.0.1 -Djboss.server.data.dir="$instanceDir" ${JAVA_PROXY_OPTIONS} ${JBOSS_HA_ARGS} ${JBOSS_MESSAGING_ARGS} &

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
  # SPLIT_DATA defines shared volume for multiple pods mounted at partitioned_data where server saves data 
  #  migration pod is started to supervise the shared volume and cleaning it
  source /opt/partition/partitionPV.sh

  DATA_DIR="${JBOSS_HOME}/standalone/partitioned_data"

  startApplicationServer "${DATA_DIR}" "${SPLIT_LOCK_TIMEOUT:-30}"
elif [ -n "${TX_DATABASE_PREFIX_MAPPING}" ]; then
  # TX_DATABASE_PREFIX_MAPPING defines to save object store data into database
  #  migration pod for to clean in-doubt transactions is started, saving data to the same database
  source /opt/partition/partitionPV.sh

  DATA_DIR="${JBOSS_HOME}/standalone/data"

  startApplicationServer "${DATA_DIR}" "${SPLIT_LOCK_TIMEOUT:-30}"
else
  # no migration pod is run
  source $JBOSS_HOME/bin/launch/configure.sh

  log_info "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION"

  trap "clean_shutdown" TERM
  trap "clean_shutdown" INT

  if [ -n "$CLI_GRACEFUL_SHUTDOWN" ] ; then
    trap "" TERM
    log_info "Using CLI Graceful Shutdown instead of TERM signal"
  fi

  $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -bmanagement 127.0.0.1 ${JAVA_PROXY_OPTIONS} ${JBOSS_HA_ARGS} ${JBOSS_MESSAGING_ARGS} &

  PID=$!
  wait $PID 2>/dev/null
  wait $PID 2>/dev/null
fi
