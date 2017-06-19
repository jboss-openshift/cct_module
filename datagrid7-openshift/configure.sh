#!/bin/sh
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

cp -r ${ADDED_DIR}/probes $JBOSS_HOME/bin/
cp -p ${ADDED_DIR}/livenessProbe.sh $JBOSS_HOME/bin/livenessProbe.sh
cp -p ${ADDED_DIR}/readinessProbe.sh $JBOSS_HOME/bin/readinessProbe.sh
chmod -R ug+x $JBOSS_HOME/bin/probes/probe/jdg
