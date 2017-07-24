#!/bin/bash

function prepareEnv() {
  unset DEBUG
  unset DISABLE_REMOTE_IP_VALVE
}

function configure() {
  configure_error_valve
  configure_remote_ip_valve
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

configure_remote_ip_valve() {
  if [ "$DISABLE_REMOTE_IP_VALVE" == "true" ]; then
    sed -i "s|<!-- ##REMOTE_IP_VALVE## -->||" $JWS_HOME/conf/server.xml
  else
    sed -i "s|<!-- ##REMOTE_IP_VALVE## -->|<Valve className=\"org.apache.catalina.valves.RemoteIpValve\" remoteIpHeader=\"X-Forwarded-For\" protocolHeader=\"X-Forwarded-Proto\"/>|" $JWS_HOME/conf/server.xml
  fi
}

