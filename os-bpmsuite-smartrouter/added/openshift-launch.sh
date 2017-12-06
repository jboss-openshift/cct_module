#!/bin/sh
# Openshift BPMS Smart Router launch script

if [ "${SCRIPT_DEBUG}" = "true" ] ; then
    set -x
    echo "Script debugging is enabled, allowing bash commands and their arguments to be printed as they are executed"
fi

CONFIGURE_SCRIPTS=(
  /opt/${JBOSS_PRODUCT}/launch/bpmsuite-smartrouter.sh
)

source /opt/${JBOSS_PRODUCT}/launch/configure.sh

echo "Running $JBOSS_IMAGE_NAME image, version $PRODUCT_VERSION"

if [ -n "$CLI_GRACEFUL_SHUTDOWN" ] ; then
  trap "" TERM
  echo "Using CLI Graceful Shutdown instead of TERM signal"
fi

exec  ${JAVA_HOME}/bin/java ${JBOSS_BPMSUITE_ARGS} -jar /opt/${JBOSS_PRODUCT}/${KIE_ROUTER_DISTRIBUTION_JAR}
