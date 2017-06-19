#!/bin/bash
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

cp -p "$ADDED_DIR/modules/layers.conf" "$JBOSS_HOME/modules/"
chown jboss:root $JBOSS_HOME/modules/layers.conf
chmod g+rwX $JBOSS_HOME/modules/layers.conf
