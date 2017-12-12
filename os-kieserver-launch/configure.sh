#!/bin/bash
# KIE Server config/install/pull/verify/launch scripts
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR="$SCRIPT_DIR/added"
SOURCES_DIR="/tmp/artifacts"

pushd "$ADDED_DIR" &> /dev/null
    # Necessary to permit running with a randomised UID
    chmod ug+x kieserver-setup.sh kieserver-config.sh kieserver-install.sh kieserver-pull.sh kieserver-verify.sh kieserver-launch.sh ha.sh
    cp -p kieserver-config.sh kieserver-install.sh kieserver-pull.sh kieserver-verify.sh kieserver-launch.sh kieserver-migrate.sh quartz.properties ${JBOSS_HOME}/bin/
    cp -p openshift-common.sh kieserver-setup.sh ha.sh ${JBOSS_HOME}/bin/launch
popd &> /dev/null

# supplementary tools only exist in kieserver > 6.2
if [ -e ${SOURCES_DIR}/jboss-bpmsuite-*-supplementary-tools.zip ]; then
    # Get the DDL files and copy to $JBOSS_HOME/bin/
    unzip -qj ${SOURCES_DIR}/jboss-bpmsuite-*-supplementary-tools.zip jboss-brms-bpmsuite-*-supplementary-tools/ddl-scripts/mysql5/quartz_tables_mysql.sql -d ${SCRIPT_DIR}
    unzip -qj ${SOURCES_DIR}/jboss-bpmsuite-*-supplementary-tools.zip jboss-brms-bpmsuite-*-supplementary-tools/ddl-scripts/postgresql/quartz_tables_postgres.sql -d ${SCRIPT_DIR}
    cp -p ${SCRIPT_DIR}/quartz_tables_mysql.sql ${JBOSS_HOME}/bin/
    cp -p ${SCRIPT_DIR}/quartz_tables_postgres.sql ${JBOSS_HOME}/bin/
fi
