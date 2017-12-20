#!/bin/bash

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

# Make sure the owner of added files is the 'jboss' user
# Necessary to permit running with a randomised UID
chown -R jboss:root $SCRIPT_DIR
chmod -R g+rwX $SCRIPT_DIR

# Move the parent EAP S2I assemble script and install child S2I scripts
mv /usr/local/s2i/assemble /usr/local/s2i/assemble_eap
cp -r ${ADDED_DIR}/s2i/* /usr/local/s2i/
chmod ug+x /usr/local/s2i/*
