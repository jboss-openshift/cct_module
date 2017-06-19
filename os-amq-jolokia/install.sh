#!/bin/sh
# Add Jolokia (http://www.jolokia.org/) to expose all MBeans
set -e

SOURCES_DIR="/tmp/artifacts"

# for backward compatibility.  jolokia is now located in /opt/jolokia.
cp -p ${SOURCES_DIR}/jolokia-jvm-*-agent.jar $AMQ_HOME/jolokia.jar
