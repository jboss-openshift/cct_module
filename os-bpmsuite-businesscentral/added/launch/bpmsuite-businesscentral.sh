#!/bin/bash

source "${JBOSS_HOME}/bin/launch/launch-common.sh"
source "${JBOSS_HOME}/bin/launch/login-modules-common.sh"
source "${JBOSS_HOME}/bin/launch/management-common.sh"

function prepareEnv() {
    unset KIE_SERVER_CONTROLLER_PWD
    unset KIE_SERVER_CONTROLLER_USER
    unset KIE_SERVER_PWD
    unset KIE_SERVER_USER
}

function configureEnv() {
    configure
}

function configure() {
    configure_controller_security
    configure_guvnor_settings
    configure_misc_security
    configure_server_security
}

function configure_controller_security() {
    local kieServerControllerUser=$(find_env "KIE_SERVER_CONTROLLER_USER" "controllerUser")
    local kieServerControllerPwd=$(find_env "KIE_SERVER_CONTROLLER_PWD" "controller1!")
    ${JBOSS_HOME}/bin/add-user.sh -a --user "${kieServerControllerUser}" --password "${kieServerControllerPwd}" --role "kie-server,rest-all,admin,kiemgmt"
    if [ "$?" -ne "0" ]; then
        echo "Failed to create controller user \"${kieServerControllerUser}\""
        echo "Exiting..."
        exit
    fi
}

function configure_guvnor_settings() {
    # see scripts/os-bpmsuite-common/configure.sh
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.guvnor.m2repo.dir=${HOME}/.m2/repository"
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.jbpm.designer.perspective=full -Ddesignerdataobjects=false"
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.demo=false -Dorg.kie.example=false"
}

function configure_misc_security() {
    add_management_interface_realm
    configure_login_modules "org.kie.security.jaas.KieLoginModule" "optional" "deployment.business-central.war"
}

function configure_server_security() {
    local kieServerUser=$(find_env "KIE_SERVER_USER" "executionUser")
    local kieServerPwd=$(find_env "KIE_SERVER_PWD" "execution1!")
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.user=${kieServerUser}"
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.pwd=${kieServerPwd}"
}

