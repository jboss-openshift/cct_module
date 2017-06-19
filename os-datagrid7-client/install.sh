#!/bin/bash

set -e

export JDG_VERSION=jboss-dg-7.1.0
SOURCES_DIR="/tmp/artifacts"
SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added
TARGET_DIR=/extensions
MODULE_DIR=${TARGET_DIR}/modules/system/layers/openshift/

mkdir -p ${MODULE_DIR}

cp -r ${ADDED_DIR}/install.sh ${TARGET_DIR}

unzip ${SOURCES_DIR}/jboss-datagrid-7.1.0-eap-modules-remote-java-client.zip -d ${SOURCES_DIR}
cp -rf ${SOURCES_DIR}/jboss-datagrid-7.1.0-eap-modules-remote-java-client/modules/* ${MODULE_DIR}
 
# Make sure the owner of added files is the 'jboss' user
chown -R jboss:root ${TARGET_DIR}

# Necessary to permit running with a randomised UID
chmod -R g+rwX ${TARGET_DIR}

