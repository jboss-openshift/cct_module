
function configure() {
  configure_jvm
}

function configure_jvm() {
  sed -c -i "s|JAVA_OPTS=\"-Xms64m -Xmx512m -XX:MaxPermSize=256m -Djava.net.preferIPv4Stack=true\"|JAVA_OPTS=\"-Xms1303m -Xmx1303m -XX:MaxPermSize=256m -Djava.net.preferIPv4Stack=true -Dorg.jboss.resolver.warning=true -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000\"|" "${JBOSS_HOME}/bin/standalone.conf"
}
