#!/bin/bash

source "${JBOSS_HOME}/bin/launch/launch-common.sh"

function prepareEnv() {
    # please keep these in alphabetical order
    unset KIE_SERVER_CONTROLLER_PWD
    unset KIE_SERVER_CONTROLLER_USER
    unset KIE_SERVER_PWD
    unset KIE_SERVER_TOKEN
    unset KIE_SERVER_USER
}

function configureEnv() {
    configure
}

function configure() {
    configure_controller_security
    configure_server_access
}

function configure_controller_security() {
    local kieServerControllerUser=$(find_env "KIE_SERVER_CONTROLLER_USER" "controllerUser")
    local kieServerControllerPwd=$(find_env "KIE_SERVER_CONTROLLER_PWD" "controller1!")
    ${JBOSS_HOME}/bin/add-user.sh -a --user "${kieServerControllerUser}" --password "${kieServerControllerPwd}" --role "kie-server,rest-all,guest"
    if [ "$?" -ne "0" ]; then
        echo "Failed to create controller user \"${kieServerControllerUser}\""
        echo "Exiting..."
        exit
    fi
}

function configure_server_access() {
    # user/pwd
    local kieServerUser=$(find_env "KIE_SERVER_USER" "executionUser")
    local kieServerPwd=$(find_env "KIE_SERVER_PWD" "execution1!")
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.user=${kieServerUser}"
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.pwd=${kieServerPwd}"
    # token
    if [ "${KIE_SERVER_TOKEN}" != "" ]; then
        JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.token=${KIE_SERVER_TOKEN}"
    fi
}
