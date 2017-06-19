#!/bin/bash

function configure() {
  configure_shutdown
}

configure_shutdown() {
  if [ -n "$TOMCAT_SHUTDOWN" ]; then
    sed -i "s|##TOMCAT_SHUTDOWN##|${TOMCAT_SHUTDOWN}|" $JWS_HOME/conf/server.xml
  else
    sed -i "s|##TOMCAT_SHUTDOWN##|SHUTDOWN|" $JWS_HOME/conf/server.xml
  fi
}