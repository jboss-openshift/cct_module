#!/bin/bash

# This should be moved to a common module
# source $JBOSS_HOME/bin/launch/launch-common.sh
source "$JBOSS_CONTAINER_UTIL_LOGGING_MODULE/logging.sh"

function prepareEnv() {
    unset MAVEN_REPO_ID
    unset MAVEN_REPO_URL

    IFS=',' read -a multi_repo_prefixes <<< ${MAVEN_REPOS}
    for multi_repo_prefix in ${multi_repo_prefixes[@]}; do
        unset ${multi_repo_prefix}_MAVEN_REPO_HOST
        unset ${multi_repo_prefix}_MAVEN_REPO_ID
        unset ${multi_repo_prefix}_MAVEN_REPO_LAYOUT
        unset ${multi_repo_prefix}_MAVEN_REPO_LOCAL
        unset ${multi_repo_prefix}_MAVEN_REPO_PASSPHRASE
        unset ${multi_repo_prefix}_MAVEN_REPO_PASSWORD
        unset ${multi_repo_prefix}_MAVEN_REPO_PATH
        unset ${multi_repo_prefix}_MAVEN_REPO_PORT
        unset ${multi_repo_prefix}_MAVEN_REPO_PRIVATE_KEY
        unset ${multi_repo_prefix}_MAVEN_REPO_PROTOCOL
        unset ${multi_repo_prefix}_MAVEN_REPO_RELEASES_ENABLED
        unset ${multi_repo_prefix}_MAVEN_REPO_RELEASES_UPDATE_POLICY
        unset ${multi_repo_prefix}_MAVEN_REPO_SERVICE
        unset ${multi_repo_prefix}_MAVEN_REPO_SNAPSHOTS_ENABLED
        unset ${multi_repo_prefix}_MAVEN_REPO_SNAPSHOTS_UPDATE_POLICY
        unset ${multi_repo_prefix}_MAVEN_REPO_URL
        unset ${multi_repo_prefix}_MAVEN_REPO_USERNAME
    done
    
    unset MAVEN_REPOS
}

function configureEnv() {
    configure
}

function configure() {
    configure_maven_repos
}

function configure_maven_repo() {
    local settings=$1
    local repo_url=$2
    local repo_id=$3
    if [[ -z $4 ]]; then
      local prefix="MAVEN"
    else
      local prefix="${4}_MAVEN"
    fi

    if [[ -z ${repo_url} ]]; then
        local repo_service=$(_find_prefixed_env "${prefix}" "REPO_SERVICE")
        # host
        local repo_host=$(_find_prefixed_env "${prefix}" "REPO_HOST")
        if [[ -z ${repo_host} ]]; then
            repo_host=$(_find_prefixed_env "${repo_service}" "SERVICE_HOST")
        fi
        if [[ ! -z ${repo_host} ]]; then
            # protocol
            local repo_protocol=$(_find_prefixed_env "${prefix}" "REPO_PROTOCOL" "http")
            # port
            local repo_port=$(_find_prefixed_env "${prefix}" "REPO_PORT")
            if [ "${repo_port}" = "" ]; then
                repo_port=$(_find_prefixed_env "${repo_service}" "SERVICE_PORT" "8080")
            fi
            local repo_path=$(_find_prefixed_env "${prefix}" "REPO_PATH")
            # strip leading slash if exists
            if [[ "${repo_path}" =~ ^/ ]]; then
                repo_path="${repo_path:1:${#repo_path}}"
            fi
            # url
            repo_url="${repo_protocol}://${repo_host}:${repo_port}/${repo_path}"
        fi
    fi
    if [[ ! -z ${repo_url} ]]; then
        add_maven_repo "${settings}" "${repo_id}" "${repo_url}" "${prefix}_MAVEN"
        add_maven_server "${settings}" "${repo_id}" "${prefix}"
    else
        log_warning "Variable \"${prefix}_REPO_URL\" not set. Skipping maven repo setup for the prefix \"${prefix}\"."
    fi
}

function configure_maven_repos() {
    local settings="${1-$HOME/.m2/settings.xml}"
    local local_repo_path="${MAVEN_LOCAL_REPO}"
    if [ "${local_repo_path}" != "" ]; then
        set_local_repo_path "${settings}" "${local_repo_path}"
    fi
    # single repo scenario: respect fully qualified url if specified, otherwise find and use service
    local single_repo_url="${MAVEN_REPO_URL}"
    if [ -n "$single_repo_url" ]; then
      local single_repo_id=$(_find_env "MAVEN_REPO_ID" "repo-$(generate_random_id)")
      configure_maven_repo $settings "$single_repo_url" "$single_repo_id"
    fi

    # multiple repos scenario: respect fully qualified url(s) if specified, otherwise find and use service(s); can be used together with "single repo scenario" above
    local multi_repo_counter=1
    IFS=',' read -a multi_repo_prefixes <<< ${MAVEN_REPOS}
    for multi_repo_prefix in ${multi_repo_prefixes[@]}; do
        local multi_repo_url=$(_find_prefixed_env "${multi_repo_prefix}" "MAVEN_REPO_URL")
        local multi_repo_id=$(_find_prefixed_env "${multi_repo_prefix}" "MAVEN_REPO_ID" "repo${multi_repo_counter}-$(generate_random_id)")
        configure_maven_repo $settings "$multi_repo_url" "$multi_repo_id" $multi_repo_prefix
        multi_repo_counter=$((multi_repo_counter+1))
    done
}

function add_maven_repo() {
    local settings=$1
    local repo_id=$2
    local url=$3
    local prefix=$4

    local layout=$(_find_prefixed_env "${prefix}" "REPO_LAYOUT" "default")
    local releases_enabled=$(_find_prefixed_env "${prefix}" "REPO_RELEASES_ENABLED" true)
    local releases_update_policy=$(_find_prefixed_env "${prefix}" "REPO_RELEASES_UPDATE_POLICY" "always")
    local snapshots_enabled=$(_find_prefixed_env "${prefix}" "REPO_SNAPSHOTS_ENABLED" true)
    local snapshots_update_policy=$(_find_prefixed_env "${prefix}" "REPO_SNAPSHOTS_UPDATE_POLICY" "always")

    # configure the repository in a profile
    local profile_id="${repo_id}-profile"
    local xml="\n\
    <profile>\n\
      <id>${profile_id}</id>\n\
      <repositories>\n\
        <repository>\n\
          <id>${repo_id}</id>\n\
          <url>${url}</url>\n\
          <layout>${layout}</layout>\n\
          <releases>\n\
            <enabled>${releases_enabled}</enabled>\n\
            <updatePolicy>${releases_update_policy}</updatePolicy>\n\
          </releases>\n\
          <snapshots>\n\
            <enabled>${snapshots_enabled}</enabled>\n\
            <updatePolicy>${snapshots_update_policy}</updatePolicy>\n\
          </snapshots>\n\
        </repository>\n\
      </repositories>\n\
    </profile>\n\
    <!-- ### configured profiles ### -->"
    sed -i "s|<!-- ### configured profiles ### -->|${xml}|" "${settings}"

    # activate the configured profile
    xml="\n\
    <activeProfile>${profile_id}</activeProfile>\n\
    <!-- ### active profiles ### -->"
    sed -i "s|<!-- ### active profiles ### -->|${xml}|" "${settings}"
}

function add_maven_server() {
    local settings=$1
    local server_id=$2
    local prefix=$3

    local username=$(_find_prefixed_env "$prefix" REPO_USERNAME)
    local password=$(_find_prefixed_env "$prefix" "REPO_PASSWORD")
    local private_key=$(_find_prefixed_env "$prefix" "REPO_PRIVATE_KEY")
    local passphrase=$(_find_prefixed_env "$prefix" "REPO_PASSPHRASE")

    local do_rewrite="false"
    local xml="\n\
    <server>\n\
      <id>${server_id}</id>"
    if [ "${private_key}" != "" -a "${passphrase}" != "" ]; then
        xml="${xml}\n\
      <privateKey>${private_key}</privateKey>\n\
      <passphrase><![CDATA[${passphrase}]]></passphrase>"
        do_rewrite="true"
    fi
    if [ "${username}" != "" -a "${password}" != "" ]; then
        xml="${xml}\n\
      <username>${username}</username>\n\
      <password><![CDATA[${password}]]></password>"
        do_rewrite="true"
    fi
    xml="${xml}\n\
    </server>\n\
    <!-- ### configured servers ### -->"
    sed -i "s|<!-- ### configured servers ### -->|${xml}|" "${settings}"

}

function generate_random_id() {
    cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1
}

function set_local_repo_path() {
    local settings="${1}"
    local local_path="${2}"
    local xml="\n\
    <localRepository>${local_path}</localRepository>"
    sed -i "s|<!-- ### configured local repository ### -->|${xml}|" "${settings}"
}

# common subroutines used in various places of the launch scripts

# Finds the environment variable  and returns its value if found.
# Otherwise returns the default value if provided.
#
# Arguments:
# $1 env variable name to check
# $2 default value if environment variable was not set
function _find_env() {
  var=${!1}
  echo "${var:-$2}"
}

# Finds the environment variable with the given prefix. If not found
# the default value will be returned. If no prefix is provided will rely on
# find_env
#
# Arguments
#  - $1 prefix. Transformed to uppercase and replace - by _
#  - $2 variable name. Prepended by "prefix_"
#  - $3 default value if the variable is not defined
function _find_prefixed_env() {
  local prefix=$1

  if [[ -z $prefix ]]; then
    _find_env $2 $3
  else
    prefix=${prefix^^} # uppercase
    prefix=${prefix//-/_} #replace - by _

    local var_name=$prefix"_"$2
    echo ${!var_name:-$3}
  fi
}
