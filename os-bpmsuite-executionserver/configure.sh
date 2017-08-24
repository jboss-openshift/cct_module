#!/bin/sh
# Openshift BPM Suite Execution Server launch script and helpers
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added
SOURCES_DIR="/tmp/artifacts"

# Make sure the owner of added files is the 'jboss' user
chown -R jboss:jboss ${SCRIPT_DIR}

# Move the parent EAP S2I assemble script and install child S2I scripts
mv /usr/local/s2i/assemble /usr/local/s2i/assemble_eap
cp -r ${ADDED_DIR}/s2i/* /usr/local/s2i/
# Necessary to permit running with a randomised UID
chown -R jboss:root /usr/local/s2i
chmod ug+x /usr/local/s2i/*

# Add custom launch script and dependent scripts/libraries/snippets
cp -p ${ADDED_DIR}/openshift-launch.sh ${JBOSS_HOME}/bin/
mkdir -p ${JBOSS_HOME}/bin/launch
cp -r ${ADDED_DIR}/launch/* ${JBOSS_HOME}/bin/launch
cp -r ${SOURCES_DIR}/slf4j-*.jar ${JBOSS_HOME}/bin/launch
chmod ug+x ${JBOSS_HOME}/bin/openshift-launch.sh

# Set bin permissions
chown -R jboss:root ${JBOSS_HOME}/bin/
chmod -R g+rwX ${JBOSS_HOME}/bin/

# Ensure that the local KIE repository exists
KIE_DIR=${HOME}/.kie
mkdir -p ${KIE_DIR}/repository
# Necessary to permit running with a randomised UID
chown -R jboss:root ${KIE_DIR}
chmod -R 777 ${KIE_DIR}

# Necessary to permit running with a randomised UID
for dir in /deployments $JBOSS_HOME $HOME; do
    chown -R jboss:root $dir
    chmod -R g+rwX $dir
done
