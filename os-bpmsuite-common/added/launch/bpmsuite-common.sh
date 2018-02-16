#!/bin/bash

source "${JBOSS_HOME}/bin/launch/launch-common.sh"
source /usr/local/s2i/scl-enable-maven
source $JBOSS_HOME/bin/launch/logging.sh

function prepareEnv() {
    # please keep these in alphabetical order
    unset KIE_ADMIN_PWD
    unset KIE_ADMIN_USER
    unset KIE_MBEANS
}

function configureEnv() {
    configure
}

function configure() {
    configure_admin_security
    configure_maven_settings
    configure_mbeans
}

function configure_admin_security() {
    local kieAdminUser=$(find_env "KIE_ADMIN_USER" "adminUser")
    local kieAdminPwd=$(find_env "KIE_ADMIN_PWD" "admin1!")
    ${JBOSS_HOME}/bin/add-user.sh -a --user "${kieAdminUser}" --password "${kieAdminPwd}" --role "kie-server,rest-all,admin,kiemgmt,Administrators"
    if [ "$?" -ne "0" ]; then
        log_error "Failed to create admin user \"${kieAdminUser}\""
        log_error "Exiting..."
        exit
    fi
}

function configure_maven_settings() {
    # env var used by KIE to first find and load global settings.xml
    local m2Home=$(mvn -v | grep -i 'maven home: ' | sed -E 's/^.{12}//')
    export M2_HOME="${m2Home}"
    # see scripts/os-bpmsuite-common/configure.sh
    # used by KIE to then override with custom settings.xml
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dkie.maven.settings.custom=${HOME}/.m2/settings.xml"
}

function configure_mbeans() {
    # should jmx mbeans be enabled? (true/false becomes enabled/disabled)
    if [ "x${KIE_MBEANS}" != "x" ]; then
        # if specified, respect value
        local kieMbeans=$(echo "${KIE_MBEANS}" | tr "[:upper:]" "[:lower:]")
        if [ "${kieMbeans}" = "true" ] || [ "${kieMbeans}" = "enabled" ]; then
            KIE_MBEANS="enabled"
        else
            KIE_MBEANS="disabled"
        fi
    else
        # otherwise, default to enabled
        KIE_MBEANS="enabled"
    fi
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dkie.mbeans=${KIE_MBEANS} -Dkie.scanner.mbeans=${KIE_MBEANS}"
}

