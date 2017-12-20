#!/bin/sh
# Openshift BPM Suite Business Central launch script and helpers
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

# Add custom launch script and dependent scripts/libraries/snippets
cp -p ${ADDED_DIR}/openshift-launch.sh ${JBOSS_HOME}/bin/
mkdir -p ${JBOSS_HOME}/bin/launch
cp -r ${ADDED_DIR}/launch/* ${JBOSS_HOME}/bin/launch
chmod ug+x ${JBOSS_HOME}/bin/openshift-launch.sh

# Set bin permissions
chown -R jboss:root ${JBOSS_HOME}/bin/
chmod -R g+rwX ${JBOSS_HOME}/bin/

# Ensure that the local data directory exists
DATA_DIR=${JBOSS_HOME}/standalone/data
mkdir -p ${DATA_DIR}/bpmsuite
# Necessary to permit running with a randomised UID
chown -R jboss:root ${DATA_DIR}
chmod -R 777 ${DATA_DIR}
