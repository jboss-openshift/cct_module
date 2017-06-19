#!/bin/sh
set -e

SCRIPT_DIR=$(dirname $0)

mkdir -p /usr/local/s2i
cp -p $SCRIPT_DIR/common.sh /usr/local/s2i/common.sh
