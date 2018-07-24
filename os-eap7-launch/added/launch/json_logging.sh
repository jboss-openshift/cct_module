function configure() {
  configure_json_logging
}

function configure_json_logging() {
  sed -i "s|^.*\.module=org\.jboss\.logmanager\.ext$||" $LOGGING_FILE

  if [ "${ENABLE_JSON_LOGGING^^}" == "TRUE" ]; then
    sed -i 's|##CONSOLE-FORMATTER##|OPENSHIFT|' $CONFIG_FILE
    sed -i 's|##CONSOLE-FORMATTER##|OPENSHIFT|' $LOGGING_FILE
  else
    sed -i 's|##CONSOLE-FORMATTER##|COLOR-PATTERN|' $CONFIG_FILE
    sed -i 's|##CONSOLE-FORMATTER##|COLOR-PATTERN|' $LOGGING_FILE
  fi
}
