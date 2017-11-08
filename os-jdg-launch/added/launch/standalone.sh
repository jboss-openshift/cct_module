
function configure(){
  modify_standalone_sh
}

function modify_standalone_sh() {
  # Enhance standalone.sh to make remote JAVA debugging possible by specifying
  # DEBUG=true environment variable
  sed -i 's|DEBUG_MODE=false|DEBUG_MODE="${DEBUG:-false}"|' $JBOSS_HOME/bin/standalone.sh
  sed -i 's|DEBUG_PORT="8787"|DEBUG_PORT="${DEBUG_PORT:-8787}"|' $JBOSS_HOME/bin/standalone.sh
}

