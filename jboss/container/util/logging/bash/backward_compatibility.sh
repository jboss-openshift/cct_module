#!/bin/sh
set -e

if [ -n "$AMQ_HOME" ]; then
  BIN_HOME="$AMQ_HOME"
elif [ -n "$JWS_HOME" ]; then
  BIN_HOME="$JWS_HOME"
else
  BIN_HOME="$JBOSS_HOME"
fi

LAUNCH_DIR=${LAUNCH_DIR:-$BIN_HOME/bin/launch}

mkdir -pm 775 ${LAUNCH_DIR}
ln -s /opt/jboss/container/util/logging/logging.sh ${LAUNCH_DIR}/logging.sh

chown -R jboss:root ${LAUNCH_DIR}
chmod -R ug+rwX ${LAUNCH_DIR}

