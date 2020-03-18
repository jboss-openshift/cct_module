#!/bin/sh
set -e

dnf module enable -y maven:3.6
dnf install -y --setopt=tsflags=nodocs maven
dnf clean all
