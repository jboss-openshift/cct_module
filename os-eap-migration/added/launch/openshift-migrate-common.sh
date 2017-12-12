#!/bin/sh
# Openshift EAP common migration script

source ${JBOSS_HOME}/bin/launch/openshift-common.sh
source ${JBOSS_HOME}/bin/probe_common.sh
source /opt/partition/partitionPV.sh

function runMigration() {
  local instanceDir=$1
  local count=$2

  export NODE_NAME="${NODE_NAME:-node}-${count}"
  cp -f ${STANDALONE_XML_COPY} ${STANDALONE_XML}

  source $JBOSS_HOME/bin/launch/configure.sh

  echo "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION"

  local txOptions="-Dcom.arjuna.ats.arjuna.common.RecoveryEnvironmentBean.recoveryBackoffPeriod=1 -Dcom.arjuna.ats.arjuna.common.RecoveryEnvironmentBean.periodicRecoveryPeriod=1 -Dcom.arjuna.ats.jta.JTAEnvironmentBean.orphanSafetyInterval=1"

  (runMigrationServer "$instanceDir" "${txOptions}") &

  PID=$!

  trap "echo Received TERM ; kill -TERM $PID" TERM
  local success=false
  local message=
  ${JBOSS_HOME}/bin/readinessProbe.sh
  if [ $? -eq 0 ] ; then
    echo "$(date): Server started, checking for transactions"
    local startTime=$(date +'%s')
    local endTime=$((startTime + ${RECOVERY_TIMEOUT} + 1))
    while [ $(date +'%s') -lt $endTime ] ; do
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
      message="Finished, Recovery DID NOT complete, check log for details.  Recovery will be reattempted."
    fi
  fi

  run_cli_cmd ':shutdown' >/dev/null 2>&1
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
