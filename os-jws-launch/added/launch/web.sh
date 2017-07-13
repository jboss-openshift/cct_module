#!/bin/bash

WEB_XML_FILE="${JWS_HOME}/conf/web.xml"

function prepareEnv() {
  unset JWS_SERVLET_LISTINGS
  unset JWS_SERVLET_READONLY
}

function configure() {
  expand_web_xml
}

function expand_web_xml() {
  if [ -n "$JWS_SERVLET_LISTINGS" ]; then
    sed -i "s|<param-name>listings</param-name><param-value>false</param-value>|<param-name>listings</param-name><param-value>${JWS_SERVLET_LISTINGS}</param-value>|" "${WEB_XML_FILE}" 
  fi

  if [ -n "$JWS_SERVLET_READONLY" ]; then
    sed -i "s|<param-name>readonly</param-name><param-value>true</param-value>|<param-name>readonly</param-name><param-value>${JWS_SERVLET_READONLY}</param-value>|" "${WEB_XML_FILE}"
  fi

}
