#!/bin/bash
# Add new "openshift" layer
# (includes module definitions for MySQL, PostgreSQL, MongoDB, OpenShift PING and OAuth)
# (also includes overridden JGroups, AS Clustering Common/JGroups, and EE for OpenShift PING)
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

cp -rp --remove-destination ${ADDED_DIR}/modules $JBOSS_HOME/
