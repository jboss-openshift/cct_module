#!/bin/sh
# Link DB drivers, provided by RPM packages, into the "openshift" layer
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

function link {
  mkdir -p $(dirname $2)
  ln -s $1 $2
}

link /usr/share/java/mysql-connector-java.jar $JBOSS_HOME/modules/system/layers/openshift/com/mysql/main/mysql-connector-java.jar
link /usr/share/java/postgresql-jdbc.jar $JBOSS_HOME/modules/system/layers/openshift/org/postgresql/main/postgresql-jdbc.jar
link /opt/rh/rh-mongodb32/root/usr/share/java/mongo-java-driver/mongo.jar $JBOSS_HOME/modules/system/layers/openshift/org/mongodb/main/mongo.jar

# module definitions for MySQL, PostgreSQL, MongoDB
# Remove any existing destination files first (which might be symlinks)
cp -rp --remove-destination "$ADDED_DIR/modules" "$JBOSS_HOME/"
