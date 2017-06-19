#!/bin/sh
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

# Add liveness and readiness probes and helper library
cp -r "$ADDED_DIR"/* $JBOSS_HOME/bin/

chown -R jboss:root $JBOSS_HOME/bin/
chmod -R g+rwX $JBOSS_HOME/bin/

# ensure added scripts are executable
chmod ug+x $JBOSS_HOME/bin/readinessProbe.sh $JBOSS_HOME/bin/livenessProbe.sh
chmod -R ug+x $JBOSS_HOME/bin/probes
