#!/bin/sh
set -u
set -e

# Clean up any java-* packages that have been installed that do not match
# our stated JAVA_VERSION-JAVA_VENDOR (e.g.: 11-openjdk; 1.8.0-openj9)
rpm -qa java-\* | while read pkg; do
    if ! echo "$pkg" | grep -q "^java-${JAVA_VERSION}-${JAVA_VENDOR}"; then
        rpm -e --nodeps "$pkg"
    fi
done
