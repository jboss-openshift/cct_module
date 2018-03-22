#!/bin/sh
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

if [ -n "$AMQ_HOME" ]; then
  BIN_HOME="$AMQ_HOME"
elif [ -n "$JWS_HOME" ]; then
  BIN_HOME="$JWS_HOME"
else
  BIN_HOME="$JBOSS_HOME"
fi

LAUNCH_DIR=${LAUNCH_DIR:-$BIN_HOME/bin/launch}

mkdir -p ${LAUNCH_DIR}
cp -r ${ADDED_DIR}/launch/logging.sh ${LAUNCH_DIR}

chown -R jboss:root ${LAUNCH_DIR}/logging.sh
chmod -R g+rwX ${LAUNCH_DIR}/logging.sh
