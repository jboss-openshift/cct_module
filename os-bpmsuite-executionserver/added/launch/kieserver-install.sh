#!/bin/sh
# if using vim, do ':set ft=zsh' for easier reading

source /usr/local/s2i/scl-enable-maven
source $JBOSS_HOME/bin/launch/logging.sh

LOCAL_SOURCE_DIR=/tmp/src

# By this point, EAP deployments dir will contain everything outputted from s2i, including
# maven-built artifacts in ~/target/, or artifacts copied from ~/source/deployments/.
DEPLOY_DIR="${JBOSS_HOME}/standalone/deployments"

# Ensure that the local maven repository exists
MAVEN_REPO=${HOME}/.m2/repository
mkdir -p ${MAVEN_REPO}

if [ -d ${DEPLOY_DIR} ]; then
    TEMP_JARS_DIR="${LOCAL_SOURCE_DIR}/tmp-jars"

    # install all jars in the local maven repository, including kjar (has both kmodule.xml and pom.xml)
    for JAR in $(find ${DEPLOY_DIR}/ -maxdepth 1 -name *.jar | sed 's|.*/||'); do
        KJAR=""
        mkdir -p ${TEMP_JARS_DIR}/${JAR}
        if [ -d ${DEPLOY_DIR}/${JAR} ]; then
            # jar is an exploded directory; copy contents
            cp -r ${DEPLOY_DIR}/${JAR}/* ${TEMP_JARS_DIR}/${JAR}/
        else
            # jar is a zipped file; unzip contents
            unzip -q ${DEPLOY_DIR}/${JAR} -d ${TEMP_JARS_DIR}/${JAR}
        fi

        # at this moment install all jars on local maven repository
        POM=$(find ${TEMP_JARS_DIR}/${JAR}/META-INF/maven -name 'pom.xml' 2>/dev/null)
        if [ -e "${POM}" ]; then

            # verify if the current jar is a kjar
            if [ -e "${TEMP_JARS_DIR}/${JAR}/META-INF/kmodule.xml" ]; then
                log_info "${DEPLOY_DIR}/${JAR} is a kjar."
                KJAR=${JAR}
            fi

            log_info "${DEPLOY_DIR}/${JAR} has a pom: Attempting to install"
            if [ -d ${DEPLOY_DIR}/${JAR} ]; then
                # jar is an exploded directory; replace with zipped file (for mvn install:install-file below to work)
                zip -r ${DEPLOY_DIR}/${JAR}.zip ${DEPLOY_DIR}/${JAR}/*
                rm -rf ${DEPLOY_DIR}/${JAR}
                mv ${DEPLOY_DIR}/${JAR}.zip ${DEPLOY_DIR}/${JAR}
            fi
            # Add JVM default options
            export MAVEN_OPTS="${MAVEN_OPTS:-$(/opt/run-java/java-default-options)}"
            # Use maven batch mode (CLOUD-579)
            MAVEN_ARGS_INSTALL="-e -DskipTests install:install-file -Dfile=${DEPLOY_DIR}/${JAR} -DpomFile=${POM} -Dpackaging=jar --batch-mode -Djava.net.preferIPv4Stack=true -Popenshift -Dcom.redhat.xpaas.repo.redhatga ${MAVEN_ARGS_APPEND}"
            log_info "Attempting to install jar with 'mvn ${MAVEN_ARGS_INSTALL}'"
            log_info "Using MAVEN_OPTS '${MAVEN_OPTS}'"
            log_info "Using $(mvn --version)"
            # Execute the maven install of jar and kjar
            mvn $MAVEN_ARGS_INSTALL
            ERR=$?
            if [ $ERR -ne 0 ]; then
                log_error "Aborting due to error code $ERR from Maven build"
                # cleanup
                rm -rf ${TEMP_JARS_DIR}
                exit $ERR
            fi

            # Discover KIE_SERVER_CONTAINER_DEPLOYMENT for when env var not specified, only kjar (has kmodule.xml) should be configured.
            if [ "${KJAR}" != "" ]; then
                pushd $(dirname ${POM}) &> /dev/null
                    # first trigger download of help:evaluate dependencies
                    log_info "Inspecting kjar ${DEPLOY_DIR}/${JAR} for artifact information..."
                    # Add JVM default options
                    export MAVEN_OPTS="${MAVEN_OPTS:-$(/opt/run-java/java-default-options)}"
                    # Use maven batch mode (CLOUD-579)
                    MAVEN_ARGS_EVALUATE="--batch-mode -Djava.net.preferIPv4Stack=true -Popenshift -Dcom.redhat.xpaas.repo.redhatga ${MAVEN_ARGS_APPEND}"
                    mvn help:evaluate -Dexpression=project.artifact ${MAVEN_ARGS_EVALUATE}
                    ERR=$?
                    if [ $ERR -ne 0 ]; then
                        log_error "Aborting due to error code $ERR from Maven artifact discovery"
                        exit $ERR
                    fi
                    # next use help:evaluate to record the kjar as a kie server container deployment
                    kieServerContainerDeploymentsFile="${JBOSS_HOME}/kieserver-container-deployments.txt"
                    kjarGroupId="$(mvn help:evaluate -Dexpression=project.artifact.groupId ${MAVEN_ARGS_EVALUATE} | egrep -v '(^\[.*\])|(Download.*: )')"
                    kjarArtifactId="$(mvn help:evaluate -Dexpression=project.artifact.artifactId ${MAVEN_ARGS_EVALUATE} | egrep -v '(^\[.*\])|(Download.*: )')"
                    kjarVersion="$(mvn help:evaluate -Dexpression=project.artifact.version ${MAVEN_ARGS_EVALUATE} | egrep -v '(^\[.*\])|(Download.*: )')"
                    kieServerContainerDeployment="${kjarArtifactId}=${kjarGroupId}:${kjarArtifactId}:${kjarVersion}"
                    log_info "Adding ${kieServerContainerDeployment} to ${kieServerContainerDeploymentsFile}"
                    echo "${kieServerContainerDeployment}" >> ${kieServerContainerDeploymentsFile}
                    chmod --quiet a+rw ${kieServerContainerDeploymentsFile}
                popd &> /dev/null
            fi
            # Remove kjar from EAP deployments dir, as KIE loads them from ${HOME}/.m2/repository/ instead.
            # Leaving this file here could cause classloading collisions if multiple KIE Server Containers
            # are configured for different versions of the same application.
            rm -f ${DEPLOY_DIR}/${JAR}
        fi
    done
    # cleanup
    rm -rf ${TEMP_JARS_DIR}

    # Necessary to permit running with a randomised UID
    chown -R --quiet jboss:root ${MAVEN_REPO}
    chmod -R --quiet g+rwX ${MAVEN_REPO}
fi

exit 0
