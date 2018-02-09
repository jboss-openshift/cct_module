#!/bin/sh
# Openshift SSO migration script

RECOVERY_TIMEOUT=${RECOVERY_TIMEOUT:-360}
RECOVERY_PAUSE=${RECOVERY_PAUSE:-10}

source ${JBOSS_HOME}/bin/launch/openshift-migrate-common.sh
