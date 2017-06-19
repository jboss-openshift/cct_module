#!/bin/sh
# Launch script and related configuration
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

cp -p ${ADDED_DIR}/launch.sh ${ADDED_DIR}/configure.sh ${ADDED_DIR}/readinessProbe.sh ${ADDED_DIR}/partitionPV.sh $AMQ_HOME/bin/
cp -p ${ADDED_DIR}/openshift-activemq.xml ${ADDED_DIR}/openshift-login.config ${ADDED_DIR}/openshift-users.properties $AMQ_HOME/conf/
