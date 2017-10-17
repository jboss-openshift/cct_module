#!/bin/sh
# if using vim, do ':set ft=zsh' for easier reading

# source the KIE config
source $JBOSS_HOME/bin/kieserver-config.sh
source $JBOSS_HOME/bin/launch/logging.sh
# set the KIE environment
setKieContainerEnv
# dump the KIE environment
dumpKieContainerEnv

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
            <groupId>$(getKieContainerVal KJAR_GROUP_ID ${1})</groupId>
            <artifactId>$(getKieContainerVal KJAR_ARTIFACT_ID ${1})</artifactId>
            <version>$(getKieContainerVal KJAR_VERSION ${1})</version>
        </dependency>
  </dependencies>
</project>"
}

for (( i=0; i<${KIE_CONTAINER_DEPLOYMENT_COUNT}; i++ )); do
    PULL_POM_FILE="pull-pom-${i}-$(generateRandom).xml"
    generatePullPomXml ${i} > ${PULL_POM_FILE}
    # Add JVM default options
    export MAVEN_OPTS="${MAVEN_OPTS:-$(/opt/run-java/java-default-options)}"
    # Use maven batch mode (CLOUD-579)
    MAVEN_ARGS_PULL="-e -DskipTests dependency:go-offline -f ${PULL_POM_FILE} --batch-mode -Djava.net.preferIPv4Stack=true -Popenshift -Dcom.redhat.xpaas.repo.redhatga ${MAVEN_ARGS_APPEND}"

    log_info "Attempting to pull dependencies for kjar ${i} with 'mvn ${MAVEN_ARGS_PULL}'"
    log_info "Using MAVEN_OPTS '${MAVEN_OPTS}'"
    log_ino "Using $(mvn --version)"

    # Execute the maven pull of dependencies
    mvn $MAVEN_ARGS_PULL
    ERR=$?

    rm -f ${PULL_POM_FILE}

    if [ $ERR -ne 0 ]; then
        log_error "Aborting due to error code $ERR from Maven build"
        exit $ERR
    fi
done

# Remove _remote.repositories files so we can run offline: CLOUD-1839
find ~/.m2/repository -name _remote.repositories | xargs rm

# Necessary to permit running with a randomised UID
chown -R jboss:root ${HOME}/.m2/repository
chmod -R g+rwX ${HOME}/.m2/repository

exit 0
