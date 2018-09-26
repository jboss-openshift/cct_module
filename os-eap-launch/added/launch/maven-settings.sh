#!/bin/bash

# source maven shell routines
source "$JBOSS_CONTAINER_MAVEN_DEFAULT_MODULE/maven.sh"

function prepareEnv() {
    # cleanup local repository
    unset MAVEN_LOCAL_REPO
    unset MAVEN_REPO_LOCAL

    # cleanup settings xml
    unset MAVEN_SETTINGS_XML

    # cleanup single mirror scenario
    unset MAVEN_MIRROR_ID
    unset MAVEN_MIRROR_OF
    unset MAVEN_MIRROR_URL

    # cleanup multiple mirrors scenario
    IFS=',' read -a multi_mirror_prefixes <<< ${MAVEN_MIRRORS}
    for multi_mirror_prefix in ${multi_mirror_prefixes[@]}; do
        unset ${multi_mirror_prefix}_MAVEN_MIRROR_ID
        unset ${multi_mirror_prefix}_MAVEN_MIRROR_OF
        unset ${multi_mirror_prefix}_MAVEN_MIRROR_URL
    done
    unset MAVEN_MIRRORS

    # cleanup single remote repository scenario
    unset MAVEN_REPO_ID
    unset MAVEN_REPO_NAME
    unset MAVEN_REPO_LAYOUT

    unset MAVEN_REPO_RELEASES_ENABLED
    unset MAVEN_REPO_RELEASES_UPDATE_POLICY
    unset MAVEN_REPO_RELEASES_CHECKSUM_POLICY

    unset MAVEN_REPO_SNAPSHOTS_ENABLED
    unset MAVEN_REPO_SNAPSHOTS_UPDATE_POLICY
    unset MAVEN_REPO_SNAPSHOTS_CHECKSUM_POLICY

    unset MAVEN_REPO_USERNAME
    unset MAVEN_REPO_PASSWORD
    unset MAVEN_REPO_PRIVATE_KEY
    unset MAVEN_REPO_PASSPHRASE
    unset MAVEN_REPO_FILE_PERMISSIONS
    unset MAVEN_REPO_DIRECTORY_PERMISSIONS

    unset MAVEN_REPO_URL
    unset MAVEN_REPO_PROTOCOL
    unset MAVEN_REPO_HOST
    unset MAVEN_REPO_PORT
    unset MAVEN_REPO_PATH
    unset MAVEN_REPO_SERVICE

    # cleanup multiple remote repositories scenario
    IFS=',' read -a multi_repo_prefixes <<< ${MAVEN_REPOS}
    for multi_repo_prefix in ${multi_repo_prefixes[@]}; do
        unset ${multi_repo_prefix}_MAVEN_REPO_ID
        unset ${multi_repo_prefix}_MAVEN_REPO_NAME
        unset ${multi_repo_prefix}_MAVEN_REPO_LAYOUT

        unset ${multi_repo_prefix}_MAVEN_REPO_RELEASES_ENABLED
        unset ${multi_repo_prefix}_MAVEN_REPO_RELEASES_UPDATE_POLICY
        unset ${multi_repo_prefix}_MAVEN_REPO_RELEASES_CHECKSUM_POLICY

        unset ${multi_repo_prefix}_MAVEN_REPO_SNAPSHOTS_ENABLED
        unset ${multi_repo_prefix}_MAVEN_REPO_SNAPSHOTS_UPDATE_POLICY
        unset ${multi_repo_prefix}_MAVEN_REPO_SNAPSHOTS_CHECKSUM_POLICY

        unset ${multi_repo_prefix}_MAVEN_REPO_USERNAME
        unset ${multi_repo_prefix}_MAVEN_REPO_PASSWORD
        unset ${multi_repo_prefix}_MAVEN_REPO_PRIVATE_KEY
        unset ${multi_repo_prefix}_MAVEN_REPO_PASSPHRASE
        unset ${multi_repo_prefix}_MAVEN_REPO_FILE_PERMISSIONS
        unset ${multi_repo_prefix}_MAVEN_REPO_DIRECTORY_PERMISSIONS

        unset ${multi_repo_prefix}_MAVEN_REPO_URL
        unset ${multi_repo_prefix}_MAVEN_REPO_PROTOCOL
        unset ${multi_repo_prefix}_MAVEN_REPO_HOST
        unset ${multi_repo_prefix}_MAVEN_REPO_PORT
        unset ${multi_repo_prefix}_MAVEN_REPO_PATH
        unset ${multi_repo_prefix}_MAVEN_REPO_SERVICE
    done
    unset MAVEN_REPOS
}

function configureEnv() {
    configure
}

function configure() {
    maven_init_var_MAVEN_LOCAL_REPO
    maven_init_var_MAVEN_SETTINGS_XML
    maven_init_settings
}
