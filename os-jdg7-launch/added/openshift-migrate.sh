#!/bin/sh
# Openshift JDG migration script

RECOVERY_TIMEOUT=${RECOVERY_TIMEOUT:-360}
RECOVERY_PAUSE=${RECOVERY_PAUSE:-10}

function runMigrationServer() {
  exec $JBOSS_HOME/bin/standalone.sh -c clustered-openshift.xml -bmanagement 127.0.0.1 -Djboss.server.data.dir="$1" ${2} ${JBOSS_HA_ARGS} ${JAVA_PROXY_OPTIONS}
}

export STANDALONE_XML_FILE=clustered-openshift.xml

source ${JBOSS_HOME}/bin/launch/openshift-migrate-common.sh
