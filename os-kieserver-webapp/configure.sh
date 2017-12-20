#!/bin/bash
# Add KIE Server web app
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR="${SCRIPT_DIR}/added"
ADDED_METAINF_DIR="${ADDED_DIR}/META-INF"
ADDED_WEBINF_DIR="${ADDED_DIR}/WEB-INF"
SOURCES_DIR="/tmp/artifacts"

BPMSUITE_BASE_DIR="jboss-eap-6.4"
KIE_SERVER_WAR_DIR="${BPMSUITE_BASE_DIR}/standalone/deployments/kie-server.war"
# asterix in WAR_PATH includes kie-server.war/ and kie-server.war.dodeploy
KIE_SERVER_WAR_PATH="${KIE_SERVER_WAR_DIR}*"
KIE_SERVER_METAINF_DIR="${KIE_SERVER_WAR_DIR}/META-INF"
KIE_SERVER_WEBINF_DIR="${KIE_SERVER_WAR_DIR}/WEB-INF"

if [ -e "${SOURCES_DIR}/jboss-bpmsuite-${BPMSUITE_BASE_VERSION}-deployable-eap6.x.zip" ]; then
    unzip -q ${SOURCES_DIR}/jboss-bpmsuite-${BPMSUITE_BASE_VERSION}-deployable-eap6.x.zip ${KIE_SERVER_WAR_PATH}
    # only install patch over this version
    BPMSUITE_PATCH_DIR="jboss-bpmsuite-${BPMSUITE_PATCH_VERSION}-patch"
    BPMSUITE_PATCH_ZIP="${SOURCES_DIR}/${BPMSUITE_PATCH_DIR}.zip"
    if [ -e "${BPMSUITE_PATCH_ZIP}" ]; then
        unzip -q ${BPMSUITE_PATCH_ZIP}
        pushd "$BPMSUITE_PATCH_DIR" &> /dev/null
            # has to be executed from '.'
            ./apply-updates.sh ../${KIE_SERVER_WAR_DIR} generic-kie-server
            # no need to keep the backup directory around
            rm -rf ./backup
        popd &> /dev/null
        rm -rf ${BPMSUITE_PATCH_DIR}
    fi
fi

cp -f -p ${SOURCES_DIR}/openshift-kieserver-common-${OPENSHIFT_KIESERVER_VERSION}.jar ${KIE_SERVER_WEBINF_DIR}/lib/openshift-kieserver-common-${OPENSHIFT_KIESERVER_VERSION}.jar
cp -f -p ${SOURCES_DIR}/openshift-kieserver-jms-${OPENSHIFT_KIESERVER_VERSION}.jar ${KIE_SERVER_WEBINF_DIR}/lib/openshift-kieserver-jms-${OPENSHIFT_KIESERVER_VERSION}.jar
cp -f -p ${SOURCES_DIR}/openshift-kieserver-web-${OPENSHIFT_KIESERVER_VERSION}.jar ${KIE_SERVER_WEBINF_DIR}/lib/openshift-kieserver-web-${OPENSHIFT_KIESERVER_VERSION}.jar
chmod 664 "${KIE_SERVER_WEBINF_DIR}/lib/openshift-kieserver-common-${OPENSHIFT_KIESERVER_VERSION}.jar"
chmod 664 "${KIE_SERVER_WEBINF_DIR}/lib/openshift-kieserver-jms-${OPENSHIFT_KIESERVER_VERSION}.jar"
chmod 664 "${KIE_SERVER_WEBINF_DIR}/lib/openshift-kieserver-web-${OPENSHIFT_KIESERVER_VERSION}.jar"

cp -f -p ${ADDED_WEBINF_DIR}/ejb-jar.xml ${KIE_SERVER_WEBINF_DIR}/ejb-jar.xml
cp -f -p ${ADDED_WEBINF_DIR}/jboss-deployment-structure.xml ${KIE_SERVER_WEBINF_DIR}/jboss-deployment-structure.xml
cp -f -p ${ADDED_WEBINF_DIR}/security-filter-rules.properties ${KIE_SERVER_WEBINF_DIR}/security-filter-rules.properties
cp -f -p ${ADDED_WEBINF_DIR}/web.xml ${KIE_SERVER_WEBINF_DIR}/web.xml
# needs to be overwritten by kieserver-launch.sh
chmod 666 "${KIE_SERVER_WEBINF_DIR}/ejb-jar.xml"
chmod 664 "${KIE_SERVER_WEBINF_DIR}/jboss-deployment-structure.xml"
chmod 664 "${KIE_SERVER_WEBINF_DIR}/security-filter-rules.properties"
chmod 664 "${KIE_SERVER_WEBINF_DIR}/web.xml"

cp -f -p ${ADDED_METAINF_DIR}/kie-server-jms.xml ${KIE_SERVER_METAINF_DIR}/kie-server-jms.xml
# needs to be overwritten by kieserver-launch.sh
chmod 666 "${KIE_SERVER_METAINF_DIR}/kie-server-jms.xml"

# temp files need to be created by kieserver-launch.sh
chmod 777 "${KIE_SERVER_WEBINF_DIR}"
chmod 777 "${KIE_SERVER_METAINF_DIR}"

chown -R jboss:root ${KIE_SERVER_WAR_PATH}
mkdir -p ${JBOSS_HOME}/standalone/deployments

cp -r -p ${KIE_SERVER_WAR_PATH} ${JBOSS_HOME}/standalone/deployments
rm -rf ${BPMSUITE_BASE_DIR}

chown -R jboss:root ${JBOSS_HOME}/standalone/deployments
chmod -R g+rwX ${JBOSS_HOME}/standalone/deployments
