#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

mv /tmp/artifacts/hawkular-javaagent-*.jar ${ARTIFACTS_DIR}/opt/jboss/container/hawkular

chown -R jboss:root ${ARTIFACTS_DIR}
chmod 444 ${ARTIFACTS_DIR}/opt/jboss/container/hawkular/hawkular-javaagent-*.jar
chmod 755 ${ARTIFACTS_DIR}/opt/jboss/container/hawkular/hawkular-opts
chmod 775 ${ARTIFACTS_DIR}/opt/jboss/container/hawkular/etc
chmod 775 ${ARTIFACTS_DIR}/opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml

pushd ${ARTIFACTS_DIR}
cp -pr * /
popd

ln -s /opt/jboss/container/hawkular/hawkular-javaagent-*.jar /opt/jboss/container/hawkular/hawkular-javaagent.jar
chown -h jboss:root /opt/jboss/container/hawkular/hawkular-javaagent.jar