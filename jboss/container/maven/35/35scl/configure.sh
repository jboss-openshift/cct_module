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

# maven pulls in jdk8, so we need to remove them if another jdk is the default
if ! readlink /etc/alternatives/java | grep -q "java-1\.8\.0"; then
    for pkg in java-1.8.0-openjdk-devel \
               java-1.8.0-openjdk-headless \
               java-1.8.0-openjdk; do
        if rpm -q "$pkg"; then
            rpm -e --nodeps "$pkg"
        fi
    done
fi
