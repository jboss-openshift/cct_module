#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

mkdir -p /usr/share/java/prometheus-jmx-exporter
mv /tmp/artifacts/jmx_prometheus_javaagent-*.jar \
	/usr/share/java/prometheus-jmx-exporter/jmx_prometheus_javaagent.jar
chown -h jboss:root \
	/usr/share/java/prometheus-jmx-exporter/jmx_prometheus_javaagent.jar

chown -R jboss:root ${ARTIFACTS_DIR}
chmod 755 ${ARTIFACTS_DIR}/opt/jboss/container/prometheus/prometheus-opts
chmod 775 ${ARTIFACTS_DIR}/opt/jboss/container/prometheus/etc
chmod 775 ${ARTIFACTS_DIR}/opt/jboss/container/prometheus/etc/jmx-exporter-config.yaml

pushd ${ARTIFACTS_DIR}
cp -pr * /
popd
