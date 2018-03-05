#!/bin/sh
set -e

SOURCES_DIR="/tmp/artifacts"

cp -p "$SOURCES_DIR"/openshift-activemq-plugin-1.2.1.Final-redhat-1.jar $AMQ_HOME/lib/optional/
cp -p "$SOURCES_DIR"/jboss-dmr-1.2.2.Final-redhat-1.jar $AMQ_HOME/lib/optional/
