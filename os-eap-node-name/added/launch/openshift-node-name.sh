function init_pod_name() {
  # when POD_NAME is non-zero length using that given name

  # docker sets up container_uuid
  [ -z "${POD_NAME}" ] && POD_NAME="${container_uuid}"
  # openshift sets up the node id as host name
  [ -z "${POD_NAME}" ] && POD_NAME="${HOSTNAME}"
  # TODO: fail when pod name is not set here?
}

function init_node_name() {
  if [ -z "${JBOSS_NODE_NAME}" ] ; then
    init_pod_name

    JBOSS_NODE_NAME="${POD_NAME}"

    # CLOUD-427: truncate to 23 characters max (from the end backwards)
    if [ ${#JBOSS_NODE_NAME} -gt 23 ]; then
      JBOSS_NODE_NAME=${JBOSS_NODE_NAME: -23}
    fi
  fi
}
