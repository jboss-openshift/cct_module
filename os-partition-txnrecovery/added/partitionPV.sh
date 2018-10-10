#!/bin/sh

source $JBOSS_HOME/bin/launch/launch-common.sh

[ "x${SCRIPT_DEBUG}" = "xtrue" ] && DEBUG_QUERY_API_PARAM="-l debug"

# when jdbc object store used for transaction data we can save recovery marker to database too
# TX_JDBC_RECOVERY_MARKER_PERMITTED: can be forced by user
TX_JDBC_RECOVERY_MARKER_PERMITTED=${TX_JDBC_RECOVERY_MARKER_PERMITTED:-true}
# IS_TX_SQL_BACKEND: depends on definition of jdbc credentials to connect to database
IS_TX_SQL_BACKEND=false
if [ -n "${TX_DATABASE_PREFIX_MAPPING}" ] && [ "x$TX_JDBC_RECOVERY_MARKER_PERMITTED" = "xtrue" ]; then
    IS_TX_SQL_BACKEND=true
fi

# parameters
# - needle to search in array
# - array passed as: "${ARRAY_VAR[@]}"
function arrContains() {
  local element match="$1"
  shift
  for element; do
    [[ "$element" == "$match" ]] && return 0
  done
  return 1
}

function init_pod_name() {
  # when POD_NAME is non-zero length using that given name

  # docker sets up container_uuid
  [ -z "${POD_NAME}" ] && POD_NAME="${container_uuid}"
  # openshift sets up the node id as host name
  [ -z "${POD_NAME}" ] && POD_NAME="${HOSTNAME}"

  # having set the POD_NAME is crucial as the processing depends on unique
  # pod name being used as identifier for migration
  if [ -z "${POD_NAME}" ]; then
    >&2 echo "Cannot proceed further as failed to get unique POD_NAME as identifier of the server to be started"
    exit 1
  fi
}

# used to redefine starting jboss.node.name as identifier of jboss container
#   need to be restricted to 23 characters (CLOUD-427)
function truncate_jboss_node_name() {
  local NODE_NAME_TRUNCATED="$1"
  if [ ${#1} -gt 23 ]; then
    NODE_NAME_TRUNCATED=${1: -23}
  fi
  NODE_NAME_TRUNCATED=${NODE_NAME_TRUNCATED##-} # do not start the identifier with '-', it makes bash issues
  echo "${NODE_NAME_TRUNCATED}"
}

# parameters
# - base directory
function partitionPV() {
  local podsDir="$1"
  local applicationPodDir

  mkdir -p "${podsDir}"

  init_pod_name
  local applicationPodDir="${podsDir}/${POD_NAME}"

  $IS_TX_SQL_BACKEND && initJdbcRecoveryMarkerProperties

  local waitCounter=0
  # 2) while any file matching, sleep
  while true; do

    if isRecoveryInProgress; then
      echo "Waiting to start pod ${POD_NAME} as recovery process '$(echo ${podsDir}/${POD_NAME}-RECOVERY-*)' is currently cleaning data directory."
    else
      # no recovery running: we are free to start the app container
      break
    fi

    sleep 1
    echo "`date`: waiting for recovery process to clean the environment for the pod to start"
  done

  # 3) create /pods/<applicationPodName>
  SERVER_DATA_DIR="${applicationPodDir}/serverData"
  mkdir -p "${SERVER_DATA_DIR}"

  if [ ! -f "${SERVER_DATA_DIR}/../data_initialized" ]; then
    init_data_dir ${SERVER_DATA_DIR}
    touch "${SERVER_DATA_DIR}/../data_initialized"
  fi

  # 4) launch server with node name as pod name (openshift-node-name.sh uses the node name value)
  NODE_NAME=$(truncate_jboss_node_name "${POD_NAME}") runServer "${SERVER_DATA_DIR}" &

  PID=$!

  trap "echo Received TERM of pid ${PID} of pod name ${POD_NAME}; kill -TERM $PID" TERM

  wait $PID 2>/dev/null
  STATUS=$?
  trap - TERM
  wait $PID 2>/dev/null

  echo "Server terminated with status $STATUS ($(kill -l $STATUS 2>/dev/null))"

  if [ "$STATUS" -eq 255 ] ; then
    echo "Server returned 255, changing to 254"
    STATUS=254
  fi

  exit $STATUS
}

# parameters
# - base directory
# - migration pause between cycles
function migratePV() {
  local podsDir="$1"
  local applicationPodDir
  MIGRATION_PAUSE="${2:-30}"
  MIGRATED=false

  init_pod_name
  local recoveryPodName="${POD_NAME}"

  $IS_TX_SQL_BACKEND && initJdbcRecoveryMarkerProperties

  while true ; do

    # 1) Periodically, for each /pods/<applicationPodName>
    for applicationPodDir in "${podsDir}"/*; do
      # check if the found file is type of directory, if not directory move to the next item
      [ ! -d "$applicationPodDir" ] && continue

      # 1.a) create the recovery marker
      local applicationPodName="$(basename ${applicationPodDir})"
      createRecoveryMarker "${podsDir}" "${applicationPodName}" "${recoveryPodName}"
      STATUS=42 # expecting there could be  error on getting living pods

      # 1.a.i) if <applicationPodName> is not in the cluster
      echo "examining existence of living pod for directory: '${applicationPodDir}'"
      unset LIVING_PODS
      LIVING_PODS=($($(dirname ${BASH_SOURCE[0]})/queryosapi.py -q pods_living -f list_space ${DEBUG_QUERY_API_PARAM}))
      [ $? -ne 0 ] && echo "ERROR: Can't get list of living pods" && continue
      # expecting the application pod of the same name was started/is living, it will manage recovery on its own
      local IS_APPLICATION_POD_LIVING=true
      if ! arrContains ${applicationPodName} "${LIVING_PODS[@]}"; then

        IS_APPLICATION_POD_LIVING=false

        (
          # 1.a.ii) run recovery until empty (including orphan checks and empty object store hierarchy deletion)
          MIGRATION_POD_TIMESTAMP=$(getPodLogTimestamp)  # investigating on current pod timestamp
          SERVER_DATA_DIR="${applicationPodDir}/serverData"
          NODE_NAME=$(truncate_jboss_node_name "${applicationPodName}") runMigration "${SERVER_DATA_DIR}" &

          PID=$!

          trap "echo Received TERM ; kill -TERM $PID" TERM

          wait $PID 2>/dev/null
          STATUS=$?
          trap - TERM
          wait $PID 2>/dev/null

          echo "Migration terminated with status $STATUS ($(kill -l $STATUS))"

          if [ "$STATUS" -eq 255 ] ; then
            echo "Server returned 255, changing to 254"
            STATUS=254
          fi
          exit $STATUS
        ) &

        PID=$!

        trap "kill -TERM $PID" TERM

        wait $PID 2>/dev/null
        STATUS=$?
        trap - TERM
        wait $PID 2>/dev/null

        if [ $STATUS -eq 0 ]; then
          # 1.a.iii) Delete /pods/<applicationPodName> when recovery was succesful
          echo "`date`: Migration succesfully finished for application directory ${applicationPodDir} thus removing it by recovery pod ${recoveryPodName}"
          rm -rf "${applicationPodDir}"
        fi
      fi

      # 1.b.) Deleting the recovery marker
      if [ $STATUS -eq 0 ] || [ $IS_APPLICATION_POD_LIVING ]; then
        # STATUS is 0: we are free from in-doubt transactions
        # IS_APPLICATION_POD_LIVING is true: there is a running pod of the same name, will do the recovery on his own, recovery pod won't manage it
        removeRecoveryMarker "${podsDir}" "${applicationPodName}" "${recoveryPodName}"
      fi

      # 2) checking for failed recovery pods to clean their data
      recoveryPodsGarbageCollection
    done

    echo "`date`: Finished Migration Check cycle, pausing for ${MIGRATION_PAUSE} seconds before resuming"
    MIGRATION_POD_TIMESTAMP=$(getPodLogTimestamp)
    trap 'kill $(jobs -p)' EXIT
    sleep "${MIGRATION_PAUSE}" & wait
    trap - EXIT
  done
}

# parameters
# - no params
function isRecoveryInProgress() {
  local isRecoveryInProgress=false
  if $IS_TX_SQL_BACKEND; then
    # jdbc based recovery descriptor
    recoveryMarkers=($(${JDBC_RECOVERY_MARKER_COMMAND} select_recovery -a ${POD_NAME}))
    local isRecoveryInProgress=false
    [ ${#recoveryMarkers[@]} -ne 0 ] && isRecoveryInProgress=true # array is not empty, there are recovery markers existing
  else
    # shared file system based recovery descriptor
    find "${podsDir}" -maxdepth 1 -type f -name "${POD_NAME}-RECOVERY-*" 2>/dev/null | grep -q .
    # is there an existing RECOVERY descriptor that means a recovery is in progress
    [ $? -eq 0 ] && isRecoveryInProgress=true
  fi
  $isRecoveryInProgress && return 0 || return 1
}

# parameters
# - place where pod data directories are saved
# - application pod name
# - recovery pod name
function createRecoveryMarker() {
  local podsDir="${1}"
  local applicationPodName="${2}"
  local recoveryPodName="${3}"

  if $IS_TX_SQL_BACKEND; then
    # jdbc recovery marker insertion
    ${JDBC_RECOVERY_MARKER_COMMAND} insert -a ${applicationPodName} -r ${recoveryPodName}
  else
    # file system recovery marker creation: /pods/<applicationPodName>-RECOVERY-<recoveryPodName>
    touch "${podsDir}/${applicationPodName}-RECOVERY-${recoveryPodName}"
    sync
  fi
}

# parameters
# - place where pod data directories are saved (podsDir)
# - application pod name
# - recovery pod name
function removeRecoveryMarker() {
  local podsDir="${1}"
  local applicationPodName="${2}"
  local recoveryPodName="${3}"

  if $IS_TX_SQL_BACKEND; then
    # jdbc recovery marker removal
    ${JDBC_RECOVERY_MARKER_COMMAND} delete -a ${applicationPodName} -r ${recoveryPodName}
  else
    # file system recovery marker deletion
    rm -f "${podsDir}/${applicationPodName}-RECOVERY-${recoveryPodName}"
    sync
  fi
}

# parameters:
# - place where pod data directories are saved (podsDir)
function recoveryPodsGarbageCollection() {
  local livingPods=($($(dirname ${BASH_SOURCE[0]})/queryosapi.py -q pods_living -f list_space ${DEBUG_QUERY_API_PARAM}))
  if [ $? -ne 0 ]; then # fail to connect to openshift api
    echo "ERROR: Can't get list of living pods. Can't do recovery marker garbage collection."
    return 1
  fi

  if $IS_TX_SQL_BACKEND; then
    # jdbc
    local recoveryMarkers=($(${JDBC_RECOVERY_MARKER_COMMAND} select_recovery))
    for recoveryPod in ${recoveryMarkers[@]}; do
      if ! arrContains ${recoveryPod} "${livingPods[@]}"; then
        # recovery pod is dead, garbage collecting
        ${JDBC_RECOVERY_MARKER_COMMAND} delete -r ${recoveryPod}
      fi
    done
  else
    # file system
    for recoveryPodFilePathToCheck in "${podsDir}/"*-RECOVERY-*; do
      local recoveryPodFileToCheck="$(basename ${recoveryPodFilePathToCheck})"
      local recoveryPodNameToCheck=${recoveryPodFileToCheck#*RECOVERY-}
      if ! arrContains ${recoveryPodNameToCheck} "${livingPods[@]}"; then
        # recovery pod is dead, garbage collecting
        rm -f "${recoveryPodFilePathToCheck}"
      fi
    done
  fi
}


# parameters
# - pod name (optional)
function getPodLogTimestamp() {
  init_pod_name
  local podNameToProbe=${1:-$POD_NAME}

  local logOutput=$($(dirname ${BASH_SOURCE[0]})/queryosapi.py -q log --pod ${podNameToProbe} --tailline 1 ${DEBUG_QUERY_API_PARAM})
  # only one, last line of the log, is returned, taking the start which is timestamp
  echo $logOutput | sed 's/ .*$//'
}

# parameters
# - since time (when the pod listing start at)
# - pod name (optional)
function probePodLogForRecoveryErrors() {
  init_pod_name
  local sinceTimestampParam=''
  local sinceTimestamp=${1:-$MIGRATION_POD_TIMESTAMP}
  [ "x$sinceTimestamp" != "x" ] && sinceTimestampParam="--sincetime ${sinceTimestamp}"
  local podNameToProbe=${2:-$POD_NAME}

  local logOutput=$($(dirname ${BASH_SOURCE[0]})/queryosapi.py -q log --pod ${podNameToProbe} ${sinceTimestampParam} ${DEBUG_QUERY_API_PARAM})
  local probeStatus=$?

  if [ $probeStatus -ne 0 ]; then
    echo "Cannot contact OpenShift API to get log for pod ${POD_NAME}"
    return 1
  fi

  local isPeriodicRecoveryError=false
  local patternToCheck="ERROR.*Periodic Recovery"
  # even for debug it's too verbose to print this pattern checking
  [ "x${SCRIPT_DEBUG}" = "xtrue" ] && set +x
  while read line; do
    [[ $line =~ $patternToCheck ]] && isPeriodicRecoveryError=true && break
  done <<< "$logOutput"
  [ "x${SCRIPT_DEBUG}" = "xtrue" ] && set -x

  if $isPeriodicRecoveryError; then # ERROR string was found in the log output
    echo "Pod '${POD_NAME}' started with periodic recovery errors: '$line'"
    return 1
  fi

  return 0
}

# parameters:
# - no params
function initJdbcRecoveryMarkerProperties() {
  tx_backend=${TX_DATABASE_PREFIX_MAPPING}

  service_name=${tx_backend%=*}
  service=${service_name^^}
  service=${service//-/_}
  db=${service##*_}
  prefix=${tx_backend#*=}

  JDBC_RECOVERY_DB_HOST=$(find_env "${service}_SERVICE_HOST")
  JDBC_RECOVERY_DB_PORT=$(find_env "${service}_SERVICE_PORT")
  JDBC_RECOVERY_DATABASE=$(find_env "${prefix}_DATABASE")
  JDBC_RECOVERY_USER=$(find_env "${prefix}_USERNAME")
  JDBC_RECOVERY_PASSWORD=$(find_env "${prefix}_PASSWORD")
  JDBC_RECOVERY_NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
  JDBC_RECOVERY_TABLE="recmark_${TX_JDBC_RECOVERY_MARKER_TABLE_SUFFIX//-/}"

    case "$db" in
    "MYSQL")
      JDBC_RECOVERY_DB_TYPE='mysql'
      ;;
    "POSTGRESQL")
      JDBC_RECOVERY_DB_TYPE='postgresql'
      ;;
  esac

  LOGGING_PROPERTIES="-Djava.util.logging.config.file=$(dirname ${BASH_SOURCE[0]})/logging.properties"
  # do not reduce logging when debug is enabled
  [ "x${SCRIPT_DEBUG}" = "xtrue" ] && LOGGING_PROPERTIES=""

  JDBC_RECOVERY_MARKER_COMMAND="java $LOGGING_PROPERTIES -jar $JBOSS_HOME/jboss-modules.jar -mp $JBOSS_HOME/modules/ io.narayana.openshift-recovery -y ${JDBC_RECOVERY_DB_TYPE} -o ${JDBC_RECOVERY_DB_HOST} -p ${JDBC_RECOVERY_DB_PORT} -d ${JDBC_RECOVERY_DATABASE} -u ${JDBC_RECOVERY_USER} -s ${JDBC_RECOVERY_PASSWORD} -t ${JDBC_RECOVERY_TABLE} -c"
  # creating the database schema
  ${JDBC_RECOVERY_MARKER_COMMAND} create
}
