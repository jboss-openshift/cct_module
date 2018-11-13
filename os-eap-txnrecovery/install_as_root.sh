set -u
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added
SOURCES_DIR="/tmp/artifacts"


test -d /opt/partition || mkdir /opt/partition

cp "$ADDED_DIR"/*.sh "$ADDED_DIR"/*.py /opt/partition/
chmod 755 /opt/partition/*
