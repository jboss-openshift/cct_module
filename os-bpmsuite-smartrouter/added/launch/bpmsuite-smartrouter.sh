#!/bin/bash

source "/opt/${JBOSS_PRODUCT}/launch/launch-common.sh"

function prepareEnv() {
    # please keep these in alphabetical order
    unset KIE_SERVER_CONTROLLER_HOST
    unset KIE_SERVER_CONTROLLER_PORT
    unset KIE_SERVER_CONTROLLER_PROTOCOL
    unset KIE_SERVER_CONTROLLER_PWD
    unset KIE_SERVER_CONTROLLER_SERVICE
    unset KIE_SERVER_CONTROLLER_TOKEN
    unset KIE_SERVER_CONTROLLER_USER
    unset KIE_SERVER_ROUTER_HOST
    unset KIE_SERVER_ROUTER_ID
    unset KIE_SERVER_ROUTER_NAME
    unset KIE_SERVER_ROUTER_PORT
    unset KIE_SERVER_ROUTER_PROTOCOL
    unset KIE_SERVER_ROUTER_URL_EXTERNAL
}

function configureEnv() {
    configure
}

function configure() {
    configure_router_state
    configure_router_location
    configure_controller_access
}

function configure_router_state() {
    # Need to replace whitespaces with something different from space or escaped space (\ ) characters
    local kieServerRouterId="${KIE_SERVER_ROUTER_ID// /_}"
    if [ "${kieServerRouterId}" = "" ]; then
        if [ "x${HOSTNAME}" != "x" ]; then
            # chop off trailing unique "dash number" so all servers use the same template
            kieServerRouterId=$(echo "${HOSTNAME}" | sed -e 's/\(.*\)-.*/\1/')
        else
            kieServerRouterId="$(generate_random_id)"
        fi
    fi
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.router.id=${kieServerRouterId}"

    # Need to replace whitespaces with something different from space or escaped space (\ ) characters
    local kieServerRouterName="${KIE_SERVER_ROUTER_NAME// /_}"
    if [ "${kieServerRouterName}" = "" ]; then
        kieServerRouterName="${kieServerRouterId}"
    fi
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.router.name=${kieServerRouterName}"

    # see scripts/os-bpmsuite-smartrouter/configure.sh
    local kieServerRouterRepo="/opt/${JBOSS_PRODUCT}"
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.router.repo=${kieServerRouterRepo}"
}

function configure_router_location {
    # DeploymentConfig: spec/template/spec/containers/env
    # {
    #     "name": "KIE_SERVER_ROUTER_HOST",
    #     "valueFrom": {
    #         "fieldRef": {
    #             "fieldPath": "status.podIP"
    #         }
    #     }
    # },
    local kieServerRouterHost="${KIE_SERVER_ROUTER_HOST}"
    if [ "${kieServerRouterHost}" = "" ]; then
        kieServerRouterHost="${HOSTNAME}"
        if [ "${kieServerRouterHost}" = "" ]; then
            kieServerRouterHost="localhost"
        fi
    fi
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.router.host=${kieServerRouterHost}"

    local kieServerRouterPort="${KIE_SERVER_ROUTER_PORT}"
    if [ "${kieServerRouterPort}" = "" ]; then
        kieServerRouterPort="9000"
    fi
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.router.port=${kieServerRouterPort}"

    local kieServerRouterUrlExternal="${KIE_SERVER_ROUTER_URL_EXTERNAL}"
    if [ "${kieServerRouterUrlExternal}" = "" ]; then
        local kieServerRouterProtocol="${KIE_SERVER_ROUTER_PROTOCOL}"
        if [ "${kieServerRouterProtocol}" = "" ]; then
            kieServerRouterProtocol="http"
        fi
        kieServerRouterUrlExternal="${kieServerRouterProtocol}://${kieServerRouterHost}:${kieServerRouterPort}"
    fi
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.router.url.external=${kieServerRouterUrlExternal}"
}

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

function generate_random_id() {
    cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1
}
