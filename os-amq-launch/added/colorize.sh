BLACK='\033[0;30m'
RED='\033[0;31m'
YELLOW='\033[0;33m'

function echo_warning() {
  local message="${1}"

  echo >&2 -e "${YELLOW}${message}${BLACK}"
}

function echo_error() {
  local message="${1}"

  echo >&2 -e "${RED}${message}${BLACK}"
}

function echo_info() {
  local message="${1}"

  echo >&2 -e "${message}"
}

