# bourne shell script snippet
# used by OpenShift JBoss Web Server launch script

function configure() {
  configure_administration
}

function configure_administration() {
  if [ -n "${JWS_ADMIN_PASSWORD+_}" ]; then
      # default management username 'jwsadmin'
      JWS_ADMIN_USERNAME=${JWS_ADMIN_USERNAME:-jwsadmin}
      sed -i "/username=\"${JWS_ADMIN_USERNAME}\"/d" $JWS_HOME/conf/tomcat-users.xml
      sed -i -e"s|</tomcat-users>|\n<user username=\"${JWS_ADMIN_USERNAME}\" password=\"${JWS_ADMIN_PASSWORD}\" roles=\"manager-jmx,manager-script\"/>\n</tomcat-users>|" $JWS_HOME/conf/tomcat-users.xml
  fi
}
