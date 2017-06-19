#!/bin/bash

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

mkdir -p $JBOSS_HOME/bin/launch

cp ${ADDED_DIR}/keycloak.sh $JBOSS_HOME/bin/launch

cp ${ADDED_DIR}/keycloak-realm-subsystem $JBOSS_HOME/bin/launch/
cp ${ADDED_DIR}/keycloak-saml-realm-subsystem $JBOSS_HOME/bin/launch/
cp ${ADDED_DIR}/keycloak-deployment-subsystem $JBOSS_HOME/bin/launch/
cp ${ADDED_DIR}/keycloak-saml-deployment-subsystem $JBOSS_HOME/bin/launch/
cp ${ADDED_DIR}/keycloak-saml-sp-subsystem $JBOSS_HOME/bin/launch/
cp ${ADDED_DIR}/keycloak-security-domain $JBOSS_HOME/bin/launch/
