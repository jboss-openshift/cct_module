#!/bin/bash
# Set up jolokia for java s2i builder image
set -e

# Legacy location

ln -s /opt/jboss/container/jolokia /opt/jolokia
chown -h jboss:root /opt/jolokia