#!/bin/sh
set -e

SCRIPT_DIR=$(dirname $0)
SRC_DIR=${SCRIPT_DIR}/src

# Add prometheus configuration
cat ${SRC_DIR}/standalone.conf >> $JBOSS_HOME/bin/standalone.conf
