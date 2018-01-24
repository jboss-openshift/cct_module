#!/bin/bash

source "${JBOSS_HOME}/bin/launch/launch-common.sh"
source "${JBOSS_HOME}/bin/launch/login-modules-common.sh"
source "${JBOSS_HOME}/bin/launch/management-common.sh"

function prepareEnv() {
    # please keep these in alphabetical order
    unset KIE_SERVER_CONTROLLER_HOST
    unset KIE_SERVER_CONTROLLER_PORT
    unset KIE_SERVER_CONTROLLER_PROTOCOL
    unset KIE_SERVER_CONTROLLER_PWD
    unset KIE_SERVER_CONTROLLER_SERVICE
    unset KIE_SERVER_CONTROLLER_TOKEN
    unset KIE_SERVER_CONTROLLER_USER
    unset KIE_SERVER_PWD
    unset KIE_SERVER_TOKEN
    unset KIE_SERVER_USER
}

function configureEnv() {
    configure
}

function configure() {
    configure_metaspace
    configure_controller_security
    configure_controller_access
    configure_server_access
    configure_guvnor_settings
    configure_misc_security
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

# here in case the controller is separate from business central
function configure_controller_access {
    # We will only support one controller, whether running by itself or in business central.
    local controllerService="${KIE_SERVER_CONTROLLER_SERVICE}"
    controllerService=${controllerService^^}
    controllerService=${controllerService//-/_}
    # host
    local kieServerControllerHost="${KIE_SERVER_CONTROLLER_HOST}"
    if [ "${kieServerControllerHost}" = "" ]; then
        kieServerControllerHost=$(find_env "${controllerService}_SERVICE_HOST")
    fi
    if [ "${kieServerControllerHost}" != "" ]; then
        # protocol
        local kieServerControllerProtocol=$(find_env "KIE_SERVER_CONTROLLER_PROTOCOL" "http")
        # port
        local kieServerControllerPort="${KIE_SERVER_CONTROLLER_PORT}"
        if [ "${kieServerControllerPort}" = "" ]; then
            kieServerControllerPort=$(find_env "${controllerService}_SERVICE_PORT" "8080")
        fi
        # path
        local kieServerControllerPath="rest/controller"
        if [ "${kieServerControllerProtocol}" = "ws" ]; then
            kieServerControllerPath="websocket/controller"
        fi
        # url
        local kieServerControllerUrl="${kieServerControllerProtocol}://${kieServerControllerHost}:${kieServerControllerPort}/${kieServerControllerPath}"
        JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.controller=${kieServerControllerUrl}"
        # user/pwd
        local kieServerControllerUser=$(find_env "KIE_SERVER_CONTROLLER_USER" "controllerUser")
        local kieServerControllerPwd=$(find_env "KIE_SERVER_CONTROLLER_PWD" "controller1!")
        JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.controller.user=${kieServerControllerUser}"
        JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.controller.pwd=${kieServerControllerPwd}"
        # token
        if [ "${KIE_SERVER_CONTROLLER_TOKEN}" != "" ]; then
            JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.controller.token=${KIE_SERVER_CONTROLLER_TOKEN}"
        fi
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

function configure_guvnor_settings() {
    # see scripts/os-bpmsuite-common/configure.sh
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.jbpm.designer.perspective=full -Ddesignerdataobjects=false"
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.demo=false -Dorg.kie.example=false"
    local bpmsuiteDataDir="${JBOSS_HOME}/standalone/data/bpmsuite"
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.guvnor.m2repo.dir=${bpmsuiteDataDir}/maven-repository"
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.uberfire.metadata.index.dir=${bpmsuiteDataDir}"
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.uberfire.nio.git.dir=${bpmsuiteDataDir}"
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.uberfire.nio.git.ssh.cert.dir=${bpmsuiteDataDir}"
}

function configure_misc_security() {
    add_management_interface_realm
    # KieLoginModule breaks Decision Central; it needs to be added only for Business Central & Business Central Monitoring
    if [ "$JBOSS_PRODUCT" = "bpmsuite-businesscentral" ] || [ "$JBOSS_PRODUCT" = "bpmsuite-businesscentral-monitoring" ]; then
        configure_login_modules "org.kie.security.jaas.KieLoginModule" "optional" "deployment.ROOT.war"
    fi
}

# Set the max metaspace size only for the workbench
# It avoid to set the max metaspace size if there is a multiple container instantiation.
function configure_metaspace() {
    export GC_MAX_METASPACE_SIZE=${WORKBENCH_MAX_METASPACE_SIZE:-1024}
}