#!/bin/bash

LOCAL_SOURCE_DIR=/tmp/src

# Resulting WAR files will be deployed to /opt/eap/standalone/deployments
DEPLOY_DIR=$JBOSS_HOME/standalone/deployments

CONFIG_FILE=${JBOSS_HOME}/standalone/configuration/standalone-openshift.xml

function find_env() {
  var=${!1}
  echo "${var:-$2}"
}

function install_deployments(){
  if [ $# != 1 ]; then
    echo "Usage: Directory parameter required"
    return
  fi
  install_dirs=$1

  for install_dir in $(echo $install_dirs | sed "s/,/ /g"); do
    cp -rf ${install_dir}/* $DEPLOY_DIR
  done
}

function install_modules(){
  if [ $# != 1 ]; then
    echo "Usage: Directory parameter required"
    return
  fi
  install_dirs=$1

  for install_dir in $(echo $install_dirs | sed "s/,/ /g"); do
    cp -rf ${install_dir}/* $JBOSS_HOME/modules
  done
}

function configure_drivers(){
  (
    if [ $# == 1 ] && [ -f "$1" ]; then
      source $1
    fi

    drivers=
    if [ -n "$DRIVERS" ]; then
      for driver_prefix in $(echo $DRIVERS | sed "s/,/ /g"); do
        driver_module=$(find_env "${driver_prefix}_DRIVER_MODULE")
        if [ -z "$driver_module" ]; then
          echo "Warning - ${driver_prefix}_DRIVER_MODULE is missing from driver configuration. Driver will not be configured"
          continue
        fi
      
        driver_name=$(find_env "${driver_prefix}_DRIVER_NAME")
        if [ -z "$driver_name" ]; then
          echo "Warning - ${driver_prefix}_DRIVER_NAME is missing from driver configuration. Driver will not be configured"
          continue
        fi

        driver_class=$(find_env "${driver_prefix}_DRIVER_CLASS")
        datasource_class=$(find_env "${driver_prefix}_XA_DATASOURCE_CLASS")
        if [ -z "$driver_class" ] && [ -z "$datasource_class" ]; then
          echo "Warning - ${driver_prefix}_DRIVER_NAME and ${driver_prefix}_XA_DATASOURCE_CLASS is missing from driver configuration. At least one is required. Driver will not be configured"
          continue
        fi

        drivers="${drivers} <driver name=\"$driver_name\" module=\"$driver_module\">"
        if [ -n "$datasource_class" ]; then
          drivers="${drivers}<xa-datasource-class>${datasource_class}</xa-datasource-class>"
        fi

        if [ -n "$driver_class" ]; then
          drivers="${drivers}<driver-class>${driver_class}</driver-class>"
        fi
        drivers="${drivers}</driver>"
      
      done

      if [ -n "$drivers" ]; then
        sed -i "s|<!-- ##DRIVERS## -->|${drivers}<!-- ##DRIVERS## -->|" $CONFIG_FILE
      fi
    fi
  )
}

