#!/bin/sh

if [ "${SCRIPT_DEBUG}" = "true" ] ; then
    set -x
    echo "Script debugging is enabled, allowing bash commands and their arguments to be printed as they are executed"
fi

CONFIGURE_SCRIPTS=(
  $JWS_HOME/bin/launch/configure_extensions.sh
  $JWS_HOME/bin/launch/passwd.sh
  $JWS_HOME/bin/launch/shutdown.sh
  $JWS_HOME/bin/launch/valve.sh
  $JWS_HOME/bin/launch/resource.sh
  $JWS_HOME/bin/launch/secure-mgmt-console.sh
  $JWS_HOME/bin/launch/http.sh
  $JWS_HOME/bin/launch/https.sh
  $JWS_HOME/bin/launch/realm.sh
  $JWS_HOME/bin/launch/catalina.sh
  $JWS_HOME/bin/launch/web.sh
  /opt/run-java/proxy-options
)

source $JWS_HOME/bin/launch/configure.sh

CATALINA_OPTS="${CATALINA_OPTS} ${JAVA_PROXY_OPTIONS}"

echo "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION"

exec $JWS_HOME/bin/catalina.sh run
