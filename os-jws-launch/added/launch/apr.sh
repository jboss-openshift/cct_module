
function prepareEnv() {
  unset USE_32_BIT_JVM
}

function configure() {
  configure_apr
}

function configure_apr() {

  if [ "${USE_32_BIT_JVM^^}" != "TRUE" ]; then
    sed -i "s|<!-- ##JWS_APR## -->|<Listener className=\"org.apache.catalina.core.AprLifecycleListener\" SSLEngine=\"on\" />|" $JWS_HOME/conf/server.xml
  fi
}
