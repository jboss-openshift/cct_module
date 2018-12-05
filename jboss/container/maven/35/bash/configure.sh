#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

chown -R jboss:root $ARTIFACTS_DIR
chmod -R ug+rwX $ARTIFACTS_DIR
chmod ug+x ${ARTIFACTS_DIR}/opt/jboss/container/maven/35/scl-enable-maven

pushd ${ARTIFACTS_DIR}
cp -pr * /
popd

# rh-maven35 pulls in jdk8, so we need to remove them if another jdk is the default
if ! $(ls -la /etc/alternatives/java |grep -q "java-1\.8\.0"); then
    if [ -n "$(yum list installed java-1.8.0-openjdk-devel |grep java-1.8.0-openjdk-devel)" ]; then
        rpm -e --nodeps java-1.8.0-openjdk-devel
    fi

    if [ -n "$(yum list installed java-1.8.0-openjdk-headless |grep java-1.8.0-openjdk-headless)" ]; then
        rpm -e --nodeps java-1.8.0-openjdk-headless
    fi

    if [ -n "$(yum list installed java-1.8.0-openjdk |grep java-1.8.0-openjdk)" ]; then
        rpm -e --nodeps java-1.8.0-openjdk
    fi
fi
