#!/usr/bin/env bash

source $AMQ_HOME/bin/launch/logging.sh

if [ "${SCRIPT_DEBUG}" = "true" ] ; then
    set -x
    log_info "Script debugging is enabled, allowing bash commands and their arguments to be printed as they are executed"
fi

source $AMQ_HOME/bin/configure.sh
source /opt/partition/partitionPV.sh
source $AMQ_HOME/bin/drainClasspath.sh
source /usr/local/dynamic-resources/dynamic_resources.sh

ACTIVEMQ_OPTS="$(adjust_java_options ${ACTIVEMQ_OPTS})"

ACTIVEMQ_OPTS="${ACTIVEMQ_OPTS} $(/opt/jolokia/jolokia-opts)"

# Make sure that we use /dev/urandom
ACTIVEMQ_OPTS="${ACTIVEMQ_OPTS} -Djava.security.egd=file:/dev/./urandom"

# White list packages for use in ObjectMessages: CLOUD-703
if [ -n "$MQ_SERIALIZABLE_PACKAGES" ]; then
  ACTIVEMQ_OPTS="${ACTIVEMQ_OPTS} -Dorg.apache.activemq.SERIALIZABLE_PACKAGES=${MQ_SERIALIZABLE_PACKAGES}"
fi

# Add proxy command line options
source /opt/run-java/proxy-options
ACTIVEMQ_OPTS="$ACTIVEMQ_OPTS $(proxy_options)"

function runMigration() {
    export ACTIVEMQ_DATA="$1"

    exec java -cp ${DRAIN_CLASSPATH} ${ACTIVEMQ_OPTS}  org.jboss.ce.amq.drain.BrokerServiceDrainer
}

DATA_DIR="${AMQ_HOME}/data"
mkdir -p "${DATA_DIR}"

migratePV "${DATA_DIR}"
