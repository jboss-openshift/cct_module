if [ -z "$(type -t log_warning)" ]; then

BLACK='\033[0;30m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
DEFAULT='\033[0m'

function log_warning() {
  local message="${1}"

  echo >&2 -e "${YELLOW}WARN ${message}${DEFAULT}"
}

function log_error() {
  local message="${1}"

  echo >&2 -e "${RED}ERROR ${message}${DEFAULT}"
}

function log_info() {
  local message="${1}"

  echo >&2 -e "INFO ${message}"
}

LOGGING_SCRIPT_DEBUG="${LOGGING_SCRIPT_DEBUG:-${SCRIPT_DEBUG}}"
export SCRIPT_DEBUG="$LOGGING_SCRIPT_DEBUG"  # setup for backward compatibility

if [ "${LOGGING_SCRIPT_DEBUG}" = "true" ] ; then
    set -x
    log_info "Script debugging is enabled, allowing bash commands and their arguments to be printed as they are executed"
fi

fi