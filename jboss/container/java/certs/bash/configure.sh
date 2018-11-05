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

d=/opt/jboss/container/java/certs
mkdir -p "$d"
cp "${ARTIFACTS_DIR}/trust-ose-cert.sh" "$d"
chmod +x "$d/trust-ose-cert.sh"
