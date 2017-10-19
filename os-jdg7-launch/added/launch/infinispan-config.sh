# Openshift Datagrid launch script routines for configuring infinispan

source $JBOSS_HOME/bin/launch/logging.sh

CACHE_CONTAINER_FILE=$JBOSS_HOME/bin/launch/cache-container.xml

function clear_prefix() {
  local prefix="$1"
  unset ${prefix}_CACHE_MODE
  unset ${prefix}_CACHE_START
  unset ${prefix}_CACHE_BATCHING
  unset ${prefix}_CACHE_STATISTICS
  unset ${prefix}_CACHE_QUEUE_SIZE
  unset ${prefix}_CACHE_QUEUE_FLUSH_INTERVAL
  unset ${prefix}_CACHE_REMOTE_TIMEOUT
  unset ${prefix}_CACHE_TYPE
  unset ${prefix}_CACHE_OWNERS
  unset ${prefix}_CACHE_SEGMENTS
  unset ${prefix}_CACHE_L1_LIFESPAN
  unset ${prefix}_CACHE_EVICTION_STRATEGY
  unset ${prefix}_CACHE_EVICTION_MAX_ENTRIES
  unset ${prefix}_CACHE_EXPIRATION_LIFESPAN
  unset ${prefix}_CACHE_EXPIRATION_MAX_IDLE
  unset ${prefix}_CACHE_EXPIRATION_INTERVAL
  unset ${prefix}_LOCKING_ACQUIRE_TIMEOUT
  unset ${prefix}_LOCKING_CONCURRENCY_LEVEL
  unset ${prefix}_LOCKING_STRIPING
  unset ${prefix}_CACHE_INDEX
  unset ${prefix}_INDEXING_PROPERTIES
  unset ${prefix}_CACHE_SECURITY_AUTHORIZATION_ENABLED
  unset ${prefix}_CACHE_SECURITY_AUTHORIZATION_ROLES
  unset ${prefix}_CACHE_PARTITION_HANDLING_ENABLED
  unset ${prefix}_JDBC_STORE_TYPE
  unset ${prefix}_KEYED_TABLE_PREFIX
  unset ${prefix}_JDBC_STORE_DATASOURCE
  unset ${prefix}_ID_TYPE
  unset ${prefix}_DATA_TYPE
  unset ${prefix}_TIMESTAMP_TYPE
}

function prepareEnv() {
  # server identities
  unset SSL_KEYSTORE_PATH
  unset SSL_KEYSTORE_RELATIVE_TO
  unset HTTPS_KEYSTORE
  unset SSL_KEYSTORE_PASSWORD
  unset HTTPS_PASSWORD
  unset SECRET_VALUE
  unset SSL_KEYSTORE_ALIAS
  unset SSL_KEY_PASSWORD
  unset SSL_PROTOCOL

  # core
  unset CACHE_CONTAINER_START
  unset CACHE_CONTAINER_STATISTICS
  unset TRANSPORT_LOCK_TIMEOUT
  unset MEMCACHED_CACHE
  unset DEFAULT_CACHE
  
  unset containersecurity
  unset CONTAINER_SECURITY_ROLE_MAPPER
  unset CONTAINER_SECURITY_CUSTOM_ROLE_MAPPER_CLASS
  unset CONTAINER_SECURITY_ROLES

  IFS=',' read -a cachenames <<< "$CACHE_NAMES"
  for cachename in ${cachenames[@]}; do
    clear_prefix $cachename
  done
  unset CACHE_NAMES

  IFS=',' read -a cachenames <<< "$DATAVIRT_CACHE_NAMES"
  for cachename in ${cachenames[@]}; do
    clear_prefix ${cachename}
    clear_prefix ${cachename}_staging
    clear_prefix ${cachename}_alias
  done
  unset DATAVIRT_CACHE_NAMES

  # endpoints
  unset INFINISPAN_CONNECTORS
  unset HOTROD_SERVICE_NAME
  unset HOTROD_AUTHENTICATION
  unset HOTROD_ENCRYPTION
  unset ENCRYPTION_REQUIRE_SSL_CLIENT_AUTH
  unset MEMCACHED_CACHE
  unset REST_SECURITY_DOMAIN
}

function configure() {
  configure_server_identities
  configure_infinispan_core
  process_cache_names
  configure_infinispan_endpoint
}

function configureEnv() {
  process_cache_names
}

function configure_server_identities() {
  local keystore_path
  local keystore_relative_to
  local keystore_password
  local keystore_alias
  local key_password
  local ssl_protocol

  if [ -n "$SSL_KEYSTORE_PATH" ]; then
    log_info "Using SSL_KEYSTORE_PATH to configure HotRod SSL keystore"
    keystore_path="$SSL_KEYSTORE_PATH"
    keystore_relative_to="$SSL_KEYSTORE_RELATIVE_TO"
  elif [ -n "$HTTPS_KEYSTORE" ]; then
    log_info "Using HTTPS_KEYSTORE to configure HotRod SSL keystore"
    keystore_path="${HTTPS_KEYSTORE_DIR}/${HTTPS_KEYSTORE}"
    keystore_relative_to=""
  fi

  if [ -n "$SSL_KEYSTORE_PASSWORD" ]; then
    log_info "Using SSL_KEYSTORE_PASSWORD for the HotRod SSL keystore"
    keystore_password="$SSL_KEYSTORE_PASSWORD"
  elif [ -n "$HTTPS_PASSWORD" ] ; then
    lof_info "Using HTTPS_PASSWORD for the HotRod SSL keystore"
    keystore_password="$HTTPS_PASSWORD"
  fi

  if [ -z "$keystore_path" -o -z "$keystore_password" ]; then
    if [ -z "$keystore_path$keystore_password" ]; then
      log_info "HotRod SSL will not be configured due to the absense of variables SSL_KEYSTORE_PATH and SSL_KEYSTORE_PASSWORD."
    else
      log_warning "HotRod SSL will not be configured due to misconfiguration of the variables SSL_KEYSTORE_PATH and SSL_KEYSTORE_PASSWORD. Both must be set."
    fi
  fi

  if [ -n "$keystore_path$SECRET_VALUE" ]; then
    if [ -n "$keystore_path" -a -n "$keystore_password" ]; then
      if [ -n "$SSL_PROTOCOL" ]; then
        ssl_protocol="protocol=\"$SSL_PROTOCOL\""
      fi
      if [ -n "$keystore_relative_to" ]; then
        keystore_relative_to="relative-to=\"$keystore_relative_to\""
      fi
      if [ -n "$SSL_KEYSTORE_ALIAS" ]; then
        keystore_alias="alias=\"$SSL_KEYSTORE_ALIAS\""
      fi
      if [ -n "$SSL_KEY_PASSWORD" ]; then
        key_password="key-password=\"$SSL_KEY_PASSWORD\""
      fi
      ssl="\
          <ssl $ssl_protocol>\
            <keystore path=\"$keystore_path\" keystore-password=\"$keystore_password\" $keystore_relative_to $keystore_alias $key_password/>\
          </ssl>"
    fi
    if [ -n "$SECRET_VALUE" ]; then
      secret="\
          <secret value=\"$SECRET_VALUE\"/>"
    fi
    serverids="\
        <server-identities>$ssl$secret\
        </server-identities>"
    sed -i "s|<!-- ##SERVER_IDENTITIES## -->|$serverids|" "$CONFIG_FILE"
  fi
}

function configure_infinispan_core() {
  local cache_container_start
  local cache_container_statistics
  local locktimeout
  local cache_names
  local first_cache

  if [ -n "$CACHE_CONTAINER_START" ]; then
    cache_container_start="start=\"$CACHE_CONTAINER_START\""
  fi
  if [ -n "$CACHE_CONTAINER_STATISTICS" ]; then
    cache_container_statistics="statistics=\"$CACHE_CONTAINER_STATISTICS\""
  fi
  if [ -n "$TRANSPORT_LOCK_TIMEOUT" ]; then
    locktimeout=" lock-timeout=\"$TRANSPORT_LOCK_TIMEOUT\""
  fi
  # We must always have a transport for a clustered cache otherwise it is treated as a local cache
  
  transport="\
                <transport channel=\"cluster\" $locktimeout/>"

  if [ -z "$CACHE_NAMES" ]; then
    CACHE_NAMES="default"
    if [ -z "$MEMCACHED_CACHE" ]; then
      MEMCACHED_CACHE="memcached"
    fi
  fi

  if [ -n "$MEMCACHED_CACHE" ]; then
    echo ${CACHE_NAMES} | grep --quiet "${MEMCACHED_CACHE}"
    if [ $? == 1 ]; then
      CACHE_NAMES="${CACHE_NAMES},${MEMCACHED_CACHE}"
    fi
  fi

  # this will configure variables for each of the specified datavirt caches
  define_datavirt_caches

  IFS=',' read -a cachenames <<< "$CACHE_NAMES"
  if [ "${#cachenames[@]}" -ne "0" ]; then
    first_cache=${cachenames[0]}
    export DEFAULT_CACHE=${DEFAULT_CACHE:-$first_cache}
  fi

  configure_container_security

  local containers="<cache-container name=\"clustered\" default-cache=\"$DEFAULT_CACHE\" $cache_container_start $cache_container_statistics>"
  containers="$containers $transport"
  local cache_container_configuration=$(cat "${CACHE_CONTAINER_FILE}" | sed ':a;N;$!ba;s|\n|\\n|g')
  containers="$containers ${cache_container_configuration}"
  containers="$containers $containersecurity <!-- ##INFINISPAN_CACHE## --></cache-container>"

  sed -i "s|<!-- ##INFINISPAN_CORE## -->|$containers|" "$CONFIG_FILE"

}

function process_cache_names() {
  IFS=',' read -a cachenames <<< "$CACHE_NAMES"
  if [ "${#cachenames[@]}" -ne "0" ]; then
    for cachename in ${cachenames[@]}; do
      configure_cache $cachename
    done
  fi
}

function configure_cache() {
  local CACHE_NAME=$1
  local prefix=${1^^}
  local CACHE_MODE=$(find_env "${prefix}_CACHE_MODE" "SYNC")

  local CACHE_TYPE=$(find_env "${prefix}_CACHE_TYPE" "${CACHE_TYPE_DEFAULT:-distributed}")

  if [ -n "$(find_env "${prefix}_CACHE_START")" ]; then
    local CACHE_START="start=\"$(find_env "${prefix}_CACHE_START")\""
  fi
  if [ -n "$(find_env "${prefix}_CACHE_BATCHING")" ]; then
    local CACHE_BATCHING="batching=\"$(find_env "${prefix}_CACHE_BATCHING")\""
  fi
  if [ -n "$(find_env "${prefix}_CACHE_STATISTICS")" ]; then
    local CACHE_STATISTICS="statistics=\"$(find_env "${prefix}_CACHE_STATISTICS")\""
  fi
  if [ -n "$(find_env "${prefix}_CACHE_REMOTE_TIMEOUT")" ]; then
    local CACHE_REMOTE_TIMEOUT="remote-timeout=\"$(find_env "${prefix}_CACHE_REMOTE_TIMEOUT")\""
  fi
  if [ "$CACHE_TYPE" = "distributed" ]; then
    if [ -n "$(find_env "${prefix}_CACHE_OWNERS")" ]; then
      local CACHE_OWNERS="owners=\"$(find_env "${prefix}_CACHE_OWNERS")\""
    fi
    if [ -n "$(find_env "${prefix}_CACHE_SEGMENTS")" ]; then
      local CACHE_SEGMENTS="segments=\"$(find_env "${prefix}_CACHE_SEGMENTS")\""
    fi
    if [ -n "$(find_env "${prefix}_CACHE_L1_LIFESPAN")" ]; then
      local CACHE_L1_LIFESPAN="l1-lifespan=\"$(find_env "${prefix}_CACHE_L1_LIFESPAN")\""
    fi
  fi
  if [ -n "$(find_env "${prefix}_CACHE_EVICTION_STRATEGY")$(find_env "${prefix}_CACHE_EVICTION_MAX_ENTRIES")" ]; then
    if [ -n "$(find_env "${prefix}_CACHE_EVICTION_STRATEGY")" ]; then
      local CACHE_EVICTION_STRATEGY="strategy=\"$(find_env "${prefix}_CACHE_EVICTION_STRATEGY")\""
    fi
    if [ -n "$(find_env "${prefix}_CACHE_EVICTION_MAX_ENTRIES")" ]; then
      local CACHE_EVICTION_MAX_ENTRIES="size=\"$(find_env "${prefix}_CACHE_EVICTION_MAX_ENTRIES")\""
    fi

    local eviction="\
                    <eviction $CACHE_EVICTION_STRATEGY $CACHE_EVICTION_MAX_ENTRIES/>"
  fi
  if [ -n "$(find_env "${prefix}_CACHE_EXPIRATION_LIFESPAN")$(find_env "${prefix}_CACHE_EXPIRATION_MAX_IDLE")$(find_env "${prefix}_CACHE_EXPIRATION_INTERVAL")" ]; then
    if [ -n "$(find_env "${prefix}_CACHE_EXPIRATION_LIFESPAN")" ]; then
      local CACHE_EXPIRATION_LIFESPAN="lifespan=\"$(find_env "${prefix}_CACHE_EXPIRATION_LIFESPAN")\""
    fi
    if [ -n "$(find_env "${prefix}_CACHE_EXPIRATION_MAX_IDLE")" ]; then
      local CACHE_EXPIRATION_MAX_IDLE="max-idle=\"$(find_env "${prefix}_CACHE_EXPIRATION_MAX_IDLE")\""
    fi
    if [ -n "$(find_env "${prefix}_CACHE_EXPIRATION_INTERVAL")" ]; then
      local CACHE_EXPIRATION_INTERVAL="interval=\"$(find_env "${prefix}_CACHE_EXPIRATION_INTERVAL")\""
    fi

    local expiration="\
                    <expiration $CACHE_EXPIRATION_LIFESPAN $CACHE_EXPIRATION_MAX_IDLE $CACHE_EXPIRATION_INTERVAL/>"
  fi

  if [ -n "$(find_env "${prefix}_LOCKING_ACQUIRE_TIMEOUT")$(find_env "${prefix}_LOCKING_CONCURRENCY_LEVEL")$(find_env "${prefix}_LOCKING_STRIPING")" ]; then
    local locking="<locking"
    if [ -n "$(find_env "${prefix}_LOCKING_ACQUIRE_TIMEOUT")" ]; then
      locking="$locking acquire-timeout=\"$(find_env "${prefix}_LOCKING_ACQUIRE_TIMEOUT")\""
    fi

    if [ -n "$(find_env "${prefix}_LOCKING_CONCURRENCY_LEVEL")" ]; then
      locking="$locking concurrency-level=\"$(find_env "${prefix}_LOCKING_CONCURRENCY_LEVEL")\""
    fi

    if [ -n "$(find_env "${prefix}_LOCKING_STRIPING")" ]; then
      locking="$locking striping=\"$(find_env "${prefix}_LOCKING_STRIPING")\""
    fi

    locking="$locking />"
  fi

  if [ -n "$(find_env "${prefix}_CACHE_INDEX")$(find_env "${prefix}_INDEXING_PROPERTIES")" ]; then
    if [ -n "$(find_env "${prefix}_CACHE_INDEX")" ]; then
      local index="index=\"$(find_env "${prefix}_CACHE_INDEX")\""
    fi
    if [ -n "${prefix}_INDEXING_PROPERTIES" ]; then
      IFS=',' read -a properties <<< "$(find_env "${prefix}_INDEXING_PROPERTIES")"
      if [ "${#properties[@]}" -ne "0" ]; then
        for property in ${properties[@]}; do
          local name=${property%=*}
          local value=${property#*=}
          local indexingprops+="\
                        <property name=\"$name\">$value</property>"
        done
      fi
    fi

    local indexing="\
                    <indexing $index>$indexingprops\
                    </indexing>"
  fi
  if [ -n "$(find_env "${prefix}_CACHE_SECURITY_AUTHORIZATION_ENABLED")$(find_env "${prefix}_CACHE_SECURITY_AUTHORIZATION_ROLES")" ]; then
    if [ -n "$(find_env "${prefix}_CACHE_SECURITY_AUTHORIZATION_ENABLED")" ]; then
      local CACHE_SECURITY_AUTHORIZATION_ENABLED="enabled=\"$(find_env "${prefix}_CACHE_SECURITY_AUTHORIZATION_ENABLED")\""
    fi
    if [ -n "$(find_env "${prefix}_CACHE_SECURITY_AUTHORIZATION_ROLES")" ]; then
      local roles="$(find_env "${prefix}_CACHE_SECURITY_AUTHORIZATION_ROLES")"
      local CACHE_SECURITY_AUTHORIZATION_ROLES="roles=\"${roles//,/ }\""
    fi

    local cachesecurity="\
                    <security>\
                      <authorization $CACHE_SECURITY_AUTHORIZATION_ENABLED $CACHE_SECURITY_AUTHORIZATION_ROLES/>\
                    </security>"
  fi
  if [ -n "$(find_env "${prefix}_CACHE_PARTITION_HANDLING_ENABLED")" ]; then
    local partitionhandling="\
                    <partition-handling enabled=\"$(find_env "${prefix}_CACHE_PARTITION_HANDLING_ENABLED")\"/>"
  fi

  configure_jdbc_store $1

  local cache="\
                <$CACHE_TYPE-cache name=\"$CACHE_NAME\""

  if [ "$CACHE_TYPE" != "local" ]; then
    cache="$cache mode=\"$CACHE_MODE\" $CACHE_QUEUE_SIZE $CACHE_QUEUE_FLUSH_INTERVAL $CACHE_REMOTE_TIMEOUT"
  fi

  if [ "$CACHE_PROTOCOL_COMPATIBILITY" == "true" ]; then
    compatibility="<compatibility enabled=\"true\"/>"
  fi

  cache="$cache $CACHE_START $CACHE_BATCHING $CACHE_STATISTICS  $CACHE_OWNERS $CACHE_SEGMENTS $CACHE_L1_LIFESPAN>$eviction $expiration $jdbcstore $indexing $cachesecurity $partitionhandling $locking $compatibility\
                </$CACHE_TYPE-cache><!-- ##INFINISPAN_CACHE## -->"

  sed -i "s|<!-- ##INFINISPAN_CACHE## -->|$cache|" "$CONFIG_FILE"

}

#
# Defines the default variables for a datavirt cache.
#
function define_datavirt_cache_variables() {
  local cache_name=$1
  local configureIndexing=$2
  local prefix=${cache_name^^}

  if [ -z "$(eval echo \$${prefix}_CACHE_START)" ]; then
    eval ${prefix}_CACHE_START=EAGER
  fi
  if [ -z "$(eval echo \$${prefix}_LOCKING_ACQUIRE_TIMEOUT)" ]; then
    eval ${prefix}_LOCKING_ACQUIRE_TIMEOUT=20000
  fi
  if [ -z "$(eval echo \$${prefix}_LOCKING_CONCURRENCY_LEVEL)" ]; then
    eval ${prefix}_LOCKING_CONCURRENCY_LEVEL=500
  fi
  if [ -z "$(eval echo \$${prefix}_LOCKING_STRIPING)" ]; then
    eval ${prefix}_LOCKING_STRIPING=false
  fi
  if [ ${configureIndexing} = "true" ]; then
    if [ -z "$(eval echo \$${prefix}_CACHE_INDEX)" ]; then
      eval ${prefix}_CACHE_INDEX=ALL
    fi
    if [ -z "$(eval echo \$${prefix}_INDEXING_PROPERTIES)" ]; then
      eval ${prefix}_INDEXING_PROPERTIES=default.directory_provider=ram
    fi
  fi

  # Note, this assumes CACHE_NAMES is already initialized with at least one
  # value, as done by "default" above
  CACHE_NAMES=${CACHE_NAMES},${cache_name}
}

#
# adds the following to CACHE_NAMES for each datavirt cache: ${cache_name},
# ${cache_name}_staging, and ${cache_name}_alias.  In addition to this, it
# specifies default values for locking and indexing appropriately for each cache
#
function define_datavirt_caches(){
  if [ -n "$DATAVIRT_CACHE_NAMES" ]; then
    for cache_name in $(echo $DATAVIRT_CACHE_NAMES | sed "s/,/ /g"); do
      define_datavirt_cache_variables "${cache_name}" "true"
      define_datavirt_cache_variables "${cache_name}_staging" "true"
      define_datavirt_cache_variables "${cache_name}_alias" "false"
    done
  fi
}

function configure_jdbc_store() {
  local prefix=${1^^}
  if [ -n "$(find_env "${prefix}_JDBC_STORE_TYPE")" ]; then
    local JDBC_STORE_TYPE="$(find_env "${prefix}_JDBC_STORE_TYPE")"
    if [ -n "$(find_env "${prefix}_KEYED_TABLE_PREFIX")" ]; then
      local KEYED_TABLE_PREFIX="prefix=\"$(find_env "${prefix}_KEYED_TABLE_PREFIX")\""
    fi

    local JDBC_STORE_DATASOURCE=$(find_env "${prefix}_JDBC_STORE_DATASOURCE")
    local db="$(get_db_type "$JDBC_STORE_DATASOURCE")"

    if [ -n "$(find_env "${prefix}_ID_TYPE")$(find_env "${prefix}_DATA_TYPE")$(find_env "${prefix}_TIMESTAMP_TYPE")" ]; then
      local columns=""
      if [ -n "$(find_env "${prefix}_ID_TYPE")" ]; then
        columns="${columns} <id-column name=\"id\" type=\"$(find_env "${prefix}_ID_TYPE")\"/>"
      fi

      if [ -n "$(find_env "${prefix}_DATA_TYPE")" ]; then
        columns="${columns} <data-column name=\"datum\" type=\"$(find_env "${prefix}_DATA_TYPE")\"/>"
      fi

      if [ -n "$(find_env "${prefix}_TIMESTAMP_TYPE")" ]; then
        columns="${columns} <timestamp-column name=\"version\" type=\"$(find_env "${prefix}_TIMESTAMP_TYPE")\"/>"
      fi

    else
      case "${db}" in
        "MYSQL")
          local columns="\
                            <id-column name=\"id\" type=\"VARCHAR(255)\"/>\
                            <data-column name=\"datum\" type=\"BLOB\"/>"
          ;;
        "POSTGRESQL")
          local columns="\
                            <data-column name=\"datum\" type=\"BYTEA\"/>"
          ;;
      esac
    fi
    if [ -n "$(find_env "${prefix}_CACHE_EVICTION_STRATEGY")" -a "$(find_env "${prefix}_CACHE_EVICTION_STRATEGY")" != "NONE" ]; then
      JDBC_STORE_PASSIVATION=true
    else
      JDBC_STORE_PASSIVATION=false
    fi

    jdbcstore="\
                    <$JDBC_STORE_TYPE-keyed-jdbc-store datasource=\"$JDBC_STORE_DATASOURCE\" passivation=\"$JDBC_STORE_PASSIVATION\" shared=\"true\">"
  
    jdbcstore="$jdbcstore \
                        <$JDBC_STORE_TYPE-keyed-table $KEYED_TABLE_PREFIX>$columns\
                        </$JDBC_STORE_TYPE-keyed-table>"

    jdbcstore="$jdbcstore \
                    </$JDBC_STORE_TYPE-keyed-jdbc-store>"
  else
    jdbcstore=""
  fi
}

function get_db_type() {
  ds=$1
  IFS=',' read -a db_backends <<< $DB_SERVICE_PREFIX_MAPPING

  if [ "${#db_backends[@]}" -gt "0" ]; then
    for db_backend in ${db_backends[@]}; do

      local service_name=${db_backend%=*}
      local service=${service_name^^}
      local service=${service//-/_}
      local db=${service##*_}
      local prefix=${db_backend#*=}

      if [ "$ds" = "$(get_jndi_name "$prefix" "$service")" ]; then
        echo $db
        break
      fi 
    done
  fi
}

function configure_container_security() {
  if [ -n "$CONTAINER_SECURITY_ROLE_MAPPER$CONTAINER_SECURITY_CUSTOM_ROLE_MAPPER_CLASS$CONTAINER_SECURITY_ROLES" ]; then
    if [ -n "$CONTAINER_SECURITY_ROLE_MAPPER" ]; then
      if [ -n "$CONTAINER_SECURITY_CUSTOM_ROLE_MAPPER_CLASS" ] && [ "$CONTAINER_SECURITY_ROLE_MAPPER" == "custom-role-mapper" ]; then
        local CONTAINER_SECURITY_CUSTOM_ROLE_MAPPER_CLASS="class=\"$CONTAINER_SECURITY_CUSTOM_ROLE_MAPPER_CLASS\""
      fi
      local rolemapper="\
                        <$CONTAINER_SECURITY_ROLE_MAPPER $CONTAINER_SECURITY_CUSTOM_ROLE_MAPPER_CLASS/>"
    fi

    if [ -n "$CONTAINER_SECURITY_ROLES" ]; then
      IFS=',' read -a roleslist <<< "$(find_env "CONTAINER_SECURITY_ROLES")"
      if [ "${#roleslist[@]}" -ne "0" ]; then
        rolecount=0
        while [ $rolecount -lt ${#roleslist[@]} ]; do
          role="${roleslist[$rolecount]}"

          rolename=${role%=*}
          permissions=${role#*=}
          roles+="\
                        <role name=\"$rolename\" permissions=\"$permissions\"/>"
          rolecount=$((rolecount+1))
        done
      fi
    fi

    containersecurity="\
                <security>\
                    <authorization>$rolemapper$roles\
                    </authorization>\
                </security>"
  else
    containersecurity=""
  fi
}

function configure_infinispan_endpoint() {
  local subsystem

  local hotrod
  local memcached
  local rest

  local topology
  local authentication
  local require_ssl_client_auth
  local encryption
  local rest_security_realm

  IFS=',' read -a connectors <<< "$(find_env "INFINISPAN_CONNECTORS" "hotrod,memcached,rest")"
  if [ "${#connectors[@]}" -ne "0" ]; then
    for connector in ${connectors[@]}; do
      case "${connector}" in
        "hotrod")
          if [ -n "$HOTROD_SERVICE_NAME" ]; then

            HOTROD_SERVICE_NAME=`echo $HOTROD_SERVICE_NAME | sed -e 's/-/_/g' -e 's/\(.*\)/\U\1/'`
            if [ -n "$(find_env "${HOTROD_SERVICE_NAME^^}_SERVICE_HOST")" ]; then
              local topology_external_host=$(find_env "${HOTROD_SERVICE_NAME^^}_SERVICE_HOST")
              local topology_external_port=$(find_env "${HOTROD_SERVICE_NAME^^}_SERVICE_PORT" "11333")
              topology="\
              <topology-state-transfer lazy-retrieval=\"false\" external-host=\"$topology_external_host\" external-port=\"$topology_external_port\"/>"
            fi
          fi
          if [ -n "$HOTROD_AUTHENTICATION" ]; then
            local sasl_server_name="jdg-server"
            if [ -n "$SASL_SERVER_NAME" ]; then
              sasl_server_name="$SASL_SERVER_NAME"
            fi

            authentication="\
              <authentication security-realm=\"ApplicationRealm\">\
                  <sasl server-name=\"${sasl_server_name}\" mechanisms=\"DIGEST-MD5\" qop=\"auth\">\
                      <policy>\
                          <no-anonymous value=\"true\"/>\
                      </policy>\
                      <property name=\"com.sun.security.sasl.digest.utf8\">true</property>\
                  </sasl>\
              </authentication>"
          fi
          if [ -n "$HOTROD_ENCRYPTION" ]; then
            if [ -n "$ENCRYPTION_REQUIRE_SSL_CLIENT_AUTH" ]; then
              require_ssl_client_auth="require-ssl-client-auth=\"$ENCRYPTION_REQUIRE_SSL_CLIENT_AUTH\""
            fi

            encryption="\
              <encryption security-realm=\"ApplicationRealm\" $require_ssl_client_auth/>"
          fi

          hotrod="\
            <hotrod-connector cache-container=\"clustered\" socket-binding=\"hotrod-internal\" name=\"hotrod-internal\">$authentication $encryption\
            </hotrod-connector>"
          if [ -n "$topology" ]; then
            hotrod+="\
            <hotrod-connector cache-container=\"clustered\" socket-binding=\"hotrod-external\" name=\"hotrod-external\">$topology $authentication $encryption\
            </hotrod-connector>"
          fi
        ;;
        "memcached")
          if [ -n "$MEMCACHED_CACHE" ]; then
            memcached="\
            <memcached-connector cache-container=\"clustered\" cache=\"${MEMCACHED_CACHE}\" socket-binding=\"memcached\"/>"
          else
            log_warning "The cache for memcached-connector is not set so the connector will not be configured."
          fi
        ;;
        "rest")
          rest_security_realm="security-realm=\"ApplicationRealm\""

          if [ -n "$REST_SECURITY_DOMAIN" ]; then
            rest_security_realm="security-realm=\"$REST_SECURITY_DOMAIN\""
            rest_authentication="<authentication $rest_security_realm auth-method=\"BASIC\"/>"
          fi

          if [ -n "${HTTPS_NAME}" -a -n "${HTTPS_PASSWORD}" -a -n "${HTTPS_KEYSTORE_DIR}" -a -n "${HTTPS_KEYSTORE}" ] ; then
            if [ -n "$REST_SECURITY_DOMAIN" ]; then
              encryption="<encryption security-realm=\"$REST_SECURITY_DOMAIN\" />"      
            else
              encryption="<encryption security-realm=\"ApplicationRealm\" />"
            fi

            rest="\
                <rest-connector name=\"rest-ssl\" socket-binding=\"rest-ssl\" cache-container=\"clustered\"> \
                   $rest_authentication \
                   $encryption \
                </rest-connector>"
          fi

          rest="$rest \
            <rest-connector name=\"rest\" socket-binding=\"rest\" cache-container=\"clustered\"> \
               $rest_authentication \
            </rest-connector>"
        ;;
      esac
    done
  fi

  subsystem="\
        <subsystem xmlns=\"urn:infinispan:server:endpoint:8.1\">$hotrod $memcached $rest\
        </subsystem>"

  sed -i "s|<!-- ##INFINISPAN_ENDPOINT## -->|$subsystem|" "$CONFIG_FILE"
}
