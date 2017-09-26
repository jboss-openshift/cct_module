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

function configure() {
  configure_access_log_valve
}

function configure_access_log_valve() {
    EAP6_VALVE="<valve><class-name>org.jboss.openshift.valves.StdoutAccessLogValve</class-name><module>org.jboss.openshift</module><param><param-name>pattern</param-name><param-value>%h %l %u %t %{X-Forwarded-Host}i \&quot;%r\&quot; %s %b</param-value></param></valve>"

    EAP7x_VALVE="<access-log use-server-log=\"true\" pattern=\"%h %l %u %t %{i,X-Forwarded-Host} \&quot;%r\&quot; %s %b\"/>"

    if [ "${ENABLE_ACCESS_LOG^^}" == "TRUE" ]; then
        echo "Configuring Access Log Valve."
        if [[ "$JBOSS_EAP_VERSION" == "6.4"* ]]; then
            sed -i "s|<!-- ##ACCESS_LOG_VALVE## -->|${EAP6_VALVE}|" ${JBOSS_HOME}/standalone/data/content/38/b8ef5d9c683c14b786ba47845934625a1c15d8/content
        fi
        if [[ "$JBOSS_EAP_VERSION" == "7."* ]]; then
            sed -i "s|<!-- ##ACCESS_LOG_VALVE## -->|${EAP7x_VALVE}|" $CONFIG_FILE
        fi
    else
        echo "Access log is disabled, ignoring configuration."
    fi
}
