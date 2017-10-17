#!/bin/bash

source $JWS_HOME/bin/launch/logging.sh

function find_env() {
  var=${!1}
  echo "${var:-$2}"
}

function prepareEnv() {
  clearDatasourcesEnv
}

function configure() {
  inject_datasources
  inject_external_datasources
}

function configureEnv() {
  inject_external_datasources
}

function clearDatasourceEnv() {
  local prefix=$1
  local service=$2

  unset ${service}_HOST
  unset ${service}_PORT  
  unset ${prefix}_PROTOCOL
  unset ${prefix}_HOST
  unset ${prefix}_PORT
  unset ${prefix}_NAME
  unset ${prefix}_USERNAME
  unset ${prefix}_PASSWORD
  unset ${prefix}_DATABASE
  unset ${prefix}_DRIVER
  unset ${prefix}_TYPE
  unset ${prefix}_VALIDATION_QUERY
  unset ${prefix}_AUTH
  unset ${prefix}_MAX_WAIT
  unset ${prefix}_MAX_IDLE
  unset ${prefix}_TEST_WHEN_IDLE
  unset ${prefix}_TEST_ON_BORROW
  unset ${prefix}_FACTORY
  unset ${prefix}_URL
  unset ${prefix}_TRANSACTION_ISOLATION
  unset ${prefix}_MIN_IDLE
  unset ${prefix}_MAX_ACTIVE
}

function clearDatasourcesEnv() {
  IFS=',' read -a db_backends <<< $DB_SERVICE_PREFIX_MAPPING
  for db_backend in ${db_backends[@]}; do
    service_name=${db_backend%=*}
    service=${service_name^^}
    service=${service//-/_}
    db=${service##*_}
    prefix=${db_backend#*=}

    clearDatasourceEnv $prefix $service
  done

  for datasource_prefix in $(echo $RESOURCES | sed "s/,/ /g"); do
    clearDatasourceEnv $datasource_prefix $datasource_prefix
  done
  unset RESOURCES
}

function inject_external_datasources() {
  # Add extensions from envs
  if [ -n "$RESOURCES" ]; then
    for prefix in $(echo $RESOURCES | sed "s/,/ /g"); do
      name=$(find_env "${prefix}_NAME" )
      if [ -z "$name" ]; then
        log_warning "${prefix}_NAME is missing. Resource $prefix WILL NOT be configured." 
        continue  
      fi      

      resource="<Resource name=\"${name}\""
      driver=$(find_env "${prefix}_DRIVER" )
      if [ -z "$driver" ]; then
        log_warning "${prefix}_DRIVER is missing. Resource $prefix WILL NOT be configured." 
        continue
      fi
      resource="${resource} driverClassName=\"$driver\""

      protocol=$(find_env "${prefix}_PROTOCOL" )
      host=$(find_env "${prefix}_HOST" )
      port=$(find_env "${prefix}_PORT" )
      database=$(find_env "${prefix}_DATABASE" )
      url=$(find_env "${prefix}_URL" )
      if [ -n "$url" ]; then
         resource="${resource} url=\"$url\"" 
      elif [ -z "${protocol}" ] || [ -z "$host" ] || [ -z "$port" ] || [ -z "$database" ]; then
        log_warning "${prefix}_PROTOCOL, ${prefix}_HOST, ${prefix}_PORT, ${prefix}_DATABASE, or ${prefix}_URL is missing. Resource $prefix WILL NOT be configured." 
        continue
      else
        resource="${resource} url=\"${protocol}://${host}:${port}/${database}\""
      fi

      factory=$(find_env "${prefix}_FACTORY" )
      if [ -z "$factory" ]; then
        log_warning "${prefix}_FACTORY is missing. Resource $prefix WILL NOT be configured." 
        continue
      fi
      resource="${resource} factory=\"$factory\""

      type=$(find_env "${prefix}_TYPE" )
      if [ -z "$type" ]; then
        log_warning "${prefix}_TYPE is missing. Resource $prefix WILL NOT be configured." 
        continue
      fi
      resource="${resource} type=\"$type\""

      username=$(find_env "${prefix}_USERNAME" )
      password=$(find_env "${prefix}_PASSWORD" )
      if [ -n "$username" ]; then
        if [ -n "$password" ]; then
          resource="${resource} username=\"$username\" password=\"$password\""
        else
          log_warning "${prefix}_PASSWORD is missing. Resource $prefix WILL NOT be configured." 
          continue
        fi
      fi

      max_wait=$(find_env "${prefix}_MAX_WAIT" )
      if [ -n "$max_wait" ]; then
         resource="${resource} maxWait=\"$max_wait\""
      fi

      max_idle=$(find_env "${prefix}_MAX_IDLE" )
      if [ -n "$max_idle" ]; then
         resource="${resource} maxIdle=\"$max_idle\""
      fi

      auth=$(find_env "${prefix}_AUTH" )
      if [ -n "$auth" ]; then
         resource="${resource} auth=\"$auth\""
      fi

      isolation=$(find_env "${prefix}_TRANSACTION_ISOLATION" )
      if [ -n "$isolation" ]; then
         resource="${resource} defaultTransactionIsolation=\"$isolation\""
      fi

      min_idle=$(find_env "${prefix}_MIN_IDLE" )
      if [ -n "$min_idle" ]; then
         resource="${resource} minIdle=\"$min_idle\""
      fi

      max_active=$(find_env "${prefix}_MAX_ACTIVE" )
      if [ -n "$max_active" ]; then
         resource="${resource} maxActive=\"$max_active\""
      fi

      validation_query=$(find_env "${prefix}_VALIDATION_QUERY" )
      if [ -n "$validation_query" ]; then
         resource="${resource} validationQuery=\"$validation_query\""

         test_when_idle=$(find_env "${prefix}_TEST_WHEN_IDLE" )
          if [ -n "$test_when_idle" ]; then
             resource="${resource} testWhenIdle=\"$test_when_idle\""
          fi

          test_on_borrow=$(find_env "${prefix}_TEST_ON_BORROW" )
          if [ -n "$test_on_borrow" ]; then
             resource="${resource} testOnBorrow=\"$test_on_borrow\""
          fi
      fi

      resource="${resource} />"

      sed -i "s|<!-- ##DATASOURCES## -->|${resource}<!-- ##DATASOURCES## -->|" $JWS_HOME/conf/context.xml

    done
  fi
}

function generate_datasource() {
  ds="    <Resource name=\"$1\" auth=\"Container\" type=\"javax.sql.DataSource\" username=\"$2\" password=\"$3\" driverClassName=\"$4\" url=\"$5\" maxWait=\"10000\" maxIdle=\"30\" validationQuery=\"SELECT 1\" testWhenIdle=\"true\" testOnBorrow=\"true\" factory=\"org.apache.tomcat.jdbc.pool.DataSourceFactory\""
  if [ -n "$tx_isolation" ]; then
    ds="$ds defaultTransactionIsolation=\"$tx_isolation\""
  fi
  if [ -n "$min_pool_size" ]; then
    ds="$ds minIdle=\"$min_pool_size\""
  fi
  if [ -n "$max_pool_size" ]; then
    ds="$ds maxActive=\"$max_pool_size\""
  fi
  ds="$ds />"

  echo "$ds"
}

# Finds the name of the database services and generates data sources
# based on this info
function inject_datasources() {
  datasources=""

  # Find all databases in the $DB_SERVICE_PREFIX_MAPPING separated by ","
  IFS=',' read -a db_backends <<< $DB_SERVICE_PREFIX_MAPPING

  for db_backend in ${db_backends[@]}; do

    service_name=${db_backend%=*}
    service=${service_name^^}
    service=${service//-/_}
    db=${service##*_}
    prefix=${db_backend#*=}

    host=$(find_env "${service}_SERVICE_HOST")
    port=$(find_env "${service}_SERVICE_PORT")

    if [ "$db" = "MYSQL" ] || [ "$db" = "POSTGRESQL" ]; then
      configurable_db=true
    else
      configurable_db=false
    fi

    if [ "$configurable_db" = true ]; then
      if [ -z $host ] || [ -z $port ]; then
        log_warning "There is a problem with your service configuration!"
        log_warning "You provided following database mapping (via DB_SERVICE_PREFIX_MAPPING environment variable): $db_backend. To configure datasources we expect ${service}_SERVICE_HOST and ${service}_SERVICE_PORT to be set."
        log_warning
        log_warning "Current values:"
        log_warning
        log_warning "${service}_SERVICE_HOST: $host"
        log_warning "${service}_SERVICE_PORT: $port"
        log_warning
        log_warning "Please make sure you provided correct service name and prefix in the mapping. Additionally please check that you do not set portalIP to None in the $service_name service. Headless services are not supported at this time."
        log_warning
        log_warning "The ${db,,} datasource for $prefix service WILL NOT be configured."
        continue
      fi

      # Custom JNDI environment variable name format: [NAME]_[DATABASE_TYPE]_JNDI
      jndi=$(find_env "${prefix}_JNDI" "jboss/datasources/${service,,}")

      # Database username environment variable name format: [NAME]_[DATABASE_TYPE]_USERNAME
      username=$(find_env "${prefix}_USERNAME")

      # Database password environment variable name format: [NAME]_[DATABASE_TYPE]_PASSWORD
      password=$(find_env "${prefix}_PASSWORD")

      # Database name environment variable name format: [NAME]_[DATABASE_TYPE]_DATABASE
      database=$(find_env "${prefix}_DATABASE")

      if [ -z $jndi ] || [ -z $username ] || [ -z $password ] || [ -z $database ]; then
        log_warning "Ooops, there is a problem with the ${db,,} datasource!"
        log_warning "In order to configure ${db,,} datasource for $prefix service you need to provide following environment variables: ${prefix}_USERNAME, ${prefix}_PASSWORD, ${prefix}_DATABASE."
        log_warning
        log_warning "Current values:"
        log_warning
        log_warning "${prefix}_USERNAME: $username"
        log_warning "${prefix}_PASSWORD: $password"
        log_warning "${prefix}_DATABASE: $database"
        log_warning
        log_warning "The ${db,,} datasource for $prefix service WILL NOT be configured."
        continue
      fi

      # Transaction isolation level environment variable name format: [NAME]_[DATABASE_TYPE]_TX_ISOLATION
      tx_isolation=$(find_env "${prefix}_TX_ISOLATION")

      # min pool size environment variable name format: [NAME]_[DATABASE_TYPE]_MIN_POOL_SIZE
      min_pool_size=$(find_env "${prefix}_MIN_POOL_SIZE")

      # max pool size environment variable name format: [NAME]_[DATABASE_TYPE]_MAX_POOL_SIZE
      max_pool_size=$(find_env "${prefix}_MAX_POOL_SIZE")

      url="jdbc:${db,,}://$(find_env "${service}_SERVICE_HOST"):$(find_env "${service}_SERVICE_PORT")/$database"

      if [ "$db" = "MYSQL" ]; then
        driver="com.mysql.jdbc.Driver"
      elif [ "$db" = "POSTGRESQL" ]; then
        driver="org.postgresql.Driver"
      fi

      datasources="$datasources$(generate_datasource $jndi $username $password $driver $url)\n\n"
    fi
  done

  sed -i "s|<!-- ##DATASOURCES## -->|${datasources}<!-- ##DATASOURCES## -->|" $JWS_HOME/conf/context.xml
}
