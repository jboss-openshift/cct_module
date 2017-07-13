# bourne shell script snippet
# used by OpenShift JBoss Web Server launch script

function prepareEnv() {
  unset JWS_SERVER_NAME
}

function configure() {
  configure_http
}

function configure_http() {
  if [ -n "$JWS_SERVER_NAME" ]; then 
    sed -i "s|redirectPort=\"8443\"|redirectPort=\"8443\" server=\"${JWS_SERVER_NAME}\"|" $JWS_HOME/conf/server.xml
  fi

}
