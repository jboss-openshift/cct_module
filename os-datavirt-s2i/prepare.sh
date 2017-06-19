#!/bin/bash

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

# Make sure the owner of added files is the 'jboss' user
chown -R jboss:jboss ${SCRIPT_DIR}

# Necessary to permit running with a randomised UID
chmod -R a+rwX ${SCRIPT_DIR}

# Move the parent EAP S2I assemble script and install child S2I scripts
mv /usr/local/s2i/assemble /usr/local/s2i/assemble_eap
cp -r ${ADDED_DIR}/s2i/* /usr/local/s2i/
chmod 755 /usr/local/s2i/*
