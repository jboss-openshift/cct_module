
function prepareEnv() {
  unset OPENSHIFT_KUBE_PING_NAMESPACE
  unset OPENSHIFT_KUBE_PING_LABELS
  unset JGROUPS_CLUSTER_PASSWORD
  unset NODE_NAME
}

function configure() {
  check_view_pods_permission
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
            echo "Service account has sufficient permissions to view pods in kubernetes (HTTP ${pods_code}). Clustering will be available."
        elif [ "${pods_code}" = "403" ]; then
            >&2 echo "WARNING: Service account has insufficient permissions to view pods in kubernetes (HTTP ${pods_code}). Clustering might be unavailable. Please refer to the documentation for configuration."
        else
            >&2 echo "WARNING: Service account unable to test permissions to view pods in kubernetes (HTTP ${pods_code}). Clustering might be unavailable. Please refer to the documentation for configuration."
        fi
    else
        >&2 echo "WARNING: Environment variable OPENSHIFT_KUBE_PING_NAMESPACE undefined. Clustering will be unavailable. Please refer to the documentation for configuration."
    fi
}

function configure_ha() {
  # Set HA args
  IP_ADDR=`hostname -i`
  JBOSS_HA_ARGS="-b ${IP_ADDR} -bprivate ${IP_ADDR}"
  if [ -n "${NODE_NAME}" ]; then
      JBOSS_NODE_NAME="${NODE_NAME}"
  elif [ -n "${container_uuid}" ]; then
      JBOSS_NODE_NAME="${container_uuid}"
  elif [ -n "${HOSTNAME}" ]; then
      JBOSS_NODE_NAME="${HOSTNAME}"
  fi
  if [ -n "${JBOSS_NODE_NAME}" ]; then
      # CLOUD-427: truncate to 23 characters max (from the end backwards)
      if [ ${#JBOSS_NODE_NAME} -gt 23 ]; then
          JBOSS_NODE_NAME=${JBOSS_NODE_NAME: -23}
      fi

      JBOSS_HA_ARGS="${JBOSS_HA_ARGS} -Djboss.node.name=${JBOSS_NODE_NAME}"
  fi

  if [ -z "${JGROUPS_CLUSTER_PASSWORD}" ]; then
      >&2 echo "WARNING: No password defined for JGroups cluster. AUTH protocol will be disabled. Please define JGROUPS_CLUSTER_PASSWORD."
      JGROUPS_AUTH="<!--WARNING: No password defined for JGroups cluster. AUTH protocol has been disabled. Please define JGROUPS_CLUSTER_PASSWORD. -->"
  else
    JGROUPS_AUTH="\n\
                <protocol type=\"AUTH\">\n\
                    <property name=\"auth_class\">org.jgroups.auth.MD5Token</property>\n\
                    <property name=\"token_hash\">SHA</property>\n\
                    <property name=\"auth_value\">$JGROUPS_CLUSTER_PASSWORD</property>\n\
                </protocol>\n"
  fi

  sed -i "s|<!-- ##JGROUPS_AUTH## -->|${JGROUPS_AUTH}|g" $CONFIG_FILE

}

