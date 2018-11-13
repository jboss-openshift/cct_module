#!/bin/bash
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added
SOURCES_DIR=/tmp/artifacts
VERSION="1.0.3.Final-redhat-1"
VERSION_TXN_MARKER="1.1.2.Final-redhat-00001"

# Add new "openshift" layer
# includes module definitions for OpenShift PING and OAuth
# (also includes overridden JGroups, AS Clustering Common/JGroups, and EE for OpenShift PING)
# Remove any existing destination files first (which might be symlinks)
cp -rp --remove-destination "$ADDED_DIR/modules" "$JBOSS_HOME/"

# Copy custom valves
cp -p "${SOURCES_DIR}/tomcat-7-valves-$VERSION.jar" "$JBOSS_HOME/modules/system/layers/openshift/org/jboss/openshift/main/tomcat-7-valves.jar"
cp -p "${SOURCES_DIR}/txn-recovery-marker-jdbc-common-${VERSION_TXN_MARKER}.jar" "$JBOSS_HOME/modules/system/layers/openshift/io/narayana/openshift-recovery/main/txn-recovery-marker-jdbc-common.jar"
cp -p "${SOURCES_DIR}/txn-recovery-marker-jdbc-hibernate4-${VERSION_TXN_MARKER}.jar" "$JBOSS_HOME/modules/system/layers/openshift/io/narayana/openshift-recovery/main/txn-recovery-marker-jdbc-hibernate4.jar"
