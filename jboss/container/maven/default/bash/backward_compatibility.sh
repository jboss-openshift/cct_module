#!/bin/sh
# Configure module
set -e
# For backward compatibility
mkdir -p /usr/local/s2i
# scl-enable-maven is not needed on ubi8 images.
if test -r "${JBOSS_CONTAINER_MAVEN_DEFAULT_MODULE}/scl-enable-maven"; then
    ln -s /opt/jboss/container/maven/default/scl-enable-maven /usr/local/s2i/scl-enable-maven
    chown -h jboss:root /usr/local/s2i/scl-enable-maven
fi

ln -s /opt/jboss/container/maven/default/maven.sh /usr/local/s2i/common.sh
chown -h jboss:root /usr/local/s2i/common.sh
