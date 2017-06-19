#!/bin/sh
# if using vim, do ':set ft=zsh' for easier reading

. /opt/rh/rh-maven33/enable

function getJBossModulesOptsForKieUtilities() {
    local kieJarDir="${JBOSS_HOME}/standalone/deployments/kie-server.war/WEB-INF/lib"
    local kieClassPath="."
    for kieJar in ${kieJarDir}/*.jar; do
        kieClassPath="${kieClassPath}:${kieJar}"
    done
    echo "-dep javax.enterprise.api,javax.inject.api -cp ${kieClassPath}"
}

function getKieClassPath() {
    local kieJarDir="${JBOSS_HOME}/standalone/deployments/kie-server.war/WEB-INF/lib"
    local kieClassPath="."
    for kieJar in ${kieJarDir}/*.jar; do
        kieClassPath="${kieClassPath}:${kieJar}"
    done
    modJarDir="${JBOSS_HOME}/modules/system/layers/base"
    modJarPaths="javax/enterprise/api javax/inject/api"
    for modJarPath in ${modJarPaths} ; do
        if [ -e ${modJarDir}/.overlays/.overlays ] ; then
            while read overlay ; do
                if [ -d ${modJarDir}/.overlays/${overlay}/${modJarPath}/main ] ; then
                    for modJar in ${modJarDir}/.overlays/${overlay}/${modJarPath}/main/*.jar; do
                        kieClassPath="${kieClassPath}:${modJar}"
                    done
                fi
            done <${modJarDir}/.overlays/.overlays
        fi
        for modJar in ${modJarDir}/${modJarPath}/main/*.jar; do
            kieClassPath="${kieClassPath}:${modJar}"
        done
    done
    echo "${kieClassPath}"
}

function getKieDeploymentId() {
    # this function needs to stay in sync with the java logic in
    # org.openshift.kieserver.common.server.ServerConfig#createDeploymentId(containerAlias, releaseId):String
    kieContainerId="${1}"
    kjarReleaseId="${2}"
    if [ "${KIE_CONTAINER_REDIRECT_ENABLED}" = "true" ]; then
        coder="org.openshift.kieserver.common.coder.SumCoder MD5"
        coderIn="${kieContainerId}=${kjarReleaseId}"
        coderOut=$(java -jar $JBOSS_HOME/jboss-modules.jar -mp $JBOSS_HOME/modules $(getJBossModulesOptsForKieUtilities) ${coder} ${coderIn})
        # TODO: switch to this instead?
        # coderOut=($(echo -n "${coderIn}" | md5sum))
        echo "${coderOut}"
    else
        echo "${kieContainerId}"
    fi
}

function setKieContainerEnv() {
    # whether kie containers should be redirected (true by default)
    kieContainerRedirectEnabled="true"
    if [ "x${KIE_CONTAINER_REDIRECT_ENABLED}" != "x" ]; then
        # if specified, respect value
        kieContainerRedirectEnabled=$(echo "${KIE_CONTAINER_REDIRECT_ENABLED}" | tr [:upper:] [:lower:])
        if [ "${kieContainerRedirectEnabled=}" != "true" ]; then
            kieContainerRedirectEnabled="false"
        fi
    fi
    KIE_CONTAINER_REDIRECT_ENABLED="${kieContainerRedirectEnabled}"
    export KIE_CONTAINER_REDIRECT_ENABLED

    # discover kie container deployments
    kieContainerDeploymentsFile="${JBOSS_HOME}/kiecontainer-deployments.txt"
    if [ "x${KIE_CONTAINER_DEPLOYMENT_OVERRIDE}" != "x" ]; then
        echo "Encountered EnvVar KIE_CONTAINER_DEPLOYMENT_OVERRIDE: ${KIE_CONTAINER_DEPLOYMENT_OVERRIDE}"
        if [ "x${KIE_CONTAINER_DEPLOYMENT}" != "x" ]; then
            KIE_CONTAINER_DEPLOYMENT_ORIGINAL="${KIE_CONTAINER_DEPLOYMENT}"
            export KIE_CONTAINER_DEPLOYMENT_ORIGINAL
            echo "Setting EnvVar KIE_CONTAINER_DEPLOYMENT_ORIGINAL: ${KIE_CONTAINER_DEPLOYMENT_ORIGINAL}"
        fi
        KIE_CONTAINER_DEPLOYMENT="${KIE_CONTAINER_DEPLOYMENT_OVERRIDE}"
        export KIE_CONTAINER_DEPLOYMENT
        echo "Using overridden EnvVar KIE_CONTAINER_DEPLOYMENT: ${KIE_CONTAINER_DEPLOYMENT}"
    elif [ "x${KIE_CONTAINER_DEPLOYMENT}" != "x" ]; then
        echo "Using standard EnvVar KIE_CONTAINER_DEPLOYMENT: ${KIE_CONTAINER_DEPLOYMENT}"
    elif [ -e ${kieContainerDeploymentsFile} ]; then
        kieContainerDeployments=""
        while read kieContainerDeployment ; do
            # add pipe at end of each
            kieContainerDeployments="${kieContainerDeployments}${kieContainerDeployment}|"
        done <${kieContainerDeploymentsFile}
        # remove last unecessary pipe
        kieContainerDeployments=$(echo ${kieContainerDeployments} | sed "s/\(.*\)|/\1/")
        KIE_CONTAINER_DEPLOYMENT="${kieContainerDeployments}"
        export KIE_CONTAINER_DEPLOYMENT
        echo "Read ${kieContainerDeploymentsFile} into EnvVar KIE_CONTAINER_DEPLOYMENT: ${KIE_CONTAINER_DEPLOYMENT}"
    fi

    # process kie container deployments
    if [ "x${KIE_CONTAINER_DEPLOYMENT}" != "x" ]; then
        # kieContainerDeployment|kieContainerDeployment
        IFS='|' read -a kieContainerDeploymentArray <<< "${KIE_CONTAINER_DEPLOYMENT}"
        kieContainerDeploymentCount=${#kieContainerDeploymentArray[@]}
        KIE_CONTAINER_DEPLOYMENT_COUNT="${kieContainerDeploymentCount}"
        for (( i=0; i<${kieContainerDeploymentCount}; i++ )); do
            # containerId=releaseId
            kieContainerDeployment=${kieContainerDeploymentArray[i]}
            IFS='=' read -a kieContainerDefinitionArray <<< "${kieContainerDeployment}"
            kieContainerId=${kieContainerDefinitionArray[0]}
            kjarReleaseId=${kieContainerDefinitionArray[1]}
            kieDeploymentId=$(getKieDeploymentId ${kieContainerId} ${kjarReleaseId})
            eval "KIE_CONTAINER_ID_${i}=\"${kieDeploymentId}\""
            # groupId:artifactId:version
            IFS=':' read -a kjarReleaseIdArray <<< "${kjarReleaseId}"
            kjarGroupId=${kjarReleaseIdArray[0]}
            kjarArtifactId=${kjarReleaseIdArray[1]}
            kjarVersion=${kjarReleaseIdArray[2]}
            eval "KIE_CONTAINER_KJAR_GROUP_ID_${i}=${kjarGroupId}"
            eval "KIE_CONTAINER_KJAR_ARTIFACT_ID_${i}=${kjarArtifactId}"
            eval "KIE_CONTAINER_KJAR_VERSION_${i}=${kjarVersion}"
        done
    else
        KIE_CONTAINER_DEPLOYMENT_COUNT=0
        echo "Warning: EnvVar KIE_CONTAINER_DEPLOYMENT is missing."
        echo "Example: export KIE_CONTAINER_DEPLOYMENT='containerId=groupId:artifactId:version|c2=g2:a2:v2'"
    fi
}

function getKieContainerVal() {
    kieContainerVar="KIE_CONTAINER_${1}_${2}"
    eval "echo \$${kieContainerVar}"
}

function dumpKieContainerEnv() {
    echo "KIE_CONTAINER_DEPLOYMENT: ${KIE_CONTAINER_DEPLOYMENT}"
    echo "KIE_CONTAINER_DEPLOYMENT_ORIGINAL: ${KIE_CONTAINER_DEPLOYMENT_ORIGINAL}"
    echo "KIE_CONTAINER_DEPLOYMENT_OVERRIDE: ${KIE_CONTAINER_DEPLOYMENT_OVERRIDE}"
    echo "KIE_CONTAINER_DEPLOYMENT_COUNT: ${KIE_CONTAINER_DEPLOYMENT_COUNT}"
    for (( i=0; i<${KIE_CONTAINER_DEPLOYMENT_COUNT}; i++ )); do
        echo "KIE_CONTAINER_ID_${i}: $(getKieContainerVal ID ${i})"
        echo "KIE_CONTAINER_KJAR_GROUP_ID_${i}: $(getKieContainerVal KJAR_GROUP_ID ${i})"
        echo "KIE_CONTAINER_KJAR_ARTIFACT_ID_${i}: $(getKieContainerVal KJAR_ARTIFACT_ID ${i})"
        echo "KIE_CONTAINER_KJAR_VERSION_${i}: $(getKieContainerVal KJAR_VERSION ${i})"
    done
    echo "KIE_CONTAINER_REDIRECT_ENABLED: ${KIE_CONTAINER_REDIRECT_ENABLED}"
}

function setKieServerEnv() {
    # server id
    if [ "${KIE_SERVER_ID}" = "" ]; then
        KIE_SERVER_ID="kieserver"
        if [ "x${EAP_NODE_NAME}" != "x" ]; then
            JBOSS_NODE_NAME="${EAP_NODE_NAME}"
        elif [ "x${container_uuid}" != "x" ]; then
            JBOSS_NODE_NAME="${container_uuid}"
        elif [ "x${HOSTNAME}" != "x" ]; then
            JBOSS_NODE_NAME="${HOSTNAME}"
        fi
        if [ "x${JBOSS_NODE_NAME}" != "x" ]; then
            KIE_SERVER_ID="${KIE_SERVER_ID}-${JBOSS_NODE_NAME}"
        fi
    fi

    # server state
    if [ "${JBOSS_HOME}" = "" ]; then
        KIE_SERVER_REPO="."
    else
        KIE_SERVER_REPO="${JBOSS_HOME}"
    fi
    KIE_SERVER_STATE_FILE="${KIE_SERVER_REPO}/${KIE_SERVER_ID}.xml"

    # server location values
    if [ "${KIE_SERVER_PROTOCOL}" = "" ]; then
        KIE_SERVER_PROTOCOL="http"
    fi
    if [ "${KIE_SERVER_HOST}" = "" ]; then
        if [ "x${HOSTNAME}" != "x" ]; then
            KIE_SERVER_HOST="${HOSTNAME}"
        else
            # TODO: see if we can the IP address from the container
            KIE_SERVER_HOST="localhost"
        fi
    fi
    if [ "${KIE_SERVER_PORT}" = "" ]; then
        # TODO: see if we can get the port from the container
        KIE_SERVER_PORT="8080"
    fi
    if [ "${KIE_SERVER_CONTEXT}" = "" ]; then
        # TODO: will have to the change name in deployments/kie-server.war/WEB-INF/jboss-web.xml
        #       if this is different than "kie-server", or rename the kie-server.war directory
        KIE_SERVER_CONTEXT="kie-server"
    fi
    KIE_SERVER_LOCATION="${KIE_SERVER_PROTOCOL}://${KIE_SERVER_HOST}:${KIE_SERVER_PORT}/${KIE_SERVER_CONTEXT}/services/rest/server"

    # server security values
    if [ "${KIE_SERVER_USER}" = "" ]; then
        KIE_SERVER_USER="kieserver"
    fi
    if [ "${KIE_SERVER_PASSWORD}" = ""  ]; then
        KIE_SERVER_PASSWORD="kieserver1!"
    fi
    if [ "${KIE_SERVER_DOMAIN}" = "" ]; then
        KIE_SERVER_DOMAIN="other"
    fi
    bypassAuthUser=$(echo "${KIE_SERVER_BYPASS_AUTH_USER}" | tr [:upper:] [:lower:])
    if [ "${bypassAuthUser}" = "true" ]; then
        KIE_SERVER_BYPASS_AUTH_USER="true"
    else
        KIE_SERVER_BYPASS_AUTH_USER="false"
    fi

    # server capabilities
    bpmDisabled=$(echo "${KIE_SERVER_BPM_DISABLED}" | tr [:upper:] [:lower:])
    if [ "${bpmDisabled}" = "true" ] || [ "${bpmDisabled}" = "disabled" ]; then
        KIE_SERVER_BPM_DISABLED="true"
    else
        KIE_SERVER_BPM_DISABLED="false"
    fi
    bpmUiDisabled=$(echo "${KIE_SERVER_BPM_UI_DISABLED}" | tr [:upper:] [:lower:])
    if [ "${bpmUiDisabled}" = "true" ] || [ "${bpmUiDisabled}" = "disabled" ]; then
        KIE_SERVER_BPM_UI_DISABLED="true"
    else
        KIE_SERVER_BPM_UI_DISABLED="false"
    fi
    brmDisabled=$(echo "${KIE_SERVER_BRM_DISABLED}" | tr [:upper:] [:lower:])
    if [ "${brmDisabled}" = "true" ] || [ "${brmDisabled}" = "disabled" ]; then
        KIE_SERVER_BRM_DISABLED="true"
    else
        KIE_SERVER_BRM_DISABLED="false"
    fi
    brpDisabled=$(echo "${KIE_SERVER_BRP_DISABLED}" | tr [:upper:] [:lower:])
    if [ "${brpDisabled}" = "true" ] || [ "${brpDisabled}" = "disabled" ]; then
        KIE_SERVER_BRP_DISABLED="true"
    else
        KIE_SERVER_BRP_DISABLED="false"
    fi

    # should the server filter classes?
    if [ "x${KIE_SERVER_FILTER_CLASSES}" != "x" ]; then
        # if specified, respect value
        filterClasses=$(echo "${KIE_SERVER_FILTER_CLASSES}" | tr [:upper:] [:lower:])
        if [ "${filterClasses}" = "true" ]; then
            KIE_SERVER_FILTER_CLASSES="true"
        else
            KIE_SERVER_FILTER_CLASSES="false"
        fi
    else
        # otherwise, filter classes by default
        KIE_SERVER_FILTER_CLASSES="true"
    fi

    # request queue
    if [ "${KIE_SERVER_JMS_QUEUES_REQUEST}" = "" ]; then
        KIE_SERVER_JMS_QUEUES_REQUEST="queue/KIE.SERVER.REQUEST"
    fi
    # response queue
    # ConnectionFactory is hardcoded in KieServerMDB as "java:/JmsXA"
    # (also see KIE_SERVER_EXECUTOR_JMS_CF below)
    if [ "${KIE_SERVER_JMS_QUEUES_RESPONSE}" = "" ]; then
        KIE_SERVER_JMS_QUEUES_RESPONSE="queue/KIE.SERVER.RESPONSE"
    fi

    # persistence
    if [ "${KIE_SERVER_PERSISTENCE_DIALECT}" = "" ]; then
        KIE_SERVER_PERSISTENCE_DIALECT="org.hibernate.dialect.H2Dialect"
    fi
    if [ "${KIE_SERVER_PERSISTENCE_DS}" = "" ]; then
        if [ "x${DB_JNDI}" != "x" ]; then
            KIE_SERVER_PERSISTENCE_DS="${DB_JNDI}"
        else
            KIE_SERVER_PERSISTENCE_DS="java:/jboss/datasources/ExampleDS"
        fi
    fi
    if [ "${KIE_SERVER_PERSISTENCE_TM}" = "" ]; then
        KIE_SERVER_PERSISTENCE_TM="org.hibernate.service.jta.platform.internal.JBossAppServerJtaPlatform"
    fi

    # human tasks
    if [ "${KIE_SERVER_HT_CALLBACK}" = "" ]; then
        KIE_SERVER_HT_CALLBACK="jaas"
    fi
    # human task properties we don't need to set defaults for:
    # KIE_SERVER_HT_CUSTOM_CALLBACK, KIE_SERVER_HT_USERINFO, KIE_SERVER_HT_CUSTOM_USERINFO

    # executor basic properties
    if [ "${KIE_SERVER_EXECUTOR_POOL_SIZE}" = "" ]; then
        KIE_SERVER_EXECUTOR_POOL_SIZE="1"
    fi
    if [ "${KIE_SERVER_EXECUTOR_RETRY_COUNT}" = "" ]; then
        KIE_SERVER_EXECUTOR_RETRY_COUNT="3"
    fi
    if [ "${KIE_SERVER_EXECUTOR_INTERVAL}" = "" ]; then
        KIE_SERVER_EXECUTOR_INTERVAL="3"
    fi
    if [ "${KIE_SERVER_EXECUTOR_INITIAL_DELAY}" = "" ]; then
        KIE_SERVER_EXECUTOR_INITIAL_DELAY="100"
    fi
    if [ "${KIE_SERVER_EXECUTOR_TIMEUNIT}" = "" ]; then
        KIE_SERVER_EXECUTOR_TIMEUNIT="SECONDS"
    fi

    # executor properties
    executorDisabled=$(echo "${KIE_SERVER_EXECUTOR_DISABLED}" | tr [:upper:] [:lower:])
    if [ "${executorDisabled}" = "true" ] || [ "${executorDisabled}" = "disabled" ]; then
        KIE_SERVER_EXECUTOR_DISABLED="true"
    else
        KIE_SERVER_EXECUTOR_DISABLED="false"
    fi
    if [ "x${KIE_SERVER_EXECUTOR_JMS}" != "x" ]; then
        # if specified, respect value
        executorJms=$(echo "${KIE_SERVER_EXECUTOR_JMS}" | tr [:upper:] [:lower:])
        if [ "${executorJms}" = "true" ]; then
            KIE_SERVER_EXECUTOR_JMS="true"
        else
            KIE_SERVER_EXECUTOR_JMS="false"
        fi
    else
        # otherwise, default to true
        KIE_SERVER_EXECUTOR_JMS="true"
    fi
    # not allowing KIE_SERVER_EXECUTOR_JMS_CF variable since default ("java:/JmsXA")
    # is same as what is hardcoded in KieServerMDB for KIE_SERVER_JMS_QUEUES_RESPONSE above
    if [ "${KIE_SERVER_EXECUTOR_JMS_QUEUE}" = "" ]; then
        KIE_SERVER_EXECUTOR_JMS_QUEUE="queue/KIE.SERVER.EXECUTOR"
    fi
    if [ "x${KIE_SERVER_EXECUTOR_JMS_TRANSACTED}" != "x" ]; then
        # if specified, respect value
        jmsTransacted=$(echo "${KIE_SERVER_EXECUTOR_JMS_TRANSACTED}" | tr [:upper:] [:lower:])
        if [ "${jmsTransacted}" = "true" ]; then
            KIE_SERVER_EXECUTOR_JMS_TRANSACTED="true"
        else
            KIE_SERVER_EXECUTOR_JMS_TRANSACTED="false"
        fi
    else
        # otherwise, default to false
        KIE_SERVER_EXECUTOR_JMS_TRANSACTED="false"
    fi

    # should jmx mbeans be enabled? (true/false becomes enabled/disabled)
    if [ "x${KIE_SERVER_MBEANS_ENABLED}" != "x" ]; then
        # if specified, respect value
        mbeansEnabled=$(echo "${KIE_SERVER_MBEANS_ENABLED}" | tr [:upper:] [:lower:])
        if [ "${mbeansEnabled}" = "true" ] || [ "${mbeansEnabled}" = "enabled" ]; then
            KIE_SERVER_MBEANS_ENABLED="enabled"
        else
            KIE_SERVER_MBEANS_ENABLED="disabled"
        fi
    else
        # otherwise, default to enabled
        KIE_SERVER_MBEANS_ENABLED="enabled"
    fi

    # Arguments to start the kieserver
    KIE_SERVER_OPTS="-Dkie.maven.settings.custom=${HOME}/.m2/settings.xml"
    KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dkie.mbeans=${KIE_SERVER_MBEANS_ENABLED}"
    KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dkie.scanner.mbeans=${KIE_SERVER_MBEANS_ENABLED}"
    KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dkie.server.jms.queues.response=${KIE_SERVER_JMS_QUEUES_RESPONSE}"
    KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.drools.server.ext.disabled=${KIE_SERVER_BRM_DISABLED}"
    KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.drools.server.filter.classes=${KIE_SERVER_FILTER_CLASSES}"
    if [ "${KIE_SERVER_BPM_DISABLED}" = "false" ]; then
        if [ "x${KIE_SERVER_HT_CALLBACK}" != "x" ]; then
            KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.jbpm.ht.callback=${KIE_SERVER_HT_CALLBACK}"
        fi
        if [ "x${KIE_SERVER_HT_CUSTOM_CALLBACK}" != "x" ]; then
            KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.jbpm.ht.custom.callback=${KIE_SERVER_HT_CUSTOM_CALLBACK}"
        fi
        if [ "x${KIE_SERVER_HT_USERINFO}" != "x" ]; then
            KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.jbpm.ht.userinfo=${KIE_SERVER_HT_USERINFO}"
        fi
        if [ "x${KIE_SERVER_HT_CUSTOM_USERINFO}" != "x" ]; then
            KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.jbpm.ht.custom.userinfo=${KIE_SERVER_HT_CUSTOM_USERINFO}"
        fi
    fi
    KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.jbpm.server.ext.disabled=${KIE_SERVER_BPM_DISABLED}"
    KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.jbpm.ui.server.ext.disabled=${KIE_SERVER_BPM_UI_DISABLED}"
    KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.kie.server.bypass.auth.user=${KIE_SERVER_BYPASS_AUTH_USER}"
    KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.kie.server.domain=${KIE_SERVER_DOMAIN}"
    if [ "${KIE_SERVER_BPM_DISABLED}" = "false" ]; then
        KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.kie.executor.disabled=${KIE_SERVER_EXECUTOR_DISABLED}"
        if [ "${KIE_SERVER_EXECUTOR_DISABLED}" = "false" ]; then
            KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.kie.executor.pool.size=${KIE_SERVER_EXECUTOR_POOL_SIZE}"
            KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.kie.executor.retry.count=${KIE_SERVER_EXECUTOR_RETRY_COUNT}"
            KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.kie.executor.interval=${KIE_SERVER_EXECUTOR_INTERVAL}"
            KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.kie.executor.initial.delay=${KIE_SERVER_EXECUTOR_INITIAL_DELAY}"
            KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.kie.executor.timeunit=${KIE_SERVER_EXECUTOR_TIMEUNIT}"
            KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.kie.executor.jms=${KIE_SERVER_EXECUTOR_JMS}"
            if [ "${KIE_SERVER_EXECUTOR_JMS}" = "true" ]; then
                KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.kie.executor.jms.queue=${KIE_SERVER_EXECUTOR_JMS_QUEUE}"
                KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.kie.executor.jms.transacted=${KIE_SERVER_EXECUTOR_JMS_TRANSACTED}"
            fi
        fi
    fi
    KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.kie.server.id=${KIE_SERVER_ID}"
    KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.kie.server.location=${KIE_SERVER_LOCATION}"
    if [ "${KIE_SERVER_BPM_DISABLED}" = "false" ]; then
        KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.kie.server.persistence.dialect=${KIE_SERVER_PERSISTENCE_DIALECT}"
        KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.kie.server.persistence.ds=${KIE_SERVER_PERSISTENCE_DS}"
        KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.kie.server.persistence.tm=${KIE_SERVER_PERSISTENCE_TM}"
    fi
    KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.kie.server.repo=${KIE_SERVER_REPO}"
    KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.optaplanner.server.ext.disabled=${KIE_SERVER_BRP_DISABLED}"

    # env var used by KIE to find and load global settings.xml before overriding with custom settings.xml (above)
    m2Home=$(mvn -v | grep -i 'maven home: ' | sed -E 's/^.{12}//')
    M2_HOME="${m2Home}"
    export M2_HOME
}

function getKieServerVal() {
    kieServerVar="KIE_SERVER_${1}"
    eval "echo \$${kieServerVar}"
}

function dumpKieServerEnv() {
    echo "KIE_SERVER_BPM_DISABLED: $(getKieServerVal BPM_DISABLED)"
    echo "KIE_SERVER_BPM_UI_DISABLED: $(getKieServerVal BPM_UI_DISABLED)"
    echo "KIE_SERVER_BRM_DISABLED: $(getKieServerVal BRM_DISABLED)"
    echo "KIE_SERVER_BRP_DISABLED: $(getKieServerVal BRP_DISABLED)"
    echo "KIE_SERVER_BYPASS_AUTH_USER: $(getKieServerVal BYPASS_AUTH_USER)"
    echo "KIE_SERVER_CONTEXT: $(getKieServerVal CONTEXT)"
    echo "KIE_SERVER_DOMAIN: $(getKieServerVal DOMAIN)"
    if [ "${KIE_SERVER_BPM_DISABLED}" = "false" ]; then
        echo "KIE_SERVER_EXECUTOR_DISABLED: $(getKieServerVal EXECUTOR_DISABLED)"
        echo "KIE_SERVER_EXECUTOR_POOL_SIZE: $(getKieServerVal EXECUTOR_POOL_SIZE)"
        echo "KIE_SERVER_EXECUTOR_RETRY_COUNT: $(getKieServerVal EXECUTOR_RETRY_COUNT)"
        echo "KIE_SERVER_EXECUTOR_INTERVAL: $(getKieServerVal EXECUTOR_INTERVAL)"
        echo "KIE_SERVER_EXECUTOR_INITIAL_DELAY: $(getKieServerVal EXECUTOR_INITIAL_DELAY)"
        echo "KIE_SERVER_EXECUTOR_TIMEUNIT: $(getKieServerVal EXECUTOR_TIMEUNIT)"
        echo "KIE_SERVER_EXECUTOR_JMS: $(getKieServerVal EXECUTOR_JMS)"
        echo "KIE_SERVER_EXECUTOR_JMS_QUEUE: $(getKieServerVal EXECUTOR_JMS_QUEUE)"
        echo "KIE_SERVER_EXECUTOR_JMS_TRANSACTED: $(getKieServerVal EXECUTOR_JMS_TRANSACTED)"
    fi
    echo "KIE_SERVER_FILTER_CLASSES: $(getKieServerVal FILTER_CLASSES)"
    echo "KIE_SERVER_HOST: $(getKieServerVal HOST)"
    if [ "${KIE_SERVER_BPM_DISABLED}" = "false" ]; then
        echo "KIE_SERVER_HT_CALLBACK: $(getKieServerVal HT_CALLBACK)"
        echo "KIE_SERVER_HT_CUSTOM_CALLBACK: $(getKieServerVal HT_CUSTOM_CALLBACK)"
        echo "KIE_SERVER_HT_USERINFO: $(getKieServerVal HT_USERINFO)"
        echo "KIE_SERVER_HT_CUSTOM_USERINFO: $(getKieServerVal HT_CUSTOM_USERINFO)"
    fi
    echo "KIE_SERVER_ID: $(getKieServerVal ID)"
    echo "KIE_SERVER_JMS_QUEUES_REQUEST: $(getKieServerVal JMS_QUEUES_REQUEST)"
    echo "KIE_SERVER_JMS_QUEUES_RESPONSE: $(getKieServerVal JMS_QUEUES_RESPONSE)"
    echo "KIE_SERVER_LOCATION: $(getKieServerVal LOCATION)"
    echo "KIE_SERVER_MBEANS_ENABLED: $(getKieServerVal MBEANS_ENABLED)"
    echo "KIE_SERVER_OPTS: $(getKieServerVal OPTS)"
    echo "KIE_SERVER_PASSWORD: $(getKieServerVal PASSWORD)"
    if [ "${KIE_SERVER_BPM_DISABLED}" = "false" ]; then
        echo "KIE_SERVER_PERSISTENCE_DIALECT: $(getKieServerVal PERSISTENCE_DIALECT)"
        echo "KIE_SERVER_PERSISTENCE_DS: $(getKieServerVal PERSISTENCE_DS)"
        echo "KIE_SERVER_PERSISTENCE_TM: $(getKieServerVal PERSISTENCE_TM)"
    fi
    echo "KIE_SERVER_PORT: $(getKieServerVal PORT)"
    echo "KIE_SERVER_PROTOCOL: $(getKieServerVal PROTOCOL)"
    echo "KIE_SERVER_REPO: $(getKieServerVal REPO)"
    echo "KIE_SERVER_STATE_FILE: $(getKieServerVal STATE_FILE)"
    echo "KIE_SERVER_USER: $(getKieServerVal USER)"
    echo "M2_HOME: ${M2_HOME}"
}

function setKieFullEnv() {
    setKieContainerEnv
    setKieServerEnv
}

function dumpKieFullEnv() {
    dumpKieContainerEnv
    dumpKieServerEnv
}

