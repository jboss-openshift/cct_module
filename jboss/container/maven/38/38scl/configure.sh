#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

chown -R jboss:root $ARTIFACTS_DIR
chmod -R ug+rwX $ARTIFACTS_DIR
chmod ug+x ${ARTIFACTS_DIR}/opt/jboss/container/maven/38/scl-enable-maven

pushd ${ARTIFACTS_DIR}
cp -pr * /
popd

# maven pulls in jdk17, so we need to remove them if another jdk is the default
if ! readlink /etc/alternatives/java | grep -q "java-17"; then
    for pkg in java-17-openjdk-devel \
               java-17-openjdk-headless \
               java-17-openjdk; do
        if rpm -q "$pkg"; then
            rpm -e --nodeps "$pkg"
        fi
    done
fi
