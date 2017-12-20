#!/bin/bash

source "${JBOSS_HOME}/bin/launch/launch-common.sh"

function prepareEnv() {
    # please keep these in alphabetical order
    unset DROOLS_SERVER_FILTER_CLASSES
    unset JBPM_HT_CALLBACK_CLASS
    unset JBPM_HT_CALLBACK_METHOD
    unset JBPM_LOOP_LEVEL_DISABLED
    unset KIE_EXECUTOR_RETRIES
    unset KIE_SERVER_BYPASS_AUTH_USER
    unset KIE_SERVER_CONTAINER_DEPLOYMENT
    unset KIE_SERVER_CONTROLLER_HOST
    unset KIE_SERVER_CONTROLLER_PORT
    unset KIE_SERVER_CONTROLLER_PROTOCOL
    unset KIE_SERVER_CONTROLLER_PWD
    unset KIE_SERVER_CONTROLLER_SERVICE
    unset KIE_SERVER_CONTROLLER_TOKEN
    unset KIE_SERVER_CONTROLLER_USER
    unset KIE_SERVER_DOMAIN
    unset KIE_SERVER_HOST
    unset KIE_SERVER_ID
    unset KIE_SERVER_PERSISTENCE_DIALECT
    unset KIE_SERVER_PERSISTENCE_DS
    unset KIE_SERVER_PERSISTENCE_SCHEMA
    unset KIE_SERVER_PERSISTENCE_TM
    unset KIE_SERVER_PORT
    unset KIE_SERVER_PROTOCOL
    unset KIE_SERVER_PWD
    unset KIE_SERVER_ROUTER_HOST
    unset KIE_SERVER_ROUTER_PORT
    unset KIE_SERVER_ROUTER_PROTOCOL
    unset KIE_SERVER_ROUTER_SERVICE
    unset KIE_SERVER_SYNC_DEPLOY
    unset KIE_SERVER_TOKEN
    unset KIE_SERVER_USER
}

function configureEnv() {
    configure
}

function configure() {
    # configure_server_env always has to be first
    configure_server_env
    configure_controller_access
    configure_router_access
    configure_server_location
    configure_server_persistence
    configure_server_security
    configure_server_sync_deploy
    configure_drools
    configure_executor
    configure_kie_server_capabilities
    # configure_server_state always has to be last
    configure_server_state
}

function configure_server_env {
    # source the KIE config
    source $JBOSS_HOME/bin/launch/kieserver-env.sh
    # set the KIE environment
    setKieEnv
    # dump the KIE environment
    dumpKieEnv | tee ${JBOSS_HOME}/kieEnv
    # save the environment for use by the probes
    sed -ri "s/^([^:]+): *(.*)$/\1=\"\2\"/" ${JBOSS_HOME}/kieEnv
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

function configure_drools() {
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
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.jbpm.ejb.timer.tx=true"
}

function configure_server_security() {
    # user/pwd
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
    # token
    if [ "${KIE_SERVER_TOKEN}" != "" ]; then
        JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.token=${KIE_SERVER_TOKEN}"
    fi
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

function configure_server_sync_deploy(){
    # server sync deploy (true by default)
    local kieServerSyncDeploy="true";
    if [ "${KIE_SERVER_SYNC_DEPLOY// /}" != "" ]; then
        kieServerSyncDeploy=$(echo "${KIE_SERVER_SYNC_DEPLOY}" | tr "[:upper:]" "[:lower:]")
        if [ "${kieServerSyncDeploy}" != "true" ]; then
            kieServerSyncDeploy="false"
        fi
    fi
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.sync.deploy=${kieServerSyncDeploy}"
}

function configure_executor(){
    # kie executor number of retries
    if [ "${KIE_EXECUTOR_RETRIES}" != "" ]; then
        JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.executor.retry.count=${KIE_EXECUTOR_RETRIES}"
    fi
}

# Enable/disable the capabilities according with the product
function configure_kie_server_capabilities() {
    local kieServerCapabilities
    if [ "${JBOSS_PRODUCT}" = "bpmsuite-executionserver" ]; then
        if [ "${JBPM_HT_CALLBACK_METHOD}" != "" ]; then
            JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.jbpm.ht.callback=${JBPM_HT_CALLBACK_METHOD}"
        fi
        if [ "${JBPM_HT_CALLBACK_CLASS}" != "" ]; then
            JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.jbpm.ht.custom.callback=${JBPM_HT_CALLBACK_CLASS}"
        fi
        if [ "${JBPM_LOOP_LEVEL_DISABLED}" != "" ]; then
            JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Djbpm.loop.level.disabled=${JBPM_LOOP_LEVEL_DISABLED}"
        fi
    fi

    if [ "${JBOSS_PRODUCT}" = "rhdm-kieserver" ]; then
        kieServerCapabilities="${kieServerCapabilities} -Dorg.jbpm.server.ext.disabled=true -Dorg.jbpm.ui.server.ext.disabled=true -Dorg.jbpm.case.server.ext.disabled=true"
    fi

    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} ${kieServerCapabilities}"
}

function configure_server_state() {
    # Need to replace whitespaces with something different from space or escaped space (\ ) characters
    local kieServerId="${KIE_SERVER_ID// /_}"
    if [ "${kieServerId}" = "" ]; then
        if [ "x${HOSTNAME}" != "x" ]; then
            # chop off trailing unique "dash number" so all servers use the same template
            kieServerId=$(echo "${HOSTNAME}" | sed -e 's/\(.*\)-.*/\1/')
        else
            kieServerId="$(generate_random_id)"
        fi
    fi
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.id=${kieServerId}"

    # see scripts/os-bpmsuite-executionserver/configure.sh
    local kieServerRepo="${HOME}/.kie/repository"
    JBOSS_BPMSUITE_ARGS="${JBOSS_BPMSUITE_ARGS} -Dorg.kie.server.repo=${kieServerRepo}"

    # see above: configure_server_env / kieserver-env.sh / setKieEnv
    if [ "${KIE_SERVER_CONTAINER_DEPLOYMENT}" != "" ]; then
        # ensure all KIE dependencies are pulled for offline use (this duplicates s2i process; TODO: short-circuit if possible?)
        $JBOSS_HOME/bin/launch/kieserver-pull.sh
        ERR=$?
        if [ $ERR -ne 0 ]; then
            echo "Aborting due to error code $ERR from maven kjar dependency pull"
            exit $ERR
        fi

        # verify all KIE containers (this duplicates s2i process; TODO: short-circuit if possible?)
        $JBOSS_HOME/bin/launch/kieserver-verify.sh
        ERR=$?
        if [ $ERR -ne 0 ]; then
            echo "Aborting due to error code $ERR from maven kjar verification"
            exit $ERR
        fi

        # create a KIE server state file with all configured containers and properties
        local stateFileInit="org.kie.server.services.impl.storage.file.KieServerStateFileInit"
        echo "Attempting to generate kie server state file with 'java ${JBOSS_BPMSUITE_ARGS} ${stateFileInit}'"
        java ${JBOSS_BPMSUITE_ARGS} $(getKieJavaArgs) ${stateFileInit}
        ERR=$?
        if [ $ERR -ne 0 ]; then
            echo "Aborting due to error code $ERR from kie server state file init"
            exit $ERR
        fi
    fi
}

function generate_random_id() {
    cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1
}
