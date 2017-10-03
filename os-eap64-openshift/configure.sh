#!/bin/sh
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

# various configuration tweaks to EAP standalone startup. NOTE: these
# must appear at the end of the resulting standalone.conf in order to
# function correctly; therefore this script package must be applied
# after any other that modify this file.
cat ${ADDED_DIR}/standalone.conf >> $JBOSS_HOME/bin/standalone.conf

# Add custom configuration file
cp -p ${ADDED_DIR}/standalone-openshift.xml $JBOSS_HOME/standalone/configuration/

mkdir -p ${JBOSS_HOME}/standalone/data/content/38/b8ef5d9c683c14b786ba47845934625a1c15d8
cp ${ADDED_DIR}/jboss-web.xml ${JBOSS_HOME}/standalone/data/content/38/b8ef5d9c683c14b786ba47845934625a1c15d8/content

