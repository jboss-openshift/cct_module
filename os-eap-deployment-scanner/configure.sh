#!/bin/sh
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

cp -p "$ADDED_DIR/deploymentScanner.sh" $JBOSS_HOME/bin/launch

chown jboss:root $JBOSS_HOME/bin/launch/deploymentScanner.sh
chmod g+rwX $JBOSS_HOME/bin/launch/deploymentScanner.sh
