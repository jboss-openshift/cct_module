#!/bin/bash

set -e

export JDV_ARTIFACT_VERSION=8.12.10.6_3-redhat-2
SOURCES_DIR="/tmp/artifacts"
SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added
TARGET_DIR=/extensions
MODULE_DIR=${TARGET_DIR}/modules/system/layers/openshift/org/jboss/teiid/client/main

mkdir -p ${MODULE_DIR}

cp -r ${ADDED_DIR}/install.sh ${ADDED_DIR}/install.properties ${TARGET_DIR}

# create the module
mkdir -p /org/jboss/teiid/client/main
cp -r ${SOURCES_DIR}/teiid-jdbc-${JDV_ARTIFACT_VERSION}.jar ${MODULE_DIR}
cp -r ${SOURCES_DIR}/teiid-hibernate-dialect-${JDV_ARTIFACT_VERSION}.jar ${MODULE_DIR}
cat ${ADDED_DIR}/module.xml | envsubst > ${MODULE_DIR}/module.xml

# Make sure the owner of added files is the 'jboss' user
chown -R jboss:root ${TARGET_DIR}

# Necessary to permit running with a randomised UID
chmod -R g+rwX ${TARGET_DIR}

