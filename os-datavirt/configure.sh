#!/bin/sh
# Add default Maven settings with Red Hat/JBoss repositories
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

cp -p ${ADDED_DIR}/standalone-openshift.xml $JBOSS_HOME/standalone/configuration/

cp ${ADDED_DIR}/layers.conf ${JBOSS_HOME}/modules
cp -a ${ADDED_DIR}/launch $JBOSS_HOME/bin
cp -p ${ADDED_DIR}/openshift-launch.sh ${JBOSS_HOME}/bin/

cp ${ADDED_DIR}/readinessProbe.sh $JBOSS_HOME/bin/
cp ${ADDED_DIR}/livenessProbe.sh $JBOSS_HOME/bin/
cp -r ${ADDED_DIR}/probes $JBOSS_HOME/bin/

if [ -f "${JBOSS_HOME}/dataVirtualization/vdb/ModeShape.vdb" ]; then
  cp ${JBOSS_HOME}/dataVirtualization/vdb/ModeShape.vdb ${JBOSS_HOME}/standalone/deployments
  touch ${JBOSS_HOME}/standalone/deployments/ModeShape.vdb.dodeploy
fi

cp ${JBOSS_HOME}/dataVirtualization/vdb/teiid-odata.war ${JBOSS_HOME}/standalone/deployments
cp ${JBOSS_HOME}/dataVirtualization/vdb/teiid-olingo-odata4.war ${JBOSS_HOME}/standalone/deployments

rm -rf ${JBOSS_HOME}/standalone/deployments/integration-platform-console.war*
rm -rf ${JBOSS_HOME}/vault*

find $JBOSS_HOME/modules/system/layers/base -name javax.script.ScriptEngineFactory -exec sed -i "s|com.sun.script.javascript.RhinoScriptEngineFactory||" {} \;

for dir in ${JBOSS_HOME} ${HOME} /deployments; do
  chown -R jboss:root $dir
  chmod -R g+rwX $dir
done