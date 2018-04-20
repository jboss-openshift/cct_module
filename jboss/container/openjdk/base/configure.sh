#!/bin/bash
set -e

# Use /dev/urandom to speed up startups.
echo securerandom.source=file:/dev/urandom >> /usr/lib/jvm/java/jre/lib/security/java.security
