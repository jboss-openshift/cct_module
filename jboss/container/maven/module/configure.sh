#!/bin/sh
set -e

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

cp ${ARTIFACTS_DIR}/maven.module /etc/dnf/modules.d/maven.module
