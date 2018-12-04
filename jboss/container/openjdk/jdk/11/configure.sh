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

# As of rhel 7.6, rh-maven35 pulls in jdk8, so we need to remove them
# XXX: This code should eventually move to the maven module, once layering is fully supported in cekit, as this module
# would be installed before maven (i.e. there's nothing to remove when this module is installed)
if [ -n "$(yum list installed java-1.8.0-openjdk-devel |grep java-1.8.0-openjdk-devel)" ]; then
    rpm -e --nodeps java-1.8.0-openjdk-devel
fi

if [ -n "$(yum list installed java-1.8.0-openjdk-headless |grep java-1.8.0-openjdk-headless)" ]; then
    rpm -e --nodeps java-1.8.0-openjdk-headless
fi

if [ -n "$(yum list installed java-1.8.0-openjdk |grep java-1.8.0-openjdk)" ]; then
    rpm -e --nodeps java-1.8.0-openjdk
fi

# Update securerandom.source for quicker starts (must be done after removing jdk 8, or it will hit the wrong files)
JAVA_SECURITY_FILE=/usr/lib/jvm/java/conf/security/java.security
SECURERANDOM=securerandom.source
if grep -q "^$SECURERANDOM=.*" $JAVA_SECURITY_FILE; then
    sed -i "s|^$SECURERANDOM=.*|$SECURERANDOM=file:/dev/urandom|" $JAVA_SECURITY_FILE
else
    echo $SECURERANDOM=file:/dev/urandom >> $JAVA_SECURITY_FILE
fi
