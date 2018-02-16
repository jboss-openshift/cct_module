#!/bin/sh

source $AMQ_HOME/bin/launch/logging.sh

if [ "${SCRIPT_DEBUG}" = "true" ] ; then
    set -x
    log_info "Script debugging is enabled, allowing bash commands and their arguments to be printed as they are executed"
fi

source $AMQ_HOME/bin/configure.sh
source /opt/partition/partitionPV.sh
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
options="$(proxy_options)"
options="$(echo $options | sed 's|"|\\"|g')"
ACTIVEMQ_OPTS="$ACTIVEMQ_OPTS $options"

# Add jolokia command line options
cat <<EOF > $AMQ_HOME/bin/env
ACTIVEMQ_OPTS="${ACTIVEMQ_OPTS} ${JAVA_OPTS_APPEND}"
EOF

log_info "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION"

# Parameters are
# - instance directory
function runServer() {
  # Fix log file
  local instanceDir=$1
  local log_file="$AMQ_HOME/conf/log4j.properties"
  sed -i "s+activemq\.base}/data+activemq.data}+" "$log_file"

  export ACTIVEMQ_DATA="$instanceDir"
  exec "$AMQ_HOME/bin/activemq" console
}

function init_data_dir() {
  # No init needed for AMQ
  return
}

if [ "$AMQ_SPLIT" = "true" ]; then
  DATA_DIR="${AMQ_HOME}/data"
  mkdir -p "${DATA_DIR}"

  partitionPV "${DATA_DIR}" "${AMQ_LOCK_TIMEOUT:-30}"
else
    exec $AMQ_HOME/bin/activemq console
fi
