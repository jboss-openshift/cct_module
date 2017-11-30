
function preConfigure() {
  # kieserver does not support clustering, so hard-code to legacy configuration.
  sed -i "s|<!-- ##JGROUPS_PING_PROTOCOL## -->|<protocol type=\"openshift.KUBE_PING\"/>|g" $CONFIG_FILE
}

