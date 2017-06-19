#!/bin/sh

function preConfigure() {
  preconfigure_extensions
}

function postConfigure() {
  postconfigure_extensions
}

function preconfigure_extensions(){
  if [ -f "${JBOSS_HOME}/extensions/preconfigure.sh" ]; then
    ${JBOSS_HOME}/extensions/preconfigure.sh
  fi
}

function postconfigure_extensions(){
  if [ -f "${JBOSS_HOME}/extensions/postconfigure.sh" ]; then
    ${JBOSS_HOME}/extensions/postconfigure.sh
  fi
}
