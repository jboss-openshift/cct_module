#!/bin/sh
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added
SOURCES_DIR="/tmp/artifacts"

. $JBOSS_HOME/bin/launch/files.sh

cp -p ${ADDED_DIR}/logging.properties ${JBOSS_HOME}/standalone/configuration/

JBOSS_LOGGING_JAR="$(getfiles org/jboss/logging/main/jboss-logging)"
JBOSS_LOGGING_DIR="$(dirname $JBOSS_LOGGING_JAR)"

# Location where to install the new module
# TODO: move to openshift layer
OPENSHIFT_LAYER_PATH="${JBOSS_HOME}/modules/system/layers/base/org/jboss/logmanager/ext/main/"

mkdir -p $OPENSHIFT_LAYER_PATH
cp -p ${SOURCES_DIR}/javax.json-1.0.4.jar $OPENSHIFT_LAYER_PATH
cp -p ${SOURCES_DIR}/jboss-logmanager-ext-1.0.0.Alpha5-redhat-1.jar $OPENSHIFT_LAYER_PATH
sed -i 's|org.jboss.logmanager|org.jboss.logmanager.ext|' $JBOSS_LOGGING_DIR/module.xml
