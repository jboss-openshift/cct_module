function init_node_name() {
  if [ -z "${JBOSS_NODE_NAME}" ] ; then
    if [ -n "${NODE_NAME}" ]; then
      JBOSS_NODE_NAME="${NODE_NAME}"
    elif [ -n "${container_uuid}" ]; then
      JBOSS_NODE_NAME="${container_uuid}"
    else
      JBOSS_NODE_NAME="${HOSTNAME}"
    fi

    # CLOUD-427: truncate to 23 characters max (from the end backwards)
    if [ ${#JBOSS_NODE_NAME} -gt 23 ]; then
      JBOSS_NODE_NAME=${JBOSS_NODE_NAME: -23}
    fi
  fi
}
