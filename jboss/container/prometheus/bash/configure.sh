#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

mv /tmp/artifacts/jmx_prometheus_javaagent-*.jar ${ARTIFACTS_DIR}/opt/jboss/container/prometheus

chown -R jboss:root ${ARTIFACTS_DIR}
chmod 444 ${ARTIFACTS_DIR}/opt/jboss/container/prometheus/jmx_prometheus_javaagent-*.jar
chmod 755 ${ARTIFACTS_DIR}/opt/jboss/container/prometheus/prometheus-opts
chmod 775 ${ARTIFACTS_DIR}/opt/jboss/container/prometheus/etc
chmod 775 ${ARTIFACTS_DIR}/opt/jboss/container/prometheus/etc/jmx-exporter-config.yaml

pushd ${ARTIFACTS_DIR}
cp -pr * /
popd

ln -s /opt/jboss/container/prometheus/jmx_prometheus_javaagent-*.jar /opt/jboss/container/prometheus/jmx_prometheus_javaagent.jar
chown -h jboss:root /opt/jboss/container/prometheus/jmx_prometheus_javaagent.jar
