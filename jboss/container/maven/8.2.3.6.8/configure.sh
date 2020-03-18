#!/bin/sh
set -e

dnf module enable -y maven:3.6
dnf install -y --setopt=tsflags=nodocs maven-openjdk8
dnf clean all
