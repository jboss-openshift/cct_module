#!/bin/sh
# Add default Maven settings with Red Hat/JBoss repositories
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added
SOURCES_DIR="/tmp/artifacts"

cp -p ${ADDED_DIR}/standalone-openshift.xml $JBOSS_HOME/standalone/configuration/

rm -rf ${JBOSS_HOME}/dataVirtualization

for dir in $JBOSS_HOME/standalone /deployments; do
  chown -R jboss:root $dir
  chmod -R g+rwX $dir
done
