#!/bin/sh
set -e

for dir in $AMQ_HOME $HOME; do
  chown -R jboss:root $dir
  chmod -R g+rwX $dir
done
