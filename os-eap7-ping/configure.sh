#!/bin/sh
# Add OpenShift PING implementation
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added
SOURCES_DIR="/tmp/artifacts"
VERSION="1.2.1.Final-redhat-1"

DEST=${JBOSS_HOME}/modules/system/layers/openshift/org/openshift/ping/main
mkdir -p ${DEST}

cp -p ${ADDED_DIR}/modules/system/layers/openshift/org/openshift/ping/main/module.xml \
      ${SOURCES_DIR}/openshift-ping-common-$VERSION.jar \
      ${SOURCES_DIR}/openshift-ping-dns-$VERSION.jar \
      ${SOURCES_DIR}/openshift-ping-kube-$VERSION.jar \
      ${DEST}

sed -i "s/##VERSION##/$VERSION/g" ${DEST}/module.xml

DEST="$JBOSS_HOME/modules/system/layers/openshift/net/oauth/core/main/"
mkdir -p "$DEST"
cp -p  ${ADDED_DIR}/modules/system/layers/openshift/net/oauth/core/main/module.xml \
       ${SOURCES_DIR}/oauth-20100527.jar "$DEST"
