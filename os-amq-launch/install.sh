#!/bin/sh
# Launch script and related configuration
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added
SOURCES_DIR="/tmp/artifacts"

cp -p ${ADDED_DIR}/launch.sh ${ADDED_DIR}/configure.sh ${ADDED_DIR}/readinessProbe.sh ${ADDED_DIR}/drain.sh $AMQ_HOME/bin/
cp -p ${ADDED_DIR}/openshift-activemq.xml ${ADDED_DIR}/openshift-login.config ${ADDED_DIR}/openshift-users.properties ${ADDED_DIR}/log4j.properties $AMQ_HOME/conf/
cp -p ${SOURCES_DIR}/ce-amq-drain-1.0.0.Final-redhat-1.jar $AMQ_HOME/lib

function findJar() {
  AMQ_LIB="${AMQ_HOME}/lib"
  JAR_NAME="$1"

  JAR="$(find $AMQ_LIB -name ${JAR_NAME}\*.jar)"
  if [ -n "${JAR}" -a -f "${JAR}" ] ; then
    echo "${JAR}"
  else
    echo "Could not locate jar ${JAR_NAME}" >&2
    exit 1
  fi
}

DRAIN_CLASSPATH="$(findJar ce-amq-drain)"

#for jar in activemq-client slf4j-api geronimo-jms_1.1_spec hawtbuf-1 geronimo-j2ee-management_1.1_spec \
   #geronimo-jta_1.0.1B_spec activemq-jms-pool commons-pool geronimo-j2ee-connector_1.5_spec \
   #log4j slf4j-log4j12
for jar in activemq-broker activemq-client slf4j-api geronimo-jms_1.1_spec activemq-kahadb-store \
   activemq-protobuf activemq-openwire-legacy openshift-activemq-plugin hawtbuf-1 \
   geronimo-j2ee-management_1.1_spec slf4j-log4j12 log4j jboss-dmr
do
  DRAIN_CLASSPATH="${DRAIN_CLASSPATH}:$(findJar "$jar")"
done

echo "export DRAIN_CLASSPATH=${DRAIN_CLASSPATH}" > "${AMQ_HOME}/bin/drainClasspath.sh"
