#!/bin/sh
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added
SOURCES_DIR="/tmp/artifacts"

# for backward compatibility.  jolokia is now located in /opt/jolokia.
# Add Jolokia (http://www.jolokia.org/) to expose all MBeans
ln -s /opt/jolokia/jolokia.jar $JBOSS_HOME/jolokia.jar

# Start Jolokia agent on boot
cat ${ADDED_DIR}/standalone.conf >> $JBOSS_HOME/bin/standalone.conf
