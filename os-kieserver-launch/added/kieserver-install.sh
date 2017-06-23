#!/bin/sh
# if using vim, do ':set ft=zsh' for easier reading

. /opt/rh/rh-maven33/enable

LOCAL_SOURCE_DIR=/tmp/src

# By this point, EAP deployments dir will contain everything outputted from s2i, including
# maven-built artifacts in ~/target/, or artifacts copied from ~/source/deployments/.
DEPLOY_DIR="${JBOSS_HOME}/standalone/deployments"

# Ensure that the local maven repository exists
MAVEN_REPO=${HOME}/.m2/repository
mkdir -p ${MAVEN_REPO}

if [ -d ${DEPLOY_DIR} ]; then
    TEMP_KJARS_DIR="${LOCAL_SOURCE_DIR}/tmp-kjars"

    # iterate through all jar files found, and if a kjar (has both kmodule.xml and pom.xml), install into local maven repository
    for JAR in $(find ${DEPLOY_DIR}/ -maxdepth 1 -name *.jar | sed 's|.*/||'); do
        KJAR=""
        mkdir -p ${TEMP_KJARS_DIR}/${JAR}
        if [ -d ${DEPLOY_DIR}/${JAR} ]; then
            # jar is an exploded directory; copy contents
            cp -r ${DEPLOY_DIR}/${JAR}/* ${TEMP_KJARS_DIR}/${JAR}/
        else
            # jar is a zipped file; unzip contents
            unzip -q ${DEPLOY_DIR}/${JAR} -d ${TEMP_KJARS_DIR}/${JAR}
        fi
        if [ -e "${TEMP_KJARS_DIR}/${JAR}/META-INF/kmodule.xml" ]; then
            POM=$(find ${TEMP_KJARS_DIR}/${JAR}/META-INF/maven -name 'pom.xml' 2>/dev/null)
            if [ -e "${POM}" ]; then
                KJAR=${JAR}
            fi
        fi
        if [ "${KJAR}" = "" ]; then
            echo "${DEPLOY_DIR}/${JAR} is not a kjar (skipping)"
        else
            echo "${DEPLOY_DIR}/${JAR} is a kjar"
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
            echo "Attempting to install kjar with 'mvn ${MAVEN_ARGS_INSTALL}'"
            echo "Using MAVEN_OPTS '${MAVEN_OPTS}'"
            echo "Using $(mvn --version)"
            # Execute the maven install of kjar
            mvn $MAVEN_ARGS_INSTALL
            ERR=$?
            if [ $ERR -ne 0 ]; then
                echo "Aborting due to error code $ERR from Maven build"
                # cleanup
                rm -rf ${TEMP_KJARS_DIR}
                exit $ERR
            fi

            # Discover KIE_CONTAINER_DEPLOYMENT for when env var not specified
            pushd $(dirname ${POM}) &> /dev/null
                # first trigger download of help:evaluate dependencies
                echo "Inspecting kjar ${DEPLOY_DIR}/${JAR} for artifact information..."
                # Add JVM default options
                export MAVEN_OPTS="${MAVEN_OPTS:-$(/opt/run-java/java-default-options)}"
                # Use maven batch mode (CLOUD-579)
                MAVEN_ARGS_EVALUATE="--batch-mode -Djava.net.preferIPv4Stack=true -Popenshift -Dcom.redhat.xpaas.repo.redhatga ${MAVEN_ARGS_APPEND}"
                mvn help:evaluate -Dexpression=project.artifact ${MAVEN_ARGS_EVALUATE}
                ERR=$?
                if [ $ERR -ne 0 ]; then
                    echo "Aborting due to error code $ERR from Maven artifact discovery"
                    exit $ERR
                fi
                # next use help:evaluate to record the kjar as a kie container deployment
                kieContainerDeploymentsFile="${JBOSS_HOME}/kiecontainer-deployments.txt"
                kjarGroupId="$(mvn help:evaluate -Dexpression=project.artifact.groupId ${MAVEN_ARGS_EVALUATE} | egrep -v '(^\[.*\])|(Download.*: )')"
                kjarArtifactId="$(mvn help:evaluate -Dexpression=project.artifact.artifactId ${MAVEN_ARGS_EVALUATE} | egrep -v '(^\[.*\])|(Download.*: )')"
                kjarVersion="$(mvn help:evaluate -Dexpression=project.artifact.version ${MAVEN_ARGS_EVALUATE} | egrep -v '(^\[.*\])|(Download.*: )')"
                kieContainerDeployment="${kjarArtifactId}=${kjarGroupId}:${kjarArtifactId}:${kjarVersion}"
                echo "Adding ${kieContainerDeployment} to ${kieContainerDeploymentsFile}"
                echo "${kieContainerDeployment}" >> ${kieContainerDeploymentsFile}
                chmod a+rw ${kieContainerDeploymentsFile}
            popd &> /dev/null

            # Remove kjar from EAP deployments dir, as KIE loads them from ${HOME}/.m2/repository/ instead.
            # Leaving this file here could cause classloading collisions if multiple KIE Containers are
            # configured for different versions of the same application.
            rm -f ${DEPLOY_DIR}/${JAR}
        fi
    done
    # cleanup
    rm -rf ${TEMP_KJARS_DIR}

    # Necessary to permit running with a randomised UID
    chown -R jboss:root ${MAVEN_REPO}
    chmod -R g+rwX ${MAVEN_REPO}
fi

exit 0
