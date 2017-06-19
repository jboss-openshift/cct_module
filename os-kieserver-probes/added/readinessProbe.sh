#!/bin/sh
# if using vim, do ':set ft=zsh' for easier reading

OUTPUT=/tmp/readiness-kie-output
ERROR=/tmp/readiness-kie-error
LOG=/tmp/readiness-kie-log

COUNT_ORIG=30
SLEEP=1
DEBUG_SCRIPT=false

if [ $# -gt 0 ] ; then
    COUNT_ORIG=$1
fi

if [ $# -gt 1 ] ; then
    SLEEP=$2
fi

if [ $# -gt 2 ] ; then
    DEBUG_SCRIPT=$3
fi

# Execute the parent readiness probe
$JBOSS_HOME/bin/readinessProbe_eap.sh $COUNT_ORIG $SLEEP $DEBUG_SCRIPT
EAP_RESULT=$?

# If the parent readiness probe was not successful, we don't have to continue
if [ $EAP_RESULT -ne 0 ] ; then
    exit $EAP_RESULT
fi

# source the KIE config
source $JBOSS_HOME/bin/kieserver-config.sh
# set the KIE environment
source ${JBOSS_HOME}/kieEnv

if [ true = "${DEBUG_SCRIPT}" ] ; then
    # dump the KIE environment
    dumpKieFullEnv >> ${LOG}
fi

# Check for required KIE capabilities
COUNT=$COUNT_ORIG
while : ; do
    curl -s -L -k --noproxy '*' --basic --user "${KIE_SERVER_USER}:${KIE_SERVER_PASSWORD}" ${KIE_SERVER_LOCATION} > ${OUTPUT} 2>${ERROR}
    CONNECT_RESULT=$?
    GREP_RESULT=0
    CAPABILITIES="KieServer"
    if [ false = "${KIE_SERVER_BPM_DISABLED}" ] ; then
        CAPABILITIES=${CAPABILITIES}" BPM"
    fi
    if [ false = "${KIE_SERVER_BRM_DISABLED}" ] ; then
        CAPABILITIES=${CAPABILITIES}" BRM"
    fi
    for CAPABILITY in ${CAPABILITIES} ;
    do
        GREP_SEARCH="<capabilities>${CAPABILITY}</capabilities>"
        if [ true = "${DEBUG_SCRIPT}" ] ; then
            (
                echo "$(date) Grepping for: ${GREP_SEARCH}"
            ) >> ${LOG}
        fi
        (cat ${OUTPUT} | grep -q "${GREP_SEARCH}")
        GREP_RESULT=$?
        if [ $GREP_RESULT -ne 0 ] ; then
            break
        fi
    done
    if [ true = "${DEBUG_SCRIPT}" ] ; then
        (
            echo "$(date) Connect: ${CONNECT_RESULT}, Grep: ${GREP_RESULT}"
            echo "========================= OUTPUT ========================="
            cat ${OUTPUT}
            echo "========================= ERROR =========================="
            cat ${ERROR}
            echo "=========================================================="
        ) >> ${LOG}
    fi
    CAPABILITY_CHECK=$(cat ${OUTPUT} | grep "capabilities")
    rm -f ${OUTPUT} ${ERROR}
    if [ ${GREP_RESULT} -eq 0 ] ; then
        # passed KIE capability check
        break;
    fi
    COUNT=$(expr $COUNT - 1)
    if [ $COUNT -eq 0 ] ; then
        # failed KIE capability check
        echo "KIE capability check ${CAPABILITY_CHECK}"
        exit 1;
    fi
    sleep ${SLEEP}
done

# Check for started KIE Containers
COUNT=$COUNT_ORIG
while : ; do
    curl -s -L -k --noproxy '*' --basic --user "${KIE_SERVER_USER}:${KIE_SERVER_PASSWORD}" ${KIE_SERVER_LOCATION}/containers > ${OUTPUT} 2>${ERROR}
    CONNECT_RESULT=$?
    GREP_RESULT=0
    for (( i=0; i<${KIE_CONTAINER_DEPLOYMENT_COUNT}; i++ ));
    do
        GREP_SEARCH="container-id=\"$(getKieContainerVal ID ${i})\" status=\"STARTED\""
        if [ true = "${DEBUG_SCRIPT}" ] ; then
            (
                echo "$(date) Grepping for: ${GREP_SEARCH}"
            ) >> ${LOG}
        fi
        (cat ${OUTPUT} | grep -q "${GREP_SEARCH}")
        GREP_RESULT=$?
        if [ $GREP_RESULT -ne 0 ] ; then
            break
        fi
    done
    if [ true = "${DEBUG_SCRIPT}" ] ; then
        (
            echo "$(date) Connect: ${CONNECT_RESULT}, Grep: ${GREP_RESULT}"
            echo "========================= OUTPUT ========================="
            cat ${OUTPUT}
            echo "========================= ERROR =========================="
            cat ${ERROR}
            echo "=========================================================="
        ) >> ${LOG}
    fi
    CONTAINER_STATUS=$(cat ${OUTPUT} | grep "container-id")
    rm -f ${OUTPUT} ${ERROR}
    if [ ${GREP_RESULT} -eq 0 ] ; then
        # passed KIE container check
        break;
    fi
    COUNT=$(expr $COUNT - 1)
    if [ $COUNT -eq 0 ] ; then
        # failed KIE container check
        echo "KIE container status ${CONTAINER_STATUS}"
        exit 1;
    fi
    sleep ${SLEEP}
done

exit 0;
