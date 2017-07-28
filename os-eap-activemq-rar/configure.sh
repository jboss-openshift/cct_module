#!/bin/sh
# Add Active-MQ rar
set -e

SOURCES_DIR=/tmp/artifacts

cp -p ${SOURCES_DIR}/activemq-rar-5.11.0.redhat-*.rar ${JBOSS_HOME}/standalone/deployments/activemq-rar.rar

chown jboss:root ${JBOSS_HOME}/standalone/deployments/activemq-rar.rar
chmod g+rwX ${JBOSS_HOME}/standalone/deployments/activemq-rar.rar
