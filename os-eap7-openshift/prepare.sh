#!/bin/bash
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added
DEPLOYMENTS_DIR=/deployments

# https://issues.jboss.org/browse/CLOUD-128
if [ ! -d "${DEPLOYMENTS_DIR}" ]; then
  mv $JBOSS_HOME/standalone/deployments $DEPLOYMENTS_DIR
else
  # -T to avoid cping the deployments directory into the existing one
  cp -R -T $JBOSS_HOME/standalone/deployments/ ${DEPLOYMENTS_DIR}
  rm -rf $JBOSS_HOME/standalone/deployments
fi

ln -s /deployments $JBOSS_HOME/standalone/deployments
chown jboss:root $JBOSS_HOME/standalone/deployments

# Necessary to permit running with a randomised UID
for dir in $SCRIPT_DIR ${JBOSS_HOME} ${HOME} $DEPLOYMENTS_DIR; do
    chown -R jboss:root $dir
    chmod -R g+rwX $dir
done
