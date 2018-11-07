#!/bin/sh
set -e

if [ -z "$JAVA_DISABLE_TRUST_OPENSHIFT_CA" ]; then
    ca=/var/run/secrets/kubernetes.io/serviceaccount/service-ca.crt
    if test -r "$ca" ; then
        cp "$ca" /etc/pki/ca-trust/source/anchors/
        /usr/bin/update-ca-trust
    fi
fi
