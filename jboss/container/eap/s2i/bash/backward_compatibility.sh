#!/bin/bash
# Set up Hawkular for java s2i builder image
set -e

ln -s /opt/jboss/container/eap/s2i/install-common.sh /usr/local/s2i/install-common.sh

chown -h jboss:root /usr/local/s2i/install-common.sh
