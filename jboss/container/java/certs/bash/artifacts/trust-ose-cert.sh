#!/bin/sh
set -e

if [ -z "$JAVA_DISABLE_TRUST_OPENSHIFT_CA" ]; then
    if test -r "/etc/pki/ca-trust/source/anchors/ose-service-ca.crt" ; then
        /usr/bin/update-ca-trust
    fi
fi
