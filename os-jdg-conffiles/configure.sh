#!/bin/bash
# Add custom configuration file
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

rm $JBOSS_HOME/standalone/configuration/standalone-openshift.xml
cp -p ${ADDED_DIR}/clustered-openshift.xml $JBOSS_HOME/standalone/configuration/
