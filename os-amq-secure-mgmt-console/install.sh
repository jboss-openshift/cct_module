#!/bin/sh
# Secure the management console
# NOTE: the script package os-amq-launch contains code to configure management
# console credentials and access at runtime.
set -e

sed -i -e 's/0.0.0.0/localhost/' $AMQ_HOME/conf/jetty.xml
