
function prepareEnv() {
  unset JBOSS_MODULES_SYSTEM_PKGS_APPEND
}

function configure() {
  configure_jboss_modules_system_pkgs
}

function configure_jboss_modules_system_pkgs() {
  JBOSS_MODULES_SYSTEM_PKGS="org.jboss.logmanager,jdk.nashorn.api,com.sun.crypto.provider"

  if [ -n "$JBOSS_MODULES_SYSTEM_PKGS_APPEND" ]; then
    JBOSS_MODULES_SYSTEM_PKGS="$JBOSS_MODULES_SYSTEM_PKGS,$JBOSS_MODULES_SYSTEM_PKGS_APPEND"
  fi
}
