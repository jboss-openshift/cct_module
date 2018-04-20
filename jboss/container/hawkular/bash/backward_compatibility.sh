#!/bin/bash
# Set up Hawkular for java s2i builder image
set -e

ln -s /opt/jboss/container/hawkular /opt/hawkular

chown -h jboss:root /opt/hawkular
