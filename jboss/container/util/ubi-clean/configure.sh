#!/bin/sh

# This list of packages was arrived at by running the following in a
# UBI/OpenJDK container, in an environment *without any redhat entitlements* to
# be sure the repodata is ONLY that available via normal UBI channels and not
# the wider RHEL8 or anything else:
#   rpm -qa --queryformat "%{NAME}\n" \
#   | while read pkg; do microdnf repoquery $pkg 2>/dev/null | grep -q $pkg || echo $pkg; done

microdnf remove grub2-common \
    dejavu-sans-mono-fonts \
    memstrack \
    os-prober \
    grub2-tools \
    grubby \
    rpm-plugin-systemd-inhibit \
    grub2-tools-minimal \
