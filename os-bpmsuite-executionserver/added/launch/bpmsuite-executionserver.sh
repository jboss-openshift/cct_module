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
    unset KIE_SERVER_PORT
    unset KIE_SERVER_PROTOCOL
    unset KIE_SERVER_PWD
    unset KIE_SERVER_USER
}

function configureEnv() {
    configure
}

function configure() {
    configure_controller_access
    configure_drools_filter
    configure_server_id
    configure_server_location
    configure_server_persistence
    configure_server_repo
    configure_server_security
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

