#!/bin/sh
# Add default Maven settings with Red Hat/JBoss repositories
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added
SOURCES_DIR="/tmp/artifacts"

cp -p ${ADDED_DIR}/standalone-openshift.xml $JBOSS_HOME/standalone/configuration/

cp ${JBOSS_HOME}/dataVirtualization/dataServiceBuilder/vdb-bench-war.war ${JBOSS_HOME}/standalone/deployments/ds-builder.war
cp ${JBOSS_HOME}/dataVirtualization/dataServiceBuilder/vdb-bench-doc.war ${JBOSS_HOME}/standalone/deployments/ds-builder-help.war
cp ${JBOSS_HOME}/dataVirtualization/dataServiceBuilder/komodo-rest.war ${JBOSS_HOME}/standalone/deployments/vdb-builder.war

rm -rf ${JBOSS_HOME}/dataVirtualization

chown -R jboss:root $JBOSS_HOME/standalone
chmod -R g+rwX $JBOSS_HOME/standalone

