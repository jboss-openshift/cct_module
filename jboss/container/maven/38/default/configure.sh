#!/bin/sh
set -e

# maven pulls in jdk17, so we need to remove them if another jdk is the default
if ! readlink /etc/alternatives/java | grep -q "java-17"; then
    for pkg in java-17-openjdk-devel \
               java-17-openjdk-headless \
               java-17-openjdk; do
        if rpm -q "$pkg"; then
            rpm -e --nodeps "$pkg"
        fi
    done
fi
