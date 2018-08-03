#!/bin/sh
# Openshift EAP common migration script

source ${JBOSS_HOME}/bin/launch/openshift-common.sh
source ${JBOSS_HOME}/bin/probe_common.sh
source /opt/partition/partitionPV.sh

function runMigration() {
  local instanceDir=$1

  # if count provided the node_name should be constructed
  local count=$2
  [ "x$count" != "x" ] && export NODE_NAME="${NODE_NAME:-node}-${count}"

  cp -f ${STANDALONE_XML_COPY} ${STANDALONE_XML}

  source $JBOSS_HOME/bin/launch/configure.sh

  echo "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION"

  local txOptions="-Dcom.arjuna.ats.arjuna.common.RecoveryEnvironmentBean.recoveryBackoffPeriod=1 -Dcom.arjuna.ats.arjuna.common.RecoveryEnvironmentBean.periodicRecoveryPeriod=1 -Dcom.arjuna.ats.jta.common.JTAEnvironmentBean.orphanSafetyInterval=1"
  local terminatingFile="${JBOSS_HOME}/terminatingMigration"

  (runMigrationServer "$instanceDir" "${txOptions}") &

  PID=$!

  rm -f "${terminatingFile}"

  trap "echo Received TERM ; touch \"${terminatingFile}\" ; kill -TERM $PID ; " TERM
  local success=false
  local message="Finished, migration pod has been terminated"
  ${JBOSS_HOME}/bin/readinessProbe.sh
  local probeStatus=$?

  if [ $probeStatus -eq 0 ] ; then
    echo "$(date): Server started, checking for transactions"

    local startTime=$(date +'%s')
    local endTime=$((startTime + ${RECOVERY_TIMEOUT} + 1))

    local socketBinding=$(run_cli_cmd '/subsystem=transactions/:read-attribute(name="socket-binding")' | grep -w result | sed -e 's+^.*=> "++' -e 's+".*$++')
    local recoveryPort=$(run_cli_cmd '/socket-binding-group=standard-sockets/socket-binding='"${socketBinding}"'/:read-attribute(name="bound-port")' | grep -w result | sed -e 's+^.*=> ++')
    local recoveryHost=$(run_cli_cmd '/socket-binding-group=standard-sockets/socket-binding='"${socketBinding}"'/:read-attribute(name="bound-address")' | grep -w result | sed -e 's+^.*=> "++' -e 's+".*$++')

    if [ "${recoveryPort}" != "undefined" ] ; then
      local recoveryClass="com.arjuna.ats.arjuna.tools.RecoveryMonitor"
      recoveryJar=$(find "${JBOSS_HOME}" -name \*.jar | xargs grep -l "${recoveryClass}")
      if [ -n "${recoveryJar}" ] ; then
        echo "$(date): Executing synchronous recovery scan for a first time"
        java -cp "${recoveryJar}" "${recoveryClass}" -host "${recoveryHost}" -port "${recoveryPort}" -timeout 1800000
        echo "$(date): Executing synchronous recovery scan for a second time"
        java -cp "${recoveryJar}" "${recoveryClass}" -host "${recoveryHost}" -port "${recoveryPort}" -timeout 1800000
        echo "$(date): Synchronous recovery scans finished for the first and the second time"
      fi
    fi
  fi

  # -- checking if the pod log is clean from errors (only if function of the particular name exists, provided by the os-partition module)
  if [ $probeStatus -eq 0 ] && [ "$(type -t probePodLogForRecoveryErrors)" = 'function' ]; then
    probePodLogForRecoveryErrors
    probeStatus=$?
    [ $probeStatus -ne 0 ] && echo "The migration container log contains periodic recovery errors, check it for details."
  fi

  if [ $probeStatus -eq 0 ] ; then
    while [ $(date +'%s') -lt $endTime -a ! -f "${terminatingFile}" ] ; do
      run_cli_cmd '/subsystem=transactions/log-store=log-store/:probe' > /dev/null 2>&1
      local transactions="$(run_cli_cmd 'ls /subsystem=transactions/log-store=log-store/transactions')"
      if [ -z "${transactions}" ] ; then
        echo "$(date): No transactions to recover"
        success=true
        break
      fi

      echo "$(date): Waiting for the following transactions: ${transactions}"
      sleep ${RECOVERY_PAUSE}
    done

    if [ "${success}" = "true" ] ; then
      message="Finished, recovery terminated successfully"
    else
      message="Finished, Recovery DID NOT complete, check log for details. Recovery will be reattempted."
    fi
  fi

  if [ ! -f "${terminatingFile}" ] ; then
      run_cli_cmd ':shutdown' >/dev/null 2>&1
  fi
  wait $PID 2>/dev/null
  trap - TERM
  wait $PID 2>/dev/null

  echo "$(date): ${message}"
  if [ "${success}" != "true" ] ; then
    return 64
  else
    return 0
  fi
}

STANDALONE_XML=${JBOSS_HOME}/standalone/configuration/${STANDALONE_XML_FILE:-standalone-openshift.xml}
STANDALONE_XML_COPY=${STANDALONE_XML}.orig

cp -p ${STANDALONE_XML} ${STANDALONE_XML_COPY}

DATA_DIR="${JBOSS_HOME}/standalone/partitioned_data"

migratePV "${DATA_DIR}"
