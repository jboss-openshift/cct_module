set -u
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added
SOURCES_DIR="/tmp/artifacts"
MODULE_DEST=${JBOSS_HOME}/modules/system/layers/openshift/io/narayana/openshift-recovery/main


test -d /opt/partition || mkdir /opt/partition

cp "$ADDED_DIR"/*.sh "$ADDED_DIR"/*.py /opt/partition/
chmod 755 /opt/partition/*


mkdir -p ${MODULE_DEST}
cp "${ADDED_DIR}"/modules/system/layers/openshift/io/narayana/openshift-recovery/main/module.xml ${MODULE_DEST}
cp ${SOURCES_DIR}/txn-recovery-marker-jdbc-*.jar ${MODULE_DEST}/txn-recovery-marker-jdbc.jar
chown -R jboss:jboss ${JBOSS_HOME}/modules/system/layers/openshift/io/
chmod 755 -R ${JBOSS_HOME}/modules/system/layers/openshift/io/
