set -u
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

test -d /opt/partition || mkdir /opt/partition

cp "$ADDED_DIR"/* /opt/partition/

chmod 755 /opt/partition/*
