#!/bin/sh
set -u
set -e

cp /var/run/secrets/kubernetes.io/serviceaccount/service-ca.crt \
	/etc/pki/ca-trust/source/anchors/
/usr/bin/update-ca-trust


