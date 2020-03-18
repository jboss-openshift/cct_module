#!/bin/bash
set -euo pipefail

# Legacy (pre-RPM) location
ln -s /usr/share/java/jolokia-jvm-agent/jolokia-jvm.jar \
	$JBOSS_CONTAINER_JOLOKIA_MODULE/jolokia.jar
