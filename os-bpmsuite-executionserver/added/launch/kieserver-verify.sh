#!/bin/sh
# if using vim, do ':set ft=zsh' for easier reading

# source the KIE config
source $JBOSS_HOME/bin/launch/kieserver-env.sh
# set the KIE environment
setKieEnv
# dump the KIE environment
dumpKieEnv

function verifyServerContainers() {
    if [ "${KIE_SERVER_CONTAINER_DEPLOYMENT}" != "" ]; then
        local releaseIds=""
        for (( i=0; i<${KIE_SERVER_CONTAINER_DEPLOYMENT_COUNT}; i++ )); do
            local groupId=$(getKieServerContainerVal KJAR_GROUP_ID ${i})
            local artifactId=$(getKieServerContainerVal KJAR_ARTIFACT_ID ${i})
            local version=$(getKieServerContainerVal KJAR_VERSION ${i})
            releaseIds="${releaseIds} ${groupId}:${artifactId}:${version}"
        done
        local containerVerifier="org.kie.server.services.impl.KieServerContainerVerifier"
        echo "Attempting to verify kie server containers with 'java ${containerVerifier} ${releaseIds}'"
        java $(getKieJavaArgs) ${containerVerifier} ${releaseIds}
    fi
}

# Execute the server container verification
verifyServerContainers
ERR=$?

if [ $ERR -ne 0 ]; then
  echo "Aborting due to error code $ERR from kie server container verification"
  exit $ERR
fi

# Necessary to permit running with a randomised UID
chown -R --quiet jboss:root ${HOME}/.m2/repository
chmod -R --quiet g+rwX ${HOME}/.m2/repository

exit 0
