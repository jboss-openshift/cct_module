#!/bin/bash
# Add custom launch script and helpers
# NOTE: this overrides the openshift-launch.sh script in os-eap64-launch
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

cp -p ${ADDED_DIR}/openshift-launch.sh ${ADDED_DIR}/openshift-migrate.sh $JBOSS_HOME/bin/

# Add infinispan config script
cp -p ${ADDED_DIR}/launch/infinispan-config.sh $JBOSS_HOME/bin/launch

# Add authentication config script
cp -p ${ADDED_DIR}/launch/authentication-config.sh $JBOSS_HOME/bin/launch

# Add backward compatiblity config script
cp -p ${ADDED_DIR}/launch/backward-compatibility.sh $JBOSS_HOME/bin/launch

# Add common start script
cp -p ${ADDED_DIR}/launch/openshift-common.sh $JBOSS_HOME/bin/launch

cp ${ADDED_DIR}/launch/management-realm.sh $JBOSS_HOME/bin/launch
cp ${ADDED_DIR}/launch/cache-container.xml $JBOSS_HOME/bin/launch
