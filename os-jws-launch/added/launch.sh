#!/bin/sh

source $JWS_HOME/bin/launch/logging.sh

if [ "${SCRIPT_DEBUG}" = "true" ] ; then
    set -x
    log_info "Script debugging is enabled, allowing bash commands and their arguments to be printed as they are executed"
fi

function escape_catalina_opts() {
  local opts=($CATALINA_OPTS)
  CATALINA_OPTS=$(printf "%q " ${opts[@]})
}

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
  /opt/run-java/proxy-options
)

source $JWS_HOME/bin/launch/configure.sh

CATALINA_OPTS="${CATALINA_OPTS} ${JAVA_PROXY_OPTIONS}"
escape_catalina_opts

log_info "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION"

exec $JWS_HOME/bin/catalina.sh run
