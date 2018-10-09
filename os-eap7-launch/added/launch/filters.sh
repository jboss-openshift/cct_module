source $JBOSS_HOME/bin/launch/launch-common.sh
source $JBOSS_HOME/bin/launch/logging.sh

prepareEnv() {
  clear_filters_env
}

configureEnv() {
  configure
}

configure() {
  inject_filters
}

clear_filters_env() {
  for filter_prefix in $(echo $FILTERS | sed "s/,/ /g"); do
    clear_filter_env $filter_prefix
  done
  unset FILTERS
}

clear_filter_env() {
  local prefix=$1
  
  unset ${prefix}_FILTER_REF_NAME
  unset ${prefix}_FILTER_RESPONSE_HEADER_NAME
  unset ${prefix}_FILTER_RESPONSE_HEADER_VALUE
}

# check to see if no already defined FILTER_RESPONSE_HEADERS_MARKER tag
# this is used in the case where no default filters are defined, so we don't
# have an empty <filters/> element in the config, or expect it to be there
has_filter_placeholder_tag() {
    if grep -q '<!-- ##HTTP_FILTERS_MARKER## -->' "${CONFIG_FILE}"
    then
        echo "true"
    else
       echo "false"
    fi
}

# <!-- ##HTTP_FILTERS_MARKER## -->
insert_filter_tag() {
    sed -i "s|<!-- ##HTTP_FILTERS_MARKER## -->|<filters><!-- ##FILTER_RESPONSE_HEADERS## --></filters>|" $CONFIG_FILE
}

inject_filters() {
  # Add extensions from envs
  if [ -n "$FILTERS" ]; then
    for filter_prefix in $(echo $FILTERS | sed "s/,/ /g"); do
      inject_filter $filter_prefix
    done
  fi
}

inject_filter() {
  local prefix=$1
  
  local refName=$(find_env "${prefix}_FILTER_REF_NAME")
  local responseHeaderName=$(find_env "${prefix}_FILTER_RESPONSE_HEADER_NAME")
  local responseHeaderValue=$(find_env "${prefix}_FILTER_RESPONSE_HEADER_VALUE")

  if [ -z "$refName" ]; then
    refName="${responseHeaderName}"
  fi

  if [ -z "$responseHeaderName" ] || [ -z "$responseHeaderValue" ]; then
    log_warning "Ooops, there is a problem with a filter!"
    log_warning "In order to configure the $prefix filter you need to provide following environment variables: ${prefix}_FILTER_RESPONSE_HEADER_NAME and ${prefix}_FILTER_RESPONSE_HEADER_VALUE"
    log_warning
    log_warning "Current values:"
    log_warning
    log_warning "${prefix}_FILTER_REF_NAME: $refName"
    log_warning "${prefix}_FILTER_RESPONSE_HEADER_NAME: $responseHeaderName"
    log_warning "${prefix}_FILTER_RESPONSE_HEADER_VALUE: $responseHeaderValue"
    log_warning
    log_warning "The $prefix filter WILL NOT be configured."
    continue
  fi

  # we may have the comment as marker, but no existing filters, if thats the case insert the <filters></filters> skeleton now.
  if [ "true" = $(has_filter_placeholder_tag) ]; then
    insert_filter_tag
  fi

  local filterRef=$(generate_filter_ref "$refName")
  local responseHeader=$(generate_response_header "$refName" "$responseHeaderName" "$responseHeaderValue")

  sed -i "s|<!-- ##FILTER_REFS## -->|${filterRef}\n<!-- ##FILTER_REFS## -->|" $CONFIG_FILE
  sed -i "s|<!-- ##FILTER_RESPONSE_HEADERS## -->|${responseHeader}\n<!-- ##FILTER_RESPONSE_HEADERS## -->|" $CONFIG_FILE
}

generate_filter_ref() {
  local refName=$1
  local filterRef="<filter-ref name=\"${refName}\"/>"
  echo $filterRef | sed ':a;N;$!ba;s|\n|\\n|g'
}

generate_response_header() {
  local refName=$1
  local responseHeaderName=$2
  local responseHeaderValue=$3
  local responseHeader="<response-header name=\"${refName}\" header-name=\"${responseHeaderName}\" header-value=\"${responseHeaderValue}\"/>"
  echo $responseHeader | sed ':a;N;$!ba;s|\n|\\n|g'
}
