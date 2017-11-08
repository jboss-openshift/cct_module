#!/bin/sh

if [ "${SCRIPT_DEBUG}" = "true" ] ; then
    set -x
    echo "Script debugging is enabled, allowing bash commands and their arguments to be printed as they are executed"
fi

CONFIG_FILE=$JBOSS_HOME/standalone/configuration/clustered-openshift.xml
LOGGING_FILE=$JBOSS_HOME/standalone/configuration/logging.properties

CONFIGURE_SCRIPTS=(
  $JBOSS_HOME/bin/launch/backward-compatibility.sh
  $JBOSS_HOME/bin/launch/configure_extensions.sh
  $JBOSS_HOME/bin/launch/passwd.sh
  $JBOSS_HOME/bin/launch/authentication-config.sh
  $JBOSS_HOME/bin/launch/datasource.sh
  $JBOSS_HOME/bin/launch/admin.sh
  $JBOSS_HOME/bin/launch/ha.sh
  $JBOSS_HOME/bin/launch/jgroups.sh
  $JBOSS_HOME/bin/launch/https.sh
  $JBOSS_HOME/bin/launch/json_logging.sh
  $JBOSS_HOME/bin/launch/security-domains.sh
  $JBOSS_HOME/bin/launch/infinispan-config.sh
  $JBOSS_HOME/bin/launch/access_log_valve.sh
  $JBOSS_HOME/bin/launch/standalone.sh
  /opt/run-java/proxy-options
)

source $JBOSS_HOME/bin/launch/configure.sh

echo "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION"

exec $JBOSS_HOME/bin/clustered.sh -c clustered-openshift.xml -bmanagement 127.0.0.1 ${JBOSS_HA_ARGS} ${JAVA_PROXY_OPTIONS}
