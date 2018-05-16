# Access Log Valve configuration script
# Supports:
#   eap6
#   eap7.x
# Usage:
#   it is disabled by default, to disable it set the following variable to true:
#   ENABLE_ACCESS_LOG
#
# Default pattern used across all products:
#   %h %l %u %t %{X-Forwarded-Host}i "%r" %s %b
#          eap7 %{i,X-Forwarded-Host}
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
# Example of configuration that will be added on standalone-openshift.xml for eap6
#   <valve name="accessLog" module="org.jboss.openshift" class-name="org.jboss.openshift.valves.StdoutAccessLogValve">
#       <param param-name="pattern" param-value="%h %l %u %t %{X-Forwarded-Host}i "%r" %s %b" />
#   </valve>
#
# Example for eap7.x
#   <access-log use-server-log="true" pattern="%h %l %u %t %{i,X-Forwarded-Host} "%r" %s %b"/>
#
# This script will be executed during container startup

source $JBOSS_HOME/bin/launch/logging.sh

function configure() {
  configure_access_log_valve
  configure_access_log_handler
}

function configure_access_log_valve() {
    EAP6_VALVE="<valve name=\"accessLog\" module=\"org.jboss.openshift\" class-name=\"org.jboss.openshift.valves.StdoutAccessLogValve\">\n              \
    <param param-name=\"pattern\" param-value=\"%h %l %u %t %{X-Forwarded-Host}i \&quot;%r\&quot; %s %b\" />\n        \
    </valve>"

    EAP7x_VALVE="<access-log use-server-log=\"true\" pattern=\"%h %l %u %t %{i,X-Forwarded-Host} \&quot;%r\&quot; %s %b\"/>"

    if [ "${ENABLE_ACCESS_LOG^^}" == "TRUE" ]; then
        log_info "Configuring Access Log Valve."
        if [[ "$JBOSS_EAP_VERSION" == "6.4"* ]]; then
            sed -i "s|<!-- ##ACCESS_LOG_VALVE## -->|${EAP6_VALVE}|" $CONFIG_FILE
        fi
        if [[ "$JBOSS_DATAGRID_VERSION" == "6.5"* ]]; then
            sed -i "s|<!-- ##ACCESS_LOG_VALVE## -->|${EAP6_VALVE}|" $CONFIG_FILE
        fi
        if [[ "$JBOSS_EAP_VERSION" == "7."* ]]; then
            sed -i "s|<!-- ##ACCESS_LOG_VALVE## -->|${EAP7x_VALVE}|" $CONFIG_FILE
        fi
    else
        log_info "Access log is disabled, ignoring configuration."
    fi
}

function version_compare () {
    [ "$1" = "`echo -e \"$1\n$2\" | sort -V | head -n1`" ] && echo "older" || echo "newer"
}

function configure_access_log_handler() {
  if [ "${ENABLE_ACCESS_LOG^^}" == "TRUE" ]; then
    IS_NEWER_OR_EQUAL_TO_7_2=$(version_compare "$JBOSS_DATAGRID_VERSION" "7.2")
    # In this piece we check whether this is JDG and whether the version is >= 7.2
    if [ ! -z $JBOSS_DATAGRID_VERSION ] && [ $IS_NEWER_OR_EQUAL_TO_7_2 = "newer" ]; then
      sed -i "s|<!-- ##ACCESS_LOG_HANDLER## -->|<logger category=\"org.infinispan.REST_ACCESS_LOG\"><level name=\"TRACE\"/></logger>|" $CONFIG_FILE
    else
      sed -i "s|<!-- ##ACCESS_LOG_HANDLER## -->|<logger category=\"org.infinispan.rest.logging.RestAccessLoggingHandler\"><level name=\"TRACE\"/></logger>|" $CONFIG_FILE
    fi
  fi
}
