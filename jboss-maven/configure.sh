#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

chown -R jboss:root $SCRIPT_DIR
chmod -R ug+rwX $SCRIPT_DIR

# Add default Maven settings with Red Hat/JBoss repositories
mkdir -p $HOME/.m2
cp -p ${ADDED_DIR}/jboss-settings.xml $HOME/.m2/settings.xml

# Add s2i scripts
mkdir -p /usr/local/s2i
cp -p ${ADDED_DIR}/s2i/scl-enable-maven /usr/local/s2i/
chmod ug+x /usr/local/s2i/scl-enable-maven

chown -R jboss:root $HOME
chmod -R g+rwX $HOME
