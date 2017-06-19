#!/bin/sh
# Openshift EAP launch script and helpers
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

# Add custom launch script and dependent scripts/libraries/snippets
cp ${ADDED_DIR}/openshift-launch.sh ${JBOSS_HOME}/bin/
cp -r ${ADDED_DIR}/launch ${JBOSS_HOME}/bin/

chown -R jboss:root ${JBOSS_HOME}
chmod -R g+rwX ${JBOSS_HOME}

chmod ug+x ${JBOSS_HOME}/bin/openshift-launch.sh
