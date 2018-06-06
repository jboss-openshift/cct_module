[ "${SCRIPT_DEBUG}" = "true" ] && DEBUG_QUERY_API_PARAM="-l debug"

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

# parameters
# - base directory
function partitionPV() {
  local podsDir="$1"
  local applicationPodDir

  mkdir -p "${podsDir}"

  init_pod_name
  local applicationPodDir="${podsDir}/${POD_NAME}"

  local waitCounter=0
  # 2) while any file matching, sleep
  while true; do
    local isRecoveryInProgress=false
    # is there an existing RECOVERY descriptor that means a recovery is in progress
    find "${podsDir}" -maxdepth 1 -type f -name "${POD_NAME}-RECOVERY-*" 2>/dev/null | grep -q .
    [ $? -eq 0 ] && isRecoveryInProgress=true

    # we are free to start the app container
    if ! $isRecoveryInProgress; then
      break
    fi

    if $isRecoveryInProgress; then
      echo "Waiting to start pod ${POD_NAME} as recovery process '$(echo ${podsDir}/${POD_NAME}-RECOVERY-*)' is currently cleaning data directory."
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

  # 4) launch EAP with node name as pod name
  #NODE_NAME="${POD_NAME}" runServer "${SERVER_DATA_DIR}" &
  # node name cannot be longer than 23 chars
  runServer "${SERVER_DATA_DIR}" &

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

function init_pod_name() {
  # when POD_NAME is non-zero length using that given name

  # docker sets up container_uuid
  [ -z "${POD_NAME}" ] && POD_NAME="${container_uuid}"
  # openshift sets up the node id as host name
  [ -z "${POD_NAME}" ] && POD_NAME="${HOSTNAME}"
  # TODO: fail when pod name is not set here?
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

  while true ; do

    # 1) Periodically, for each /pods/<applicationPodName>
    for applicationPodDir in "${podsDir}"/*; do
      # check if the found file is type of directory, if not directory move to the next item
      [ ! -d "$applicationPodDir" ] && continue

      # 1.a) create /pods/<applicationPodName>-RECOVERY-<recoveryPodName>
      local applicationPodName="$(basename ${applicationPodDir})"
      touch "${podsDir}/${applicationPodName}-RECOVERY-${recoveryPodName}"
      STATUS=42 # expecting there could be  error on getting living pods

      # 1.a.i) if <applicationPodName> is not in the cluster
      echo "examining existence of living pod for directory: '${applicationPodDir}'"
      unset LIVING_PODS
      LIVING_PODS=($($(dirname ${BASH_SOURCE[0]})/query.py -q pods_living -f list_space ${DEBUG_QUERY_API_PARAM}))
      [ $? -ne 0 ] && echo "ERROR: Can't get list of living pods" && continue
      STATUS=-1 # here we have data about living pods and the recovery marker can be removed if the pod is living
      if ! arrContains ${applicationPodName} "${LIVING_PODS[@]}"; then

        (
          # 1.a.ii) run recovery until empty (including orphan checks and empty object store hierarchy deletion)
          SERVER_DATA_DIR="${applicationPodDir}/serverData"
          JBOSS_NODE_NAME="$applicationPodName"
          if [ ${#JBOSS_NODE_NAME} -gt 23 ]; then
            JBOSS_NODE_NAME=${JBOSS_NODE_NAME: -23}
          fi
          runMigration "${SERVER_DATA_DIR}" &

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
      if [ $STATUS -eq 0 ] || [ $STATUS -eq -1 ]; then
        # STATUS is 0: we are free from in-doubt transactions, -1: there is a running pod of the same name (do the recovery on his own if needed)
        rm -f "${podsDir}/${applicationPodName}-RECOVERY-${recoveryPodName}"
      fi

      # 2) Periodically, for files /pods/<applicationPodName>-RECOVERY-<recoveryPodName>, for failed recovery pods
      for recoveryPodFilePathToCheck in "${podsDir}/"*-RECOVERY-*; do
        local recoveryPodFileToCheck="$(basename ${recoveryPodFilePathToCheck})"
        local recoveryPodNameToCheck=${recoveryPodFileToCheck#*RECOVERY-}

        unset LIVING_PODS
        LIVING_PODS=($($(dirname ${BASH_SOURCE[0]})/query.py -q pods_living -f list_space ${DEBUG_QUERY_API_PARAM}))
        [ $? -ne 0 ] && echo "ERROR: Can't get list of living pods" && continue

        if ! arrContains ${recoveryPodNameToCheck} "${LIVING_PODS[@]}"; then
          # recovery pod is dead, garbage collecting
          rm -f "${recoveryPodFilePathToCheck}"
        fi
      done

    done

    echo "`date`: Finished Migration Check cycle, pausing for ${MIGRATION_PAUSE} seconds before resuming"
    sleep "${MIGRATION_PAUSE}"
  done
}

# parameters
# - pod name (optional)
function probePodLog() {
  init_pod_name
  local podNameToProbe=${1:-$POD_NAME}

  local logOutput=$($(dirname ${BASH_SOURCE[0]})/query.py -q log ${podNameToProbe})
  local probeStatus=$?

  if [ $probeStatus -ne 0 ]; then
    echo "Cannot contact OpenShift API to get log for pod ${POD_NAME}"
    return 1
  fi

  local isPeriodicRecoveryError=false
  local patternToCheck="ERROR.*Periodic Recovery"
  while read line; do
    [[ $line =~ $patternToCheck ]] && isPeriodicRecoveryError=true && break
  done <<< "$logOutput"
  if $isPeriodicRecoveryError; then # ERROR string was found in the log output
    echo "Server at ${NAMESPACE}/${POD_NAME} started with errors"
    return 1
  fi

  return 0
}
