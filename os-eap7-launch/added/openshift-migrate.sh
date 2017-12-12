#!/bin/sh
# Openshift EAP migration script

RECOVERY_TIMEOUT=${RECOVERY_TIMEOUT:-360}
RECOVERY_PAUSE=${RECOVERY_PAUSE:-10}

function runMigrationServer() {
  exec $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -bmanagement 127.0.0.1 -Djboss.server.data.dir="$1" ${2} ${JAVA_PROXY_OPTIONS} ${JBOSS_HA_ARGS} ${JBOSS_MESSAGING_ARGS}
}

source ${JBOSS_HOME}/bin/launch/openshift-migrate-common.sh
