#!/bin/bash
set -ueo pipefail

# Legacy location
ln -s /usr/share/java/prometheus-jmx-exporter/jmx_prometheus_javaagent.jar \
	$JBOSS_CONTAINER_PROMETHEUS_MODULE/jmx_prometheus_javaagent.jar
