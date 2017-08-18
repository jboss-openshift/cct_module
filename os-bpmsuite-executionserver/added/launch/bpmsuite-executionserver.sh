#!/bin/bash

source "${JBOSS_HOME}/bin/launch/launch-common.sh"

function prepareEnv() {
    unset DROOLS_SERVER_FILTER_CLASSES
    unset KIE_SERVER_BYPASS_AUTH_USER
    unset KIE_SERVER_CONTROLLER_HOST
    unset KIE_SERVER_CONTROLLER_PORT
    unset KIE_SERVER_CONTROLLER_PROTOCOL
    unset KIE_SERVER_CONTROLLER_PWD
    unset KIE_SERVER_CONTROLLER_SERVICE
    unset KIE_SERVER_CONTROLLER_USER
    unset KIE_SERVER_DOMAIN
    unset KIE_SERVER_HOST
    unset KIE_SERVER_ID
    unset KIE_SERVER_PERSISTENCE_DIALECT
    unset KIE_SERVER_PERSISTENCE_DS
    unset KIE_SERVER_PERSISTENCE_TM
    unset KIE_SERVER_PERSISTENCE_SCHEMA
    unset KIE_SERVER_PORT
    unset KIE_SERVER_PROTOCOL
    unset KIE_SERVER_PWD
    unset KIE_SERVER_USER
    unset KIE_SERVER_ROUTER_PROTOCOL
    unset KIE_SERVER_ROUTER_SERVICE
    unset KIE_SERVER_ROUTER_HOST
    unset KIE_SERVER_ROUTER_PORT
    unset KIE_EXECUTOR_RETRIES
    unset JBPM_HT_CALLBACK_METHOD
    unset JBPM_HT_CALLBACK_CLASS
    unset JBPM_LOOP_LEVEL_DISABLED
}

function configureEnv() {
    configure
}

function configure() {
    configure_controller_access
    configure_router_access
    configure_drools_filter
    configure_server_id
    configure_server_location
    configure_server_persistence
    configure_server_repo
    configure_server_security
    configure_executor
    configure_jbpm
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
        # url
        local kieServerControllerUrl="${kieServerControllerProtocol}://${kieServerControllerHost}:${kieServerControllerPort}/rest/controller"
        JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.controller=${kieServerControllerUrl}"
        # user/pwd
        local kieServerControllerUser=$(find_env "KIE_SERVER_CONTROLLER_USER" "controllerUser")
        local kieServerControllerPwd=$(find_env "KIE_SERVER_CONTROLLER_PWD" "controller1!")
        JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.controller.user=${kieServerControllerUser}"
        JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.controller.pwd=${kieServerControllerPwd}"
    fi
}

function configure_router_access {
    local routerService="${KIE_SERVER_ROUTER_SERVICE}"
    routerService=${routerService^^}
    routerService=${routerService//-/_}
    # host
    local kieServerRouterHost="${KIE_SERVER_ROUTER_HOST}"
    if [ "${kieServerRouterHost}" = "" ]; then
        kieServerRouterHost=$(find_env "${routerService}_SERVICE_HOST")
    fi
    if [ "${kieServerRouterHost}" != "" ]; then
        # protocol
        local kieServerRouterProtocol=$(find_env "KIE_SERVER_ROUTER_PROTOCOL" "http")
        # port
        local kieServerRouterPort="${KIE_SERVER_ROUTER_PORT}"
        if [ "${kieServerRouterPort}" = "" ]; then
            kieServerRouterPort=$(find_env "${routerService}_SERVICE_PORT" "9000")
        fi
        # url
        local kieServerRouterUrl="${kieServerRouterProtocol}://${kieServerRouterHost}:${kieServerRouterPort}"
        JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.router=${kieServerRouterUrl}"
    fi
}

function configure_drools_filter() {
    # should the server filter classes?
    if [ "x${DROOLS_SERVER_FILTER_CLASSES}" != "x" ]; then
        # if specified, respect value
        local droolsServerFilterClasses=$(echo "${DROOLS_SERVER_FILTER_CLASSES}" | tr "[:upper:]" "[:lower:]")
        if [ "${droolsServerFilterClasses}" = "true" ]; then
            DROOLS_SERVER_FILTER_CLASSES="true"
        else
            DROOLS_SERVER_FILTER_CLASSES="false"
        fi
    else
        # otherwise, filter classes by default
        DROOLS_SERVER_FILTER_CLASSES="true"
    fi
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.drools.server.filter.classes=${DROOLS_SERVER_FILTER_CLASSES}"
}

function configure_server_id() {
    local kieServerId="${KIE_SERVER_ID}"
    if [ "${kieServerId}" = "" ]; then
        if [ "x${HOSTNAME}" != "x" ]; then
            # chop off trailing unique "dash number" so all servers use the same template
            kieServerId=$(echo "${HOSTNAME}" | sed -e 's/\(.*\)-.*/\1/')
        else
            kieServerId="$(generate_random_id)"
        fi
    fi
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.id=${kieServerId}"
}

function generate_random_id() {
    cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1
}

function configure_server_location() {
    # DeploymentConfig: spec/template/spec/containers/env
    # {
    #     "name": "KIE_SERVER_HOST",
    #     "valueFrom": {
    #         "fieldRef": {
    #             "fieldPath": "status.podIP"
    #         }
    #     }
    # },
    if [ "${KIE_SERVER_HOST}" = "" ]; then
        KIE_SERVER_HOST="${HOSTNAME}"
    fi
    if [ "${KIE_SERVER_HOST}" != "" ]; then
        if [ "${KIE_SERVER_PROTOCOL}" = "" ]; then
            KIE_SERVER_PROTOCOL="http"
        fi
        if [ "${KIE_SERVER_PORT}" = "" ]; then
            KIE_SERVER_PORT="8080"
        fi
        local kieServerUrl="${KIE_SERVER_PROTOCOL}://${KIE_SERVER_HOST}:${KIE_SERVER_PORT}/services/rest/server"
        JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.location=${kieServerUrl}"
    fi
}

function configure_server_persistence() {
    # dialect
    if [ "${KIE_SERVER_PERSISTENCE_DIALECT}" = "" ]; then
        KIE_SERVER_PERSISTENCE_DIALECT="org.hibernate.dialect.H2Dialect"
    fi
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.persistence.dialect=${KIE_SERVER_PERSISTENCE_DIALECT}"
    # datasource
    if [ "${KIE_SERVER_PERSISTENCE_DS}" = "" ]; then
        if [ "x${DB_JNDI}" != "x" ]; then
            KIE_SERVER_PERSISTENCE_DS="${DB_JNDI}"
        else
            KIE_SERVER_PERSISTENCE_DS="java:/jboss/datasources/ExampleDS"
        fi
    fi
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.persistence.ds=${KIE_SERVER_PERSISTENCE_DS}"
    # transactions
    if [ "${KIE_SERVER_PERSISTENCE_TM}" = "" ]; then
        #KIE_SERVER_PERSISTENCE_TM="org.hibernate.service.jta.platform.internal.JBossAppServerJtaPlatform"
        KIE_SERVER_PERSISTENCE_TM="org.hibernate.engine.transaction.jta.platform.internal.JBossAppServerJtaPlatform"
    fi
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.persistence.tm=${KIE_SERVER_PERSISTENCE_TM}"
    # default schema
    if [ "${KIE_SERVER_PERSISTENCE_SCHEMA}" != "" ]; then
        JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.persistence.schema=${KIE_SERVER_PERSISTENCE_SCHEMA}"
    fi
}

function configure_server_repo() {
    # see scripts/os-bpmsuite-executionserver/configure.sh
    local kieServerRepo="${HOME}/.kie/repository"
    #local kieServerRepo
    #if [ "${JBOSS_HOME}" = "" ]; then
    #        kieServerRepo="."
    #    else
    #        kieServerRepo="${JBOSS_HOME}"
    #    fi
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.repo=${kieServerRepo}"
}

function configure_server_security() {
    # execution user/pwd
    local kieServerUser=$(find_env "KIE_SERVER_USER" "executionUser")
    local kieServerPwd=$(find_env "KIE_SERVER_PWD" "execution1!")
    ${JBOSS_HOME}/bin/add-user.sh -a --user "${kieServerUser}" --password "${kieServerPwd}" --role "kie-server,rest-all,guest"
    if [ "$?" -ne "0" ]; then
        echo "Failed to create execution user \"${kieServerUser}\""
        echo "Exiting..."
        exit
    fi
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.user=${kieServerUser}"
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.pwd=${kieServerPwd}"
    # domain
    if [ "${KIE_SERVER_DOMAIN}" = "" ]; then
        KIE_SERVER_DOMAIN="other"
    fi
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.domain=${KIE_SERVER_DOMAIN}"
    # bypass auth user
    bypassAuthUser=$(echo "${KIE_SERVER_BYPASS_AUTH_USER}" | tr "[:upper:]" "[:lower:]")
    if [ "${bypassAuthUser}" = "true" ]; then
        KIE_SERVER_BYPASS_AUTH_USER="true"
    else
        KIE_SERVER_BYPASS_AUTH_USER="false"
    fi
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.bypass.auth.user=${KIE_SERVER_BYPASS_AUTH_USER}"
}

function configure_executor(){
    # kie executor number of retries
    if [ "${KIE_EXECUTOR_RETRIES}" != "" ]; then
        JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.executor.retry.count=${KIE_EXECUTOR_RETRIES}"
    fi
}

function configure_jbpm(){
    # jbpm capabilities configuration
    if [ "${JBPM_HT_CALLBACK_METHOD}" != "" ]; then
        JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.jbpm.ht.callback=${JBPM_HT_CALLBACK_METHOD}"
    fi
    if [ "${JBPM_HT_CALLBACK_CLASS}" != "" ]; then
        JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.jbpm.ht.custom.callback=${JBPM_HT_CALLBACK_CLASS}"
    fi
    if [ "${JBPM_LOOP_LEVEL_DISABLED}" != "" ]; then
        JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Djbpm.loop.level.disabled=${JBPM_LOOP_LEVEL_DISABLED}"
    fi
}
