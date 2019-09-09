#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

# configure artifact permissions
chown -R jboss:root $ARTIFACTS_DIR
chmod -R ug+rwX $ARTIFACTS_DIR
chmod ug+x ${ARTIFACTS_DIR}/opt/jboss/container/maven/default/maven.sh

# install artifacts
pushd ${ARTIFACTS_DIR}
cp -pr * /
popd

# pull in specific maven version to serve as default
ln -s /opt/jboss/container/maven/35/* /opt/jboss/container/maven/default
chown -h jboss:root /opt/jboss/container/maven/default/*

# install default settings.xml file in user home
mkdir -p $HOME/.m2
ln -s /opt/jboss/container/maven/default/jboss-settings.xml $HOME/.m2/settings.xml

chown -R jboss:root $HOME/.m2
chmod -R ug+rwX $HOME/.m2
