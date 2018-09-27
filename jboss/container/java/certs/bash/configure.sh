#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

# necessary for random UID user to run update-ca-certs
chmod 777 \
	/etc/pki/ca-trust/extracted/openssl \
	/etc/pki/ca-trust/extracted/java \
	/etc/pki/ca-trust/source/anchors \
	/etc/pki/ca-trust/extracted/pem

# XXX this script needs to be copied to wherever the runtime scripts go
# trust-ose-cert.sh
cp "${ARTIFACTS_DIR}/trust-ose-cert.sh" /opt/jboss
chmod +x /opt/jboss/trust-ose-cert.sh
# temp path
