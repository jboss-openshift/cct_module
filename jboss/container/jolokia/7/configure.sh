#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

mv /tmp/artifacts/jolokia-jvm-*-agent.jar ${ARTIFACTS_DIR}/opt/jboss/container/jolokia

chown -R jboss:root $SCRIPT_DIR
chmod -R ug+rwX $SCRIPT_DIR
chmod ug+x ${ARTIFACTS_DIR}/opt/jboss/container/jolokia/*

pushd ${ARTIFACTS_DIR}
cp -pr * /
popd

mkdir -p /opt/jboss/container/jolokia/etc
chmod 775 /opt/jboss/container/jolokia/etc
chown -R jboss:root /opt/jboss/container/jolokia/etc

ln -s /opt/jboss/container/jolokia/jolokia-jvm-*-agent.jar /opt/jboss/container/jolokia/jolokia.jar
chown -h jboss:root /opt/jboss/container/jolokia/jolokia.jar
