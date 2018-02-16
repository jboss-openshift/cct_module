#!/bin/bash

source $JWS_HOME/bin/launch/logging.sh

function prepareEnv() {
  unset DEBUG
  unset DISABLE_REMOTE_IP_VALVE
}

function configure() {
  configure_error_valve
  configure_access_log_valve
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
# Access Log Valve configuration function
# Supports:
#   jws 7|8
# Usage:
#   it is disabled by default, to disable it set the following variable to true:
#   ENABLE_ACCESS_LOG
#
# Default pattern used across all products:
#   %h %l %u %t %{X-Forwarded-Host}i "%r" %s %b
#
# Where:
#   %h: Remote host name
#   %l: Remote logical username from identd (always returns '-')
#   %u: Remote user that was authenticated
#   %t: Date and time, in Common Log Format format
#   %{X-Forwarded-Host}: for X-Forwarded-Host incoming headers
#   %r: First line of the request, generally something like this: "GET /index.jsf HTTP/1.1"
#   %s: HTTP status code of the response
#   %b: Bytes sent, excluding HTTP headers, or '-' if no bytes were sent
#
# Example for jws
#   <Valve className="org.apache.catalina.valves.AccessLogValve" directory="/proc/self/fd"
#     prefix="1" suffix="" rotatable="false" requestAttributesEnabled="true"
#     pattern="%h %l %u %t %{X-Forwarded-Host}i &quot;%r&quot; %s %b" />"
#
# This script will be executed during container startup
function configure_access_log_valve() {

    JWS7_8_VALVE="<Valve className=\"org.apache.catalina.valves.AccessLogValve\" directory=\"/proc/self/fd\"\n       \
    prefix=\"1\" suffix=\"\" rotatable=\"false\" requestAttributesEnabled=\"true\"\n       \
    pattern=\"%h %l %u %t %{X-Forwarded-Host}i \&quot;%r\&quot; %s %b\" />"

    if [ "${ENABLE_ACCESS_LOG^^}" == "TRUE" ]; then
        log_info "Configuring Access Log Valve."
        sed -i "s|<!-- ##ACCESS_LOG_VALVE## -->|${JWS7_8_VALVE}|" $JWS_HOME/conf/server.xml
    else
        log_info "Access log is disabled, ignoring configuration."
    fi
}
