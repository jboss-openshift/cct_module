#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

chown -R jboss:root $SCRIPT_DIR
chmod -R ug+rwX $SCRIPT_DIR
chmod ug+x ${ARTIFACTS_DIR}/opt/jboss/container/openjdk/jdk/*

pushd ${ARTIFACTS_DIR}
cp -pr * /
popd

# Set this JDK as the alternative in use
_arch="$(uname -i)"
alternatives --set java java-1.8.0-openjdk.${_arch}
alternatives --set javac java-1.8.0-openjdk.${_arch}
alternatives --set java_sdk_openjdk java-1.8.0-openjdk.${_arch}
alternatives --set jre_openjdk java-1.8.0-openjdk.${_arch}

echo securerandom.source=file:/dev/urandom >> /usr/lib/jvm/java/jre/lib/security/java.security
