source ${JBOSS_HOME}/bin/launch/openshift-node-name.sh
source $JBOSS_HOME/bin/launch/logging.sh

function prepareEnv() {
  unset OPENSHIFT_KUBE_PING_NAMESPACE
  unset OPENSHIFT_KUBE_PING_LABELS
  unset OPENSHIFT_DNS_PING_SERVICE_NAME
  unset OPENSHIFT_DNS_PING_SERVICE_PORT
  unset JGROUPS_CLUSTER_PASSWORD
  unset JGROUPS_PING_PROTOCOL
  unset NODE_NAME
}

function configure() {
  configure_ha
}

function check_view_pods_permission() {
    if [ -n "${OPENSHIFT_KUBE_PING_NAMESPACE+_}" ]; then
        local CA_CERT="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
        local CURL_CERT_OPTION
        pods_url="https://${KUBERNETES_SERVICE_HOST:-kubernetes.default.svc}:${KUBERNETES_SERVICE_PORT:-443}/api/${OPENSHIFT_KUBE_PING_API_VERSION:-v1}/namespaces/${OPENSHIFT_KUBE_PING_NAMESPACE}/pods"
        if [ -n "${OPENSHIFT_KUBE_PING_LABELS}" ]; then
            pods_labels="labels=${OPENSHIFT_KUBE_PING_LABELS}"
        else
            pods_labels=""
        fi

        # make sure the cert exists otherwise use insecure connection
        if [ -f "${CA_CERT}" ]; then
            CURL_CERT_OPTION="--cacert ${CA_CERT}"
        else
            CURL_CERT_OPTION="-k"
        fi
        pods_auth="Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
        pods_code=$(curl --noproxy "*" -s -o /dev/null -w "%{http_code}" -G --data-urlencode "${pods_labels}" ${CURL_CERT_OPTION} -H "${pods_auth}" ${pods_url})
        if [ "${pods_code}" = "200" ]; then
            log_info "Service account has sufficient permissions to view pods in kubernetes (HTTP ${pods_code}). Clustering will be available."
        elif [ "${pods_code}" = "403" ]; then
            log_warning "Service account has insufficient permissions to view pods in kubernetes (HTTP ${pods_code}). Clustering might be unavailable. Please refer to the documentation for configuration."
        else
            log_warning "Service account unable to test permissions to view pods in kubernetes (HTTP ${pods_code}). Clustering might be unavailable. Please refer to the documentation for configuration."
        fi
    else
        log_warning "Environment variable OPENSHIFT_KUBE_PING_NAMESPACE undefined. Clustering will be unavailable. Please refer to the documentation for configuration."
    fi
}

function validate_dns_ping_settings() {
  if [ "x$OPENSHIFT_DNS_PING_SERVICE_NAME" = "x" ]; then
    log_warning "Environment variable OPENSHIFT_DNS_PING_SERVICE_NAME undefined. Clustering will be unavailable. Please refer to the documentation for configuration."
  fi
}

function validate_ping_protocol() {
  if [ "$1" = "openshift.KUBE_PING" ]; then
    check_view_pods_permission
  elif [ "$1" = "openshift.DNS_PING" ]; then
    validate_dns_ping_settings
  else
    log_warning "Unknown protocol specified for JGroups discovery protocol: $1.  Expecting one of: openshift.KUBE_PING or openshift.DNS_PING."
  fi
}

function configure_ha() {
  # Set HA args
  IP_ADDR=`hostname -i`
  JBOSS_HA_ARGS="-b ${IP_ADDR} -bprivate ${IP_ADDR}"

  init_node_name

  JBOSS_HA_ARGS="${JBOSS_HA_ARGS} -Djboss.node.name=${JBOSS_NODE_NAME}"

  if [ -n "${JGROUPS_CLUSTER_PASSWORD}" ]; then
    JGROUPS_AUTH="\n\
                <protocol type=\"AUTH\">\n\
                    <property name=\"auth_class\">org.jgroups.auth.MD5Token</property>\n\
                    <property name=\"token_hash\">SHA</property>\n\
                    <property name=\"auth_value\">$JGROUPS_CLUSTER_PASSWORD</property>\n\
                </protocol>\n"
  fi

  local ping_protocol=${JGROUPS_PING_PROTOCOL:-openshift.KUBE_PING}
  local ping_protocol_element="<protocol type=\"${ping_protocol}\" socket-binding=\"jgroups-mping\"/>"
  validate_ping_protocol "${ping_protocol}" 

  sed -i "s|<!-- ##JGROUPS_AUTH## -->|${JGROUPS_AUTH}|g" $CONFIG_FILE
  log_info "Configuring JGroups discovery protocol to ${ping_protocol}"
  sed -i "s|<!-- ##JGROUPS_PING_PROTOCOL## -->|${ping_protocol_element}|g" $CONFIG_FILE

}

