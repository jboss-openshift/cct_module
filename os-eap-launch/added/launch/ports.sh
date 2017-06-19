# only processes a single environment as the placeholder is not preserved

function prepareEnv() {
  unset PORT_OFFSET
}

function configure() {
  configure_port_offset
}

function configureEnv() {
  configure
}

function configure_port_offset() {
  jgroups_encrypt=""

  if [ -n "${PORT_OFFSET}" ]; then
    sed -i "s|port-offset=\"0\"|port-offset=\"${PORT_OFFSET}\"|g" "$CONFIG_FILE"
  fi
}
