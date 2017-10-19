#!/bin/sh

source $JBOSS_HOME/bin/launch/logging.sh

if [ "${SCRIPT_DEBUG}" = "true" ] ; then
    set -x
    log_info "Script debugging is enabled, allowing bash commands and their arguments to be printed as they are executed"
fi

CONFIG_FILE=$JBOSS_HOME/standalone/configuration/clustered-openshift.xml
LOGGING_FILE=$JBOSS_HOME/standalone/configuration/logging.properties

CONFIGURE_SCRIPTS=(
  $JBOSS_HOME/bin/launch/backward-compatibility.sh
  $JBOSS_HOME/bin/launch/configure_extensions.sh
  $JBOSS_HOME/bin/launch/passwd.sh
  $JBOSS_HOME/bin/launch/authentication-config.sh
  $JBOSS_HOME/bin/launch/datasource.sh
  $JBOSS_HOME/bin/launch/admin.sh
  $JBOSS_HOME/bin/launch/ha.sh
  $JBOSS_HOME/bin/launch/jgroups.sh
  $JBOSS_HOME/bin/launch/https.sh
  $JBOSS_HOME/bin/launch/json_logging.sh
  $JBOSS_HOME/bin/launch/security-domains.sh
  $JBOSS_HOME/bin/launch/infinispan-config.sh
  $JBOSS_HOME/bin/launch/management-realm.sh
  $JBOSS_HOME/bin/launch/access_log_valve.sh
  /opt/run-java/proxy-options
)

function runServer() {
  local instanceDir=$1

  log_info "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION"

  exec $JBOSS_HOME/bin/standalone.sh -c clustered-openshift.xml -bmanagement 127.0.0.1 -Djboss.server.data.dir="$instanceDir" ${JBOSS_HA_ARGS} ${JAVA_PROXY_OPTIONS}
}

function init_data_dir() {
  DATA_DIR="$1"
  if [ -d "${JBOSS_HOME}/standalone/data" ]; then
    cp -rf ${JBOSS_HOME}/standalone/data/* $DATA_DIR
  fi
}

source $JBOSS_HOME/bin/launch/configure.sh

if [ "${DATAGRID_SPLIT^^}" = "TRUE" ]; then
  source /opt/partition/partitionPV.sh

  DATA_DIR="${JBOSS_HOME}/standalone/partitioned_data"

  partitionPV "${DATA_DIR}" "${DATAGRID_LOCK_TIMEOUT:-30}"
else
  log_info "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION"

  exec $JBOSS_HOME/bin/standalone.sh -c clustered-openshift.xml -bmanagement 127.0.0.1 ${JBOSS_HA_ARGS} ${JAVA_PROXY_OPTIONS}
fi
