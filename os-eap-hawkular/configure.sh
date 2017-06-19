#!/bin/sh
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

# Add hawkular configuration
cat ${ADDED_DIR}/standalone.conf >> $JBOSS_HOME/bin/standalone.conf

