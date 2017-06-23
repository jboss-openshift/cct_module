# Openshift EAP launch script datasource generation routines

. $JBOSS_HOME/bin/launch/launch-common.sh

function clearTxDatasourceEnv() {
  tx_backend=${TX_DATABASE_PREFIX_MAPPING}

  if [ -n "${tx_backend}" ] ; then
    service_name=${tx_backend%=*}
    service=${service_name^^}
    service=${service//-/_}
    db=${service##*_}
    prefix=${tx_backend#*=}

    unset ${service}_SERVICE_HOST
    unset ${service}_SERVICE_PORT
    unset ${prefix}_JNDI
    unset ${prefix}_USERNAME
    unset ${prefix}_PASSWORD
    unset ${prefix}_DATABASE
    unset ${prefix}_TX_ISOLATION
    unset ${prefix}_MIN_POOL_SIZE
    unset ${prefix}_MAX_POOL_SIZE
  fi
}

# Arguments:
# $1 - service name
# $2 - datasource jndi name
# $3 - datasource username
# $4 - datasource password
# $5 - datasource host
# $6 - datasource port
# $7 - datasource databasename
# $8 - driver
function generate_tx_datasource() {

  ds="                  <datasource jta=\"false\" jndi-name=\"${2}ObjectStore\" pool-name=\"${1}ObjectStorePool\" enabled=\"true\">
                      <connection-url>jdbc:${8}://${5}:${6}/${7}</connection-url>
                      <driver>${8}</driver>"
      if [ -n "$tx_isolation" ]; then
        ds="$ds 
                      <transaction-isolation>$tx_isolation</transaction-isolation>"
      fi
      if [ -n "$min_pool_size" ] || [ -n "$max_pool_size" ]; then
        ds="$ds
                      <pool>"
        if [ -n "$min_pool_size" ]; then
          ds="$ds
                          <min-pool-size>$min_pool_size</min-pool-size>"
        fi
        if [ -n "$max_pool_size" ]; then
          ds="$ds
                          <max-pool-size>$max_pool_size</max-pool-size>"
        fi
        ds="$ds
                      </pool>"
      fi
      ds="$ds
                      
                      <security>
                          <user-name>${3}</user-name>
                          <password>${4}</password>
                      </security>
                  </datasource>"
  echo $ds | sed ':a;N;$!ba;s|\n|\\n|g'
}

function inject_jdbc_store() {
  jdbcStore="<jdbc-store datasource-jndi-name=\"${1}ObjectStore\"/>"
  sed -i "s|<!-- ##JDBC_STORE## -->|${jdbcStore}|" $CONFIG_FILE
}

function inject_tx_datasource() {
  tx_backend=${TX_DATABASE_PREFIX_MAPPING}

  if [ -n "${tx_backend}" ] ; then
    service_name=${tx_backend%=*}
    service=${service_name^^}
    service=${service//-/_}
    db=${service##*_}
    prefix=${tx_backend#*=}

    host=$(find_env "${service}_SERVICE_HOST")
    port=$(find_env "${service}_SERVICE_PORT")

    if [ -z $host ] || [ -z $port ]; then
      echo >&2 "There is a problem with your service configuration!"
      echo >&2 "You provided following database mapping (via TX_SERVICE_PREFIX_MAPPING environment variable): $tx_backend. To configure datasources we expect ${service}_SERVICE_HOST and ${service}_SERVICE_PORT to be set."
      echo >&2
      echo >&2 "Current values:"
      echo >&2
      echo >&2 "${service}_SERVICE_HOST: $host"
      echo >&2" ${service}_SERVICE_PORT: $port"
      echo >&2
      echo >&2 "Please make sure you provided correct service name and prefix in the mapping. Additionally please check that you do not set portalIP to None in the $service_name service. Headless services are not supported at this time."
      echo >&2
      echo >&2 "WARNING! The ${db,,} datasource for $prefix service WILL NOT be configured."
      return
    fi

    # Custom JNDI environment variable name format: [NAME]_[DATABASE_TYPE]_JNDI appended by ObjectStore
    jndi=$(find_env "${prefix}_JNDI" "java:jboss/datasources/${service,,}")

    # Database username environment variable name format: [NAME]_[DATABASE_TYPE]_USERNAME
    username=$(find_env "${prefix}_USERNAME")

    # Database password environment variable name format: [NAME]_[DATABASE_TYPE]_PASSWORD
    password=$(find_env "${prefix}_PASSWORD")

    # Database name environment variable name format: [NAME]_[DATABASE_TYPE]_DATABASE
    database=$(find_env "${prefix}_DATABASE")

    if [ -z $jndi ] || [ -z $username ] || [ -z $password ] || [ -z $database ]; then
      echo >&2 "Ooops, there is a problem with the ${db,,} datasource!"
      echo >&2 "In order to configure ${db,,} transactional datasource for $prefix service you need to provide following environment variables: ${prefix}_USERNAME, ${prefix}_PASSWORD, ${prefix}_DATABASE."
      echo >&2
      echo >&2 "Current values:"
      echo >&2
      echo >&2 "${prefix}_USERNAME: $username"
      echo >&2 "${prefix}_PASSWORD: $password"
      echo >&2 "${prefix}_DATABASE: $database"
      echo >&2
      echo >&2 "WARNING! The ${db,,} datasource for $prefix service WILL NOT be configured."
      db="ignore"
    fi

    # Transaction isolation level environment variable name format: [NAME]_[DATABASE_TYPE]_TX_ISOLATION
    tx_isolation=$(find_env "${prefix}_TX_ISOLATION")

    # min pool size environment variable name format: [NAME]_[DATABASE_TYPE]_MIN_POOL_SIZE
    min_pool_size=$(find_env "${prefix}_MIN_POOL_SIZE")

    # max pool size environment variable name format: [NAME]_[DATABASE_TYPE]_MAX_POOL_SIZE
    max_pool_size=$(find_env "${prefix}_MAX_POOL_SIZE")

    case "$db" in
      "MYSQL")
        driver="mysql"
        datasource="$(generate_tx_datasource ${service,,} $jndi $username $password $host $port $database $driver)\n"
        inject_jdbc_store $jndi
        ;;
      "POSTGRESQL")
        driver="postgresql"
        datasource="$(generate_tx_datasource ${service,,} $jndi $username $password $host $port $database $driver)\n"
        inject_jdbc_store $jndi
        ;;
      *)
        datasource=""
        ;;
    esac
    echo ${datasource} | sed ':a;N;$!ba;s|\n|\\n|g'
  else
    if [ -n "$JDBC_STORE_JNDI_NAME" ]; then
      local jdbcStore="<jdbc-store datasource-jndi-name=\"${JDBC_STORE_JNDI_NAME}\"/>"
      sed -i "s|<!-- ##JDBC_STORE## -->|${jdbcStore}|" $CONFIG_FILE
    fi
  fi
}
