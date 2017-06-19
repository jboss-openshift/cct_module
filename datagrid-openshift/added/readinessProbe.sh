#!/bin/sh

OUTPUT=/tmp/readiness-output
ERROR=/tmp/readiness-error
LOG=/tmp/readiness-log

COUNT=30
SLEEP=1
DEBUG=false
PROBE_IMPL="probe.eap.dmr.EapProbe probe.jdg.jolokia.JdgProbe"

if [ $# -gt 0 ] ; then
    COUNT=$1
fi

if [ $# -gt 1 ] ; then
    SLEEP=$2
fi

if [ $# -gt 2 ] ; then
    DEBUG=$3
fi

if [ $# -gt 3 ] ; then
    PROBE_IMPL=$4
fi

if [ "$DEBUG" = "true" ]; then
    DEBUG_OPTIONS="--debug --logfile $LOG --loglevel DEBUG"
fi

if python $JBOSS_HOME/bin/probes/runner.py -c READY --maxruns $COUNT --sleep $SLEEP $DEBUG_OPTIONS $PROBE_IMPL; then
    exit 0
fi
exit 1

