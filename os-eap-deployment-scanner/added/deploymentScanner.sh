#!/bin/sh

function configure() {
  configure_deployment_scanner
}

function configure_deployment_scanner() {
  if [[ -n "$JAVA_OPTS_APPEND" ]] && [[ $JAVA_OPTS_APPEND == *"Xdebug"* ]]; then
    sed -i "s|##AUTO_DEPLOY_EXPLODED##|true|" "$CONFIG_FILE"
  elif [ -n "$AUTO_DEPLOY_EXPLODED" ]; then
    sed -i "s|##AUTO_DEPLOY_EXPLODED##|$AUTO_DEPLOY_EXPLODED|" "$CONFIG_FILE"
  else
    sed -i "s|##AUTO_DEPLOY_EXPLODED##|false|" "$CONFIG_FILE"
  fi
}
