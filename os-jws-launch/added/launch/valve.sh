#!/bin/bash

function configure() {
  configure_error_valve
}

configure_error_valve() {
  if [ -n "$DEBUG" ] && [ "$DEBUG" == "true" ]; then
    sed -i "s|##TOMCAT_SHOW_REPORT##|true|" $JWS_HOME/conf/server.xml
    sed -i "s|##TOMCAT_SHOW_SERVER_INFO##|true|" $JWS_HOME/conf/server.xml
  else
    sed -i "s|##TOMCAT_SHOW_REPORT##|false|" $JWS_HOME/conf/server.xml
    sed -i "s|##TOMCAT_SHOW_SERVER_INFO##|false|" $JWS_HOME/conf/server.xml
  fi
}