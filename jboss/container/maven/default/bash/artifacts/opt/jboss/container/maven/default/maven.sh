# common shell routines for use with maven
source "$JBOSS_CONTAINER_UTIL_LOGGING_MODULE/logging.sh"
source "$JBOSS_CONTAINER_MAVEN_DEFAULT_MODULE/maven-repos.sh"

# default settings.xml file
__JBOSS_MAVEN_DEFAULT_SETTINGS_FILE="${HOME}/.m2/settings.xml"

# initialize maven
function maven_init() {
  maven_init_vars
  maven_init_settings
  maven_init_local_repo
}

# initialize maven variables
function maven_init_vars() {
  maven_init_var_MAVEN_LOCAL_REPO
  maven_init_var_MAVEN_SETTINGS_XML
  maven_init_var_MAVEN_OPTS
  maven_init_var_MAVEN_ARGS
  
  maven_init_backward_compatibility
}

# initialize old variables in case anybody is still using them
function maven_init_backward_compatibility() {
  export MAVEN_REPO_LOCAL="$MAVEN_LOCAL_REPO"
}

function maven_init_var_MAVEN_LOCAL_REPO() {
  MAVEN_LOCAL_REPO="${MAVEN_LOCAL_REPO:-${MAVEN_REPO_LOCAL:-${HOME}/.m2/repository}}"
}

function maven_init_var_MAVEN_SETTINGS_XML() {
  if [ -f "${MAVEN_SETTINGS_XML}" ]; then
    :
  elif [ -f "${HOME}/.m2/settings.xml" ]; then
    MAVEN_SETTINGS_XML="${HOME}/.m2/settings.xml"
  else
    MAVEN_SETTINGS_XML="${JBOSS_CONTAINER_MAVEN_DEFAULT_MODULE}/jboss-settings.xml"
  fi
}

function maven_init_var_MAVEN_OPTS() {
  export MAVEN_OPTS="${MAVEN_OPTS:-$(${JBOSS_CONTAINER_JAVA_JVM_MODULE}/java-default-options)}"
}

function maven_init_var_MAVEN_ARGS() {
  MAVEN_ARGS=${MAVEN_ARGS:--e -Popenshift -DskipTests -Dcom.redhat.xpaas.repo.redhatga -Dfabric8.skip=true}
  # Use maven batch mode (CLOUD-579)
  # Always force IPv4 (CLOUD-188)
  MAVEN_ARGS="$MAVEN_ARGS --batch-mode -Djava.net.preferIPv4Stack=true"
  # manually configure settings (to simplify using custom settings vs default)
  MAVEN_ARGS="$MAVEN_ARGS -s ${MAVEN_SETTINGS_XML}"
  # manually configure local repository (to simplify configuration of custom vs default)
  MAVEN_ARGS="$MAVEN_ARGS -Dmaven.repo.local=${MAVEN_LOCAL_REPO}"

  # Append user-supplied arguments (CLOUD-412)
  MAVEN_ARGS="$MAVEN_ARGS ${MAVEN_ARGS_APPEND}"
}

function maven_init_settings() {
  process_maven_settings_xml "${MAVEN_SETTINGS_XML}"
}

function maven_init_local_repo() {
  :
}

# perform a maven build
# $1 build directory; defaults to cwd
# $2 goals to execute; defaults to package
# e.g. cd $1; mvn $2
function maven_build() {
  local build_dir=${1:-$(cwd)}
  local goals=${2:-package}
  log_info "Performing Maven build in $build_dir"

  pushd $build_dir &> /dev/null

  log_info "Using MAVEN_OPTS ${MAVEN_OPTS}"
  log_info "Using $(mvn $MAVEN_ARGS --version)"
  log_info "Running 'mvn $MAVEN_ARGS $goals'"
  # Execute the actual build
  mvn $MAVEN_ARGS $goals
  
  popd &> /dev/null
  
}

# post build cleanup.  deletes local repository after a build, if MAVEN_CLEAR_REPO is set
function maven_cleanup() { 
  # Remove repo if desired
  if [ "${MAVEN_CLEAR_REPO,,}" == "true" -a -n "$(find ${MAVEN_LOCAL_REPO} -maxdepth 0 -type d ! -empty 2> /dev/null)" ]; then
    log_info "Clearing local maven repository at ${MAVEN_LOCAL_REPO}"
    rm -rf "${MAVEN_LOCAL_REPO}"
    if [ $? -ne 0 ]; then
      log_error "Cannot remove local Maven repository ${MAVEN_LOCAL_REPO}"
    fi
  fi
}

# apply environment to settings.xml file
function process_maven_settings_xml() {
  local settings="${1:-${__JBOSS_MAVEN_DEFAULT_SETTINGS_FILE}}"
  add_maven_proxy_settings "${settings}"
  add_maven_mirrors "${settings}"
  configure_maven_repos "${settings}"
}

# add proxy configuration to settings.xml
# internal function, use process_maven_settings_xml which applies all configuration
function add_maven_proxy_settings() {
  local httpsProxy="${https_proxy:-${HTTPS_PROXY}}"
  local httpProxy="${http_proxy:-${HTTP_PROXY}}"
  local settings="$1"

  if [ -n "${httpsProxy}" ] ; then
    source "$JBOSS_CONTAINER_JAVA_PROXY_MODULE"/parse-proxy-url.sh "${httpsProxy}" https 443
  else
    if [ -n "${httpProxy}" ] ; then
      source "$JBOSS_CONTAINER_JAVA_PROXY_MODULE"/parse-proxy-url.sh "${httpProxy}" http 80
    fi
  fi
  _add_maven_proxy "${settings}"
}

# insert settings for HTTP proxy into settings.xml if supplied as
# separate variables JAVA_PROXY_HOST, _PORT, _SCHEME, _USERNAME,
# _PASSWORD, _NONPROXYHOSTS
# internal function
function _add_maven_proxy() {
  local settings="${1:-${__JBOSS_MAVEN_DEFAULT_SETTINGS_FILE}}"
  if [ -n "$JAVA_PROXY_HOST" -a -n "$JAVA_PROXY_PORT" ]; then
    xml="<proxy>\
         <id>genproxy</id>\
         <active>true</active>\
         <protocol>${JAVA_PROXY_SCHEME:-http}</protocol>\
         <host>$JAVA_PROXY_HOST</host>\
         <port>$JAVA_PROXY_PORT</port>"
    if [ -n "$JAVA_PROXY_USERNAME" -a -n "$JAVA_PROXY_PASSWORD" ]; then
      xml="$xml\
         <username>$JAVA_PROXY_USERNAME</username>\
         <password>$JAVA_PROXY_PASSWORD</password>"
    fi
    source "$JBOSS_CONTAINER_JAVA_PROXY_MODULE"/translate-no-proxy.sh
    if [ -n "$JAVA_PROXY_NONPROXYHOSTS" ]; then
      xml="$xml\
         <nonProxyHosts>$JAVA_PROXY_NONPROXYHOSTS</nonProxyHosts>"
    fi
  xml="$xml\
       </proxy>"
    local sub="<!-- ### configured http proxy ### -->"
    sed -i "s^${sub}^${xml}^" "$settings"
  fi
}

function _maven_find_env() {
  local var=${!1}
  echo "${var:-$2}"
}

# insert settings for mirrors/repository managers into settings.xml if supplied
# internal function, use process_maven_settings_xml which applies all configuration
function add_maven_mirrors() {
  local settings="${1:-${__JBOSS_MAVEN_DEFAULT_SETTINGS_FILE}}"
  local counter=1

  # Be backwards compatible
  if [ -n "${MAVEN_MIRROR_URL}" ]; then
    local mirror_id=$(_maven_find_env "MAVEN_MIRROR_ID" "mirror.default")
    local mirror_of=$(_maven_find_env "MAVEN_MIRROR_OF" "external:*")

    _add_maven_mirror "${settings}" "${mirror_id}" "${MAVEN_MIRROR_URL}" "${mirror_of}"
  fi

  IFS=',' read -a maven_mirror_prefixes <<< ${MAVEN_MIRRORS}
  for maven_mirror_prefix in ${maven_mirror_prefixes[@]}; do
    local mirror_id=$(_maven_find_env "${maven_mirror_prefix}_MAVEN_MIRROR_ID" "mirror${counter}")
    local mirror_url=$(_maven_find_env "${maven_mirror_prefix}_MAVEN_MIRROR_URL")
    local mirror_of=$(_maven_find_env "${maven_mirror_prefix}_MAVEN_MIRROR_OF" "external:*")

    if [ -z "${mirror_url}" ]; then
      log_warning "Variable \"${maven_mirror_prefix}_MAVEN_MIRROR_URL\" not set. Skipping maven mirror setup for the prefix \"${maven_mirror_prefix}\"."
    else
      _add_maven_mirror "${settings}" "${mirror_id}" "${mirror_url}" "${mirror_of}"
    fi

    counter=$((counter+1))
  done
}

# private
function _add_maven_mirror() {
  local settings="${1}"
  local mirror_id="${2}"
  local mirror_url="${3}"
  local mirror_of="${4}"

  local xml="<mirror>\n\
      <id>${mirror_id}</id>\n\
      <url>${mirror_url}</url>\n\
      <mirrorOf>${mirror_of}</mirrorOf>\n\
    </mirror>\n\
    <!-- ### configured mirrors ### -->"

  sed -i "s|<!-- ### configured mirrors ### -->|$xml|" "${settings}"

}

# The following functions are deprecated and provided solely for backward compatibility
function configure_proxy() {
  add_maven_proxy_settings $@
}

function configure_mirrors() {
  add_maven_mirrors $@
}

# copy all artifacts of types, specified as the second up to n-th
# argument of the routine into the $DEPLOY_DIR directory
# Requires: source directory expressed in the form of absolute path!
function copy_artifacts() {
  local dir=$1
  local types=
  shift
  while [ $# -gt 0 ]; do
    types="$types;$1"
    shift
  done
  
  for d in $(echo $dir | tr "," "\n")
  do
    shift
    local regex="^\/"
    if [[ ! "$d" =~ $regex ]]; then
      log_error "$FUNCNAME: Absolute path required for source directory \"$d\"!"
      exit 1
    fi
    for t in $(echo $types | tr ";" "\n")
    do
      log_info "Copying all $t artifacts from $d directory into $DEPLOY_DIR for later deployment..."
      cp -rfv $d/*.$t $DEPLOY_DIR 2> /dev/null
    done
  done
}

# handle incremental builds. If we have been passed build artifacts, untar
# them over the supplied source.
function manage_incremental_build() {
    if [ -d /tmp/artifacts ]; then
        log_info "Expanding artifacts from incremental build..."
        ( cd /tmp/artifacts && tar cf - . ) | ( cd ${HOME} && tar xvf - )
        rm -rf /tmp/artifacts
    fi
}

# s2i 'save-artifacts' routine
function s2i_save_build_artifacts() {
    cd ${HOME}
    tar cf - .m2
}

# optionally clear the local maven repository after the build
function clear_maven_repository() {
    mcr=$(echo "${MAVEN_CLEAR_REPO}" | tr [:upper:] [:lower:])
    if [ "${mcr}" = "true" ]; then
        rm -rf ${HOME}/.m2/repository/*
    fi
}
