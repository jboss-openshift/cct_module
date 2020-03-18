#!/bin/bash
# Set up jolokia for java s2i builder image
set -euo pipefail

# Legacy locations

ln -s /opt/jboss/container/jolokia /opt/jolokia
chown -h jboss:root /opt/jolokia

ln -s /usr/share/java/jolokia-jvm-agent/jolokia-jvm.jar \
	$JBOSS_CONTAINER_JOLOKIA_MODULE/jolokia.jar
