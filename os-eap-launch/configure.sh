#!/bin/sh
# Openshift EAP launch script and helpers
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

# Add custom launch script and dependent scripts/libraries/snippets
mkdir -p ${JBOSS_HOME}/bin/launch
cp -r ${ADDED_DIR}/launch/* ${JBOSS_HOME}/bin/launch

# users should migrate to $JBOSS_CONTAINER_MAVEN_DEFAULT_MODULE/maven-repos.sh
ln -s /opt/jboss/container/maven/default/maven-repos.sh ${JBOSS_HOME}/bin/launch/maven-repos.sh
chown -h jboss:root ${JBOSS_HOME}/bin/launch/maven-repos.sh
