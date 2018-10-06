#!/bin/sh
# Configure module
set -e

# As of rhel 7.6, rh-maven35 pulls in jdk8, so we need to remove them

if [ -n "$(yum list installed java-1.8.0-openjdk-devel |grep java-1.8.0-openjdk-devel)" ]; then
    rpm -e --nodeps java-1.8.0-openjdk-devel
fi

if [ -n "$(yum list installed java-1.8.0-openjdk-headless |grep java-1.8.0-openjdk-headless)" ]; then
    rpm -e --nodeps java-1.8.0-openjdk-headless
fi

if [ -n "$(yum list installed java-1.8.0-openjdk |grep java-1.8.0-openjdk)" ]; then
    rpm -e --nodeps java-1.8.0-openjdk
fi
