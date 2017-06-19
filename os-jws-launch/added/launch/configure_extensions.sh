#!/bin/sh

function preConfigure() {
  preconfigure_extensions
}

function postConfigure() {
  postconfigure_extensions
}

function preconfigure_extensions(){
  if [ -f "${JWS_HOME}/extensions/preconfigure.sh" ]; then
    ${JWS_HOME}/extensions/preconfigure.sh
  fi
}

function postconfigure_extensions(){
  if [ -f "${JWS_HOME}/extensions/postconfigure.sh" ]; then
    ${JWS_HOME}/extensions/postconfigure.sh
  fi
}
