#!/bin/sh
# if using vim, do ':set ft=zsh' for easier reading

source /opt/rh/rh-maven33/enable
source $JBOSS_HOME/bin/launch/logging.sh

# source the KIE config
source $JBOSS_HOME/bin/launch/kieserver-env.sh
# set the KIE environment
setKieEnv
# dump the KIE environment
dumpKieEnv

function generateRandom() {
    cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1
}

function generatePullPomXml() {
  echo "<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>org.openshift</groupId>
  <artifactId>kieserver-pull</artifactId>
  <version>1.0.0.Final</version>
  <name>Pull Dependencies</name>
  <dependencies>
        <dependency>
            <groupId>$(getKieServerContainerVal KJAR_GROUP_ID ${1})</groupId>
            <artifactId>$(getKieServerContainerVal KJAR_ARTIFACT_ID ${1})</artifactId>
            <version>$(getKieServerContainerVal KJAR_VERSION ${1})</version>
        </dependency>
  </dependencies>
</project>"
}

if [ "${KIE_SERVER_CONTAINER_DEPLOYMENT}" != "" ]; then
    for (( i=0; i<${KIE_SERVER_CONTAINER_DEPLOYMENT_COUNT}; i++ )); do
        pullPomFile="pull-pom-${i}-$(generateRandom).xml"
        generatePullPomXml ${i} > ${pullPomFile}
        # Add JVM default options
        export MAVEN_OPTS="${MAVEN_OPTS:-$(/opt/run-java/java-default-options)}"
        # Use maven batch mode (CLOUD-579)
        mavenArgsPull="-e -DskipTests dependency:go-offline -f ${pullPomFile} --batch-mode -Djava.net.preferIPv4Stack=true -Popenshift -Dcom.redhat.xpaas.repo.redhatga ${MAVEN_ARGS_APPEND}"

        log_info "Attempting to pull dependencies for kjar ${i} with 'mvn ${mavenArgsPull}'"
        log_info "Using MAVEN_OPTS '${MAVEN_OPTS}'"
        log_info "Using $(mvn --version)"

        # Execute the maven pull of dependencies
        mvn ${mavenArgsPull}
        ERR=$?

        rm -f ${pullPomFile}

        if [ $ERR -ne 0 ]; then
            log_error "Aborting due to error code $ERR from Maven build"
            exit $ERR
        fi
    done
fi

# Remove _remote.repositories files so we can run offline: CLOUD-1839
find ~/.m2/repository -name _remote.repositories | xargs rm

# Necessary to permit running with a randomised UID
chown -R --quiet jboss:root ${HOME}/.m2/repository
chmod -R --quiet g+rwX ${HOME}/.m2/repository

exit 0
