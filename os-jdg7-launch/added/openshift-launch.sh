#!/bin/sh

source ${JBOSS_HOME}/bin/launch/openshift-common.sh
source $JBOSS_HOME/bin/launch/logging.sh

function runServer() {
  local instanceDir=$1
  local count=$2

  export NODE_NAME="${NODE_NAME:-node}-${count}"

  source $JBOSS_HOME/bin/launch/configure.sh

  log_info "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION"

  exec $JBOSS_HOME/bin/standalone.sh -c clustered-openshift.xml -bmanagement 127.0.0.1 -Djboss.server.data.dir="$instanceDir" ${JBOSS_HA_ARGS} ${JAVA_PROXY_OPTIONS}
}

function init_data_dir() {
  DATA_DIR="$1"
  if [ -d "${JBOSS_HOME}/standalone/data" ]; then
    cp -rf ${JBOSS_HOME}/standalone/data/* $DATA_DIR
  fi
}

SPLIT_DATA=${SPLIT_DATA:-$DATAGRID_SPLIT}
SPLIT_LOCK_TIMEOUT=${SPLIT_LOCK_TIMEOUT:-$DATAGRID_LOCK_TIMEOUT}

if [ "${SPLIT_DATA^^}" = "TRUE" ]; then
  source /opt/partition/partitionPV.sh

  DATA_DIR="${JBOSS_HOME}/standalone/partitioned_data"

  partitionPV "${DATA_DIR}" "${SPLIT_LOCK_TIMEOUT:-30}"
else
  source $JBOSS_HOME/bin/launch/configure.sh

  log_info "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION"

  exec $JBOSS_HOME/bin/standalone.sh -c clustered-openshift.xml -bmanagement 127.0.0.1 ${JBOSS_HA_ARGS} ${JAVA_PROXY_OPTIONS}
fi
