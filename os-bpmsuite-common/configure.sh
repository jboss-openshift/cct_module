#!/bin/sh
# Openshift BPM Suite common scripts and helpers
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

# Add common scripts/libraries/snippets
mkdir -p ${JBOSS_HOME}/bin/launch
cp -r ${ADDED_DIR}/launch/* ${JBOSS_HOME}/bin/launch

# Set bin permissions
chown -R jboss:root ${JBOSS_HOME}/bin/
chmod -R g+rwX ${JBOSS_HOME}/bin/

# Ensure that the local Maven repository exists
MVN_DIR=${HOME}/.m2
mkdir -p ${MVN_DIR}/repository
# Necessary to permit running with a randomised UID
chown -R jboss:root ${MVN_DIR}
chmod -R 777 ${MVN_DIR}
