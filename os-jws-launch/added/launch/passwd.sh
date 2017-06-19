#!/bin/bash

function configure() {
  configure_passwd
}

function configure_passwd() {
  sed "/^jboss/s/[^:]*/$(id -u)/3" /etc/passwd > /tmp/passwd
  cat /tmp/passwd > /etc/passwd
  rm /tmp/passwd
}