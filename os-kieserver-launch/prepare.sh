#!/bin/bash
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

# Make sure the owner of added files is the 'jboss' user
chown -R jboss:jboss ${SCRIPT_DIR}
