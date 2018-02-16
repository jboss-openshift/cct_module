#!/bin/bash

source "${JBOSS_HOME}/bin/launch/launch-common.sh"
source $JBOSS_HOME/bin/launch/logging.sh 

function prepareEnv() {
    unset MAVEN_REPO_HOST
    unset MAVEN_REPO_ID
    unset MAVEN_REPO_LAYOUT
    unset MAVEN_REPO_PASSPHRASE
    unset MAVEN_REPO_PASSWORD
    unset MAVEN_REPO_PATH
    unset MAVEN_REPO_PORT
    unset MAVEN_REPO_PRIVATE_KEY
    unset MAVEN_REPO_PROTOCOL
    unset MAVEN_REPO_RELEASES_ENABLED
    unset MAVEN_REPO_RELEASES_UPDATE_POLICY
    unset MAVEN_REPO_SERVICE
    unset MAVEN_REPO_SNAPSHOTS_ENABLED
    unset MAVEN_REPO_SNAPSHOTS_UPDATE_POLICY
    unset MAVEN_REPO_URL
    unset MAVEN_REPO_USERNAME
}

function configureEnv() {
    configure
}

function configure() {
    configure_maven_repos
}

function configure_maven_repos {
    local settings="${1-$HOME/.m2/settings.xml}"
    # single repo scenario: respect fully qualified url if specified, otherwise find and use service
    local single_repo_url="${MAVEN_REPO_URL}"
    if [ "${single_repo_url}" = "" ]; then
        local single_repo_service="${MAVEN_REPO_SERVICE}"
        single_repo_service=${single_repo_service^^}
        single_repo_service=${single_repo_service//-/_}
        # host
        local single_repo_host="${MAVEN_REPO_HOST}"
        if [ "${single_repo_host}" = "" ]; then
            single_repo_host=$(find_env "${single_repo_service}_SERVICE_HOST")
        fi
        if [ "${single_repo_host}" != "" ]; then
            # protocol
            local single_repo_protocol=$(find_env "MAVEN_REPO_PROTOCOL" "http")
            # port
            local single_repo_port="${MAVEN_REPO_PORT}"
            if [ "${single_repo_port}" = "" ]; then
                single_repo_port=$(find_env "${single_repo_service}_SERVICE_PORT" "8080")
            fi
            local single_repo_path="${MAVEN_REPO_PATH}"
            # strip leading slash if exists
            if [[ "${single_repo_path}" =~ ^/ ]]; then
                single_repo_path="${single_repo_path:1:${#single_repo_path}}"
            fi
            # url
            single_repo_url="${single_repo_protocol}://${single_repo_host}:${single_repo_port}/${single_repo_path}"
        fi
    fi
    if [ "${single_repo_url}" != "" ]; then
        local single_repo_id=$(find_env "MAVEN_REPO_ID" "repo-$(generate_random_id)")
        local single_repo_username=$(find_env "MAVEN_REPO_USERNAME")
        local single_repo_password=$(find_env "MAVEN_REPO_PASSWORD")
        local single_repo_private_key=$(find_env "MAVEN_REPO_PRIVATE_KEY")
        local single_repo_passphrase=$(find_env "MAVEN_REPO_PASSPHRASE")
        local single_repo_layout=$(find_env "MAVEN_REPO_LAYOUT" "default")
        local single_repo_releases_enabled=$(find_env "MAVEN_REPO_RELEASES_ENABLED" "true")
        local single_repo_releases_update_policy=$(find_env "MAVEN_REPO_RELEASES_UPDATE_POLICY" "always")
        local single_repo_snapshots_enabled=$(find_env "MAVEN_REPO_SNAPSHOTS_ENABLED" "true")
        local single_repo_snapshots_update_policy=$(find_env "MAVEN_REPO_SNAPSHOTS_UPDATE_POLICY" "always")
        add_maven_repo "${settings}" "${single_repo_id}" "${single_repo_url}" "${single_repo_layout}" "${single_repo_releases_enabled}" "${single_repo_releases_update_policy}" "${single_repo_snapshots_enabled}" "${single_repo_snapshots_update_policy}"
        add_maven_server "${settings}" "${single_repo_id}" "${single_repo_username}" "${single_repo_password}" "${single_repo_private_key}" "${single_repo_passphrase}"
    fi
    # multiple repos scenario: support multiple fully-qualified urls (can be used together with "single repo scenario" above)
    local multi_repo_counter=1
    IFS=',' read -a multi_repo_prefixes <<< ${MAVEN_REPOS}
    for multi_repo_prefix in ${multi_repo_prefixes[@]}; do
        multi_repo_prefix=${multi_repo_prefix^^}
        multi_repo_prefix=${multi_repo_prefix//-/_}
        local multi_repo_url=$(find_env "${multi_repo_prefix}_MAVEN_REPO_URL")
        if [ -z "${multi_repo_url}" ]; then
            log_warning "Variable \"${multi_repo_prefix}_MAVEN_REPO_URL\" not set. Skipping maven repo setup for the prefix \"${multi_repo_prefix}\"."
        else
            local multi_repo_id=$(find_env "${multi_repo_prefix}_MAVEN_REPO_ID" "repo${multi_repo_counter}-$(generate_random_id)")
            local multi_repo_username=$(find_env "${multi_repo_prefix}_MAVEN_REPO_USERNAME")
            local multi_repo_password=$(find_env "${multi_repo_prefix}_MAVEN_REPO_PASSWORD")
            local multi_repo_private_key=$(find_env "${multi_repo_prefix}_MAVEN_REPO_PRIVATE_KEY")
            local multi_repo_passphrase=$(find_env "${multi_repo_prefix}_MAVEN_REPO_PASSPHRASE")
            local multi_repo_layout=$(find_env "${multi_repo_prefix}_MAVEN_REPO_LAYOUT" "default")
            local multi_repo_releases_enabled=$(find_env "${multi_repo_prefix}_MAVEN_REPO_RELEASES_ENABLED" "true")
            local multi_repo_releases_update_policy=$(find_env "${multi_repo_prefix}_MAVEN_REPO_RELEASES_UPDATE_POLICY" "always")
            local multi_repo_snapshots_enabled=$(find_env "${multi_repo_prefix}_MAVEN_REPO_SNAPSHOTS_ENABLED" "true")
            local multi_repo_snapshots_update_policy=$(find_env "${multi_repo_prefix}_MAVEN_REPO_SNAPSHOTS_UPDATE_POLICY" "always")
            add_maven_repo "${settings}" "${multi_repo_id}" "${multi_repo_url}" "${multi_repo_layout}" "${multi_repo_releases_enabled}" "${multi_repo_releases_update_policy}" "${multi_repo_snapshots_enabled}" "${multi_repo_snapshots_update_policy}"
            add_maven_server "${settings}" "${multi_repo_id}" "${multi_repo_username}" "${multi_repo_password}" "${multi_repo_private_key}" "${multi_repo_passphrase}"
        fi
        multi_repo_counter=$((multi_repo_counter+1))
    done
}

function add_maven_repo() {
    local settings="${1}"
    local repo_id="${2}"
    local url="${3}"
    local layout="${4:-default}"
    local releases_enabled="${5:-true}"
    local releases_update_policy="${6:-always}"
    local snapshots_enabled="${7:-true}"
    local snapshots_update_policy="${8:-always}"

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
    local settings="${1}"
    local server_id="${2}"
    local username="${3}"
    local password="${4}"
    local private_key="${5}"
    local passphrase="${6}"
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
    if [ "${do_rewrite}" = "true"  ]; then
        sed -i "s|<!-- ### configured servers ### -->|${xml}|" "${settings}"
    fi
}

function generate_random_id() {
    cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1
}

