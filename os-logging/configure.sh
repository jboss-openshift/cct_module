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

mkdir -p ${BIN_HOME}/bin/launch
cp -r ${ADDED_DIR}/launch/logging.sh ${BIN_HOME}/bin/launch

chown -R jboss:root ${BIN_HOME}/bin/launch/logging.sh
chmod -R g+rwX ${BIN_HOME}/bin/launch/logging.sh
