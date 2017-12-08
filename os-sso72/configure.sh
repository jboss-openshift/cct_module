#!/bin/sh

set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

cp ${ADDED_DIR}/standalone-openshift.xml $JBOSS_HOME/standalone/configuration
cp ${ADDED_DIR}/import-realm.json $JBOSS_HOME/standalone/configuration
cp ${ADDED_DIR}/openshift-launch.sh $JBOSS_HOME/bin/

mkdir -p ${JBOSS_HOME}/bin/launch
cp -r ${ADDED_DIR}/launch/* ${JBOSS_HOME}/bin/launch

mkdir ${JBOSS_HOME}/root-app-redirect
cp ${ADDED_DIR}/index.html ${JBOSS_HOME}/root-app-redirect
rm -rf ${JBOSS_HOME}/welcome-content

chown -R jboss:root $JBOSS_HOME
chmod -R g+rwX $JBOSS_HOME
