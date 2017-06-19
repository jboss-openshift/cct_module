#!/bin/bash

. /usr/local/dynamic-resources/dynamic_resources.sh

function configure() {
  expand_catalina_opts
}

function expand_catalina_opts() {
    #XXX: we should probably deprecate CATALINA_OPTS_APPEND in favor of
    #     JAVA_OPTS_APPED, which is consistent with the rest of our images.
    CATALINA_OPTS="$CATALINA_OPTS $CATALINA_OPTS_APPEND $(/opt/jolokia/jolokia-opts)"

    CATALINA_OPTS="$(adjust_java_options ${CATALINA_OPTS})"
    
    export CATALINA_OPTS
}
