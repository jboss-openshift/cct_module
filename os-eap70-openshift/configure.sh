#!/bin/sh
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

# Add custom configuration file
cp -p ${ADDED_DIR}/standalone-openshift.xml $JBOSS_HOME/standalone/configuration/
