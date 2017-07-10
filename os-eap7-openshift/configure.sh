#!/bin/sh
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

# various configuration tweaks to EAP standalone startup. NOTE: these
# must appear at the end of the resulting standalone.conf in order to
# function correctly; therefore this script package must be applied
# after any other that modify this file.
cat ${ADDED_DIR}/standalone.conf >> $JBOSS_HOME/bin/standalone.conf
