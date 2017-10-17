#!/bin/sh
# if using vim, do ':set ft=zsh' for easier reading

source $JBOSS_HOME/bin/launch/logging.sh

function getKieJavaArgs() {
    local kieJarDir="${JBOSS_HOME}/standalone/deployments/ROOT.war/WEB-INF/lib"
    local kieClassPath="."
    for kieJar in ${kieJarDir}/*.jar; do
        kieClassPath="${kieClassPath}:${kieJar}"
    done
    for launchJar in ${JBOSS_HOME}/bin/launch/*.jar; do
        kieClassPath="${kieClassPath}:${launchJar}"
    done
    echo "-Dorg.slf4j.simpleLogger.defaultLogLevel=WARN -jar ${JBOSS_HOME}/jboss-modules.jar -mp ${JBOSS_HOME}/modules -dep javax.enterprise.api,javax.inject.api,sun.jdk -cp ${kieClassPath}"
}

function setKieEnv() {
    # discover kie server container deployments
    local kieServerContainerDeploymentsFile="${JBOSS_HOME}/kieserver-container-deployments.txt"
    if [ "x${KIE_SERVER_CONTAINER_DEPLOYMENT_OVERRIDE}" != "x" ]; then
        log_info "Encountered EnvVar KIE_SERVER_CONTAINER_DEPLOYMENT_OVERRIDE: ${KIE_SERVER_CONTAINER_DEPLOYMENT_OVERRIDE}"
        if [ "x${KIE_SERVER_CONTAINER_DEPLOYMENT}" != "x" ]; then
            KIE_SERVER_CONTAINER_DEPLOYMENT_ORIGINAL="${KIE_SERVER_CONTAINER_DEPLOYMENT}"
            export KIE_SERVER_CONTAINER_DEPLOYMENT_ORIGINAL
            log_info "Setting EnvVar KIE_SERVER_CONTAINER_DEPLOYMENT_ORIGINAL: ${KIE_SERVER_CONTAINER_DEPLOYMENT_ORIGINAL}"
        fi
        KIE_SERVER_CONTAINER_DEPLOYMENT="${KIE_SERVER_CONTAINER_DEPLOYMENT_OVERRIDE}"
        export KIE_SERVER_CONTAINER_DEPLOYMENT
        log_info "Using overridden EnvVar KIE_SERVER_CONTAINER_DEPLOYMENT: ${KIE_SERVER_CONTAINER_DEPLOYMENT}"
    elif [ "x${KIE_SERVER_CONTAINER_DEPLOYMENT}" != "x" ]; then
        log_info "Using standard EnvVar KIE_SERVER_CONTAINER_DEPLOYMENT: ${KIE_SERVER_CONTAINER_DEPLOYMENT}"
    elif [ -e ${kieServerContainerDeploymentsFile} ]; then
        local kieServerContainerDeployments=""
        while read kieServerContainerDeployment ; do
            # add pipe at end of each
            kieServerContainerDeployments="${kieServerContainerDeployments}${kieServerContainerDeployment}|"
        done <${kieServerContainerDeploymentsFile}
        # remove last unecessary pipe
        kieServerContainerDeployments=$(echo ${kieServerContainerDeployments} | sed "s/\(.*\)|/\1/")
        KIE_SERVER_CONTAINER_DEPLOYMENT="${kieServerContainerDeployments}"
        export KIE_SERVER_CONTAINER_DEPLOYMENT
        log_info "Read ${kieServerContainerDeploymentsFile} into EnvVar KIE_SERVER_CONTAINER_DEPLOYMENT: ${KIE_SERVER_CONTAINER_DEPLOYMENT}"
    fi

    # process kie server container deployments
    if [ "x${KIE_SERVER_CONTAINER_DEPLOYMENT}" != "x" ]; then
        # kieServerContainerDeployment|kieServerContainerDeployment
        IFS='|' read -a kieServerContainerDeploymentArray <<< "${KIE_SERVER_CONTAINER_DEPLOYMENT}"
        local kieServerContainerDeploymentCount=${#kieServerContainerDeploymentArray[@]}
        KIE_SERVER_CONTAINER_DEPLOYMENT_COUNT="${kieServerContainerDeploymentCount}"
        for (( i=0; i<${kieServerContainerDeploymentCount}; i++ )); do
            # containerId=releaseId
            local kieServerContainerDeployment=${kieServerContainerDeploymentArray[i]}
            IFS='=' read -a kieServerContainerDefinitionArray <<< "${kieServerContainerDeployment}"
            local kieServerContainerId=${kieServerContainerDefinitionArray[0]}
            local kjarReleaseId=${kieServerContainerDefinitionArray[1]}
            eval "KIE_SERVER_CONTAINER_ID_${i}=\"${kieServerContainerId}\""
            # groupId:artifactId:version
            IFS=':' read -a kjarReleaseIdArray <<< "${kjarReleaseId}"
            local kjarGroupId=${kjarReleaseIdArray[0]}
            local kjarArtifactId=${kjarReleaseIdArray[1]}
            local kjarVersion=${kjarReleaseIdArray[2]}
            eval "KIE_SERVER_CONTAINER_KJAR_GROUP_ID_${i}=${kjarGroupId}"
            eval "KIE_SERVER_CONTAINER_KJAR_ARTIFACT_ID_${i}=${kjarArtifactId}"
            eval "KIE_SERVER_CONTAINER_KJAR_VERSION_${i}=${kjarVersion}"
        done
    else
        KIE_SERVER_CONTAINER_DEPLOYMENT_COUNT=0
        log_warning "Warning: EnvVar KIE_SERVER_CONTAINER_DEPLOYMENT is missing."
        log_warning "Example: export KIE_SERVER_CONTAINER_DEPLOYMENT='containerId=groupId:artifactId:version|c2=g2:a2:v2'"
    fi
}

function getKieServerContainerVal() {
    local kieServerContainerVar="KIE_SERVER_CONTAINER_${1}_${2}"
    eval "echo \$${kieServerContainerVar}"
}

function dumpKieEnv() {
    echo "KIE_SERVER_CONTAINER_DEPLOYMENT: ${KIE_SERVER_CONTAINER_DEPLOYMENT}"
    echo "KIE_SERVER_CONTAINER_DEPLOYMENT_ORIGINAL: ${KIE_SERVER_CONTAINER_DEPLOYMENT_ORIGINAL}"
    echo "KIE_SERVER_CONTAINER_DEPLOYMENT_OVERRIDE: ${KIE_SERVER_CONTAINER_DEPLOYMENT_OVERRIDE}"
    echo "KIE_SERVER_CONTAINER_DEPLOYMENT_COUNT: ${KIE_SERVER_CONTAINER_DEPLOYMENT_COUNT}"
    for (( i=0; i<${KIE_SERVER_CONTAINER_DEPLOYMENT_COUNT}; i++ )); do
        echo "KIE_SERVER_CONTAINER_ID_${i}: $(getKieServerContainerVal ID ${i})"
        echo "KIE_SERVER_CONTAINER_KJAR_GROUP_ID_${i}: $(getKieServerContainerVal KJAR_GROUP_ID ${i})"
        echo "KIE_SERVER_CONTAINER_KJAR_ARTIFACT_ID_${i}: $(getKieServerContainerVal KJAR_ARTIFACT_ID ${i})"
        echo "KIE_SERVER_CONTAINER_KJAR_VERSION_${i}: $(getKieServerContainerVal KJAR_VERSION ${i})"
    done
}
