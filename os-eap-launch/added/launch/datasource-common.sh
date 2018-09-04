source $JBOSS_HOME/bin/launch/launch-common.sh
source $JBOSS_HOME/bin/launch/tx-datasource.sh
source $JBOSS_HOME/bin/launch/logging.sh

function clearDatasourceEnv() {
  local prefix=$1
  local service=$2

  unset ${service}_HOST
  unset ${service}_PORT
  unset ${prefix}_JNDI
  unset ${prefix}_USERNAME
  unset ${prefix}_PASSWORD
  unset ${prefix}_DATABASE
  unset ${prefix}_TX_ISOLATION
  unset ${prefix}_MIN_POOL_SIZE
  unset ${prefix}_MAX_POOL_SIZE
  unset ${prefix}_JTA
  unset ${prefix}_NONXA
  unset ${prefix}_DRIVER
  unset ${prefix}_CONNECTION_CHECKER
  unset ${prefix}_EXCEPTION_SORTER
  unset ${prefix}_URL
  unset ${prefix}_BACKGROUND_VALIDATION
  unset ${prefix}_BACKGROUND_VALIDATION_MILLIS

  for xa_prop in $(compgen -v | grep -s "${prefix}_XA_CONNECTION_PROPERTY_"); do
    unset ${xa_prop}
  done
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

  unset TIMER_SERVICE_DATA_STORE

  for datasource_prefix in $(echo $DATASOURCES | sed "s/,/ /g"); do
    clearDatasourceEnv $datasource_prefix $datasource_prefix
  done
  unset DATASOURCES
  unset JDBC_STORE_JNDI_NAME
}

# Finds the name of the database services and generates data sources
# based on this info
function inject_datasources_common() {

  inject_internal_datasources

  tx_datasource="$(inject_tx_datasource)"
  if [ -n "$tx_datasource" ]; then
    sed -i "s|<!-- ##DATASOURCES## -->|${tx_datasource}<!-- ##DATASOURCES## -->|" $CONFIG_FILE
  fi

  inject_external_datasources
}

function inject_internal_datasources() {

  # keep this from polluting other scripts
  local jndi

  # Find all databases in the $DB_SERVICE_PREFIX_MAPPING separated by ","
  IFS=',' read -a db_backends <<< $DB_SERVICE_PREFIX_MAPPING

  if [ -z "$TIMER_SERVICE_DATA_STORE" ]; then
    inject_timer_service default-file-store
  fi

  if [ "${#db_backends[@]}" -eq "0" ]; then
    datasource=$(generate_datasource)
    if [ -n "$datasource" ]; then
      sed -i "s|<!-- ##DATASOURCES## -->|${datasource}<!-- ##DATASOURCES## -->|" $CONFIG_FILE
    fi

    if [ -z "$defaultDatasourceJndi" ]; then
      defaultDatasourceJndi="java:jboss/datasources/ExampleDS"
    fi
  else
    for db_backend in ${db_backends[@]}; do

      local service_name=${db_backend%=*}
      local service=${service_name^^}
      service=${service//-/_}
      local db=${service##*_}
      local prefix=${db_backend#*=}

      if [[ "$service" != *"_"* ]]; then
        log_warning "There is a problem with the DB_SERVICE_PREFIX_MAPPING environment variable!"
        log_warning "You provided the following database mapping (via DB_SERVICE_PREFIX_MAPPING): $db_backend. The mapping does not contain the database type."
        log_warning
        log_warning "Please make sure the mapping is of the form <name>-<database_type>=PREFIX, where <database_type> is either MYSQL or POSTGRESQL."
        log_warning
        log_warning "The datasource for $prefix service WILL NOT be configured."
        continue
      fi

      inject_datasource $prefix $service $service_name

      if [ -z "$defaultDatasourceJndi" ]; then
        # make sure we re-read $jndi, messaging uses it too
        jndi=$(get_jndi_name "$prefix" "$service")
        defaultDatasourceJndi="$jndi"
      fi
    done
  fi

  if [ -n "$defaultDatasourceJndi" ]; then
    defaultDatasource="datasource=\"$defaultDatasourceJndi\""
  else
    defaultDatasource=""
  fi

  # new format replacement : datasource="##DEFAULT_DATASOURCE##"
  sed -i "s|datasource=\"##DEFAULT_DATASOURCE##\"|${defaultDatasource}|" $CONFIG_FILE
  # old format (for compat)
  sed -i "s|<!-- ##DEFAULT_DATASOURCE## -->|${defaultDatasource}|" $CONFIG_FILE
}

function inject_external_datasources() {
  local db
  # Add extensions from envs
  if [ -n "$DATASOURCES" ]; then
    for datasource_prefix in $(echo $DATASOURCES | sed "s/,/ /g"); do
      driver=$(find_env "${datasource_prefix}_DRIVER" )
      if [ "$driver" == "postgresql" ]; then
        db="POSTGRESQL"
      elif [ "$driver" == "mysql" ]; then
        db="MYSQL"
      else
        db="EXTERNAL"
      fi
      inject_datasource $datasource_prefix $datasource_prefix $datasource_prefix
    done
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
# $8 - connection checker class
# $9 - exception sorter class
# $10 - driver
# $11 - original service name
# $12 - datasource jta
# $13 - validate
# $14 - url
function generate_datasource_common() {
  local pool_name="${1}"
  local jndi_name="${2}"
  local username="${3}"
  local password="${4}"
  local host="${5}"
  local port="${6}"
  local databasename="${7}"
  local checker="${8}"
  local sorter="${9}"
  local driver="${10}"
  local service_name="${11}"
  local jta="${12}"
  local validate="${13}"
  local url="${14}"

  if [ -n "$driver" ]; then
    ds=$(generate_external_datasource)
  else
    jndi_name="java:jboss/datasources/ExampleDS"
    if [ -n "$DB_JNDI" ]; then
      jndi_name="$DB_JNDI"
    fi
    pool_name="ExampleDS"
    if [ -n "$DB_POOL" ]; then
      pool_name="$DB_POOL"
    fi

    ds=$(generate_default_datasource)
  fi

  if [ -z "$service_name" ]; then
    service_name="ExampleDS"
    driver="hsql"
  fi

  if [ -n "$TIMER_SERVICE_DATA_STORE" -a "$TIMER_SERVICE_DATA_STORE" = "${service_name}" ]; then
    inject_timer_service ${pool_name}_ds
    local refresh_interval=$(refresh_interval ${TIMER_SERVICE_DATA_STORE_REFRESH_INTERVAL:--1})
    inject_datastore $pool_name $jndi_name $driver $refresh_interval
  fi

  echo $ds | sed ':a;N;$!ba;s|\n|\\n|g'
}

# Global function to configure refresh-interval, this function needs to be overridden in the datasource.sh script
# i.e. os-eap7-launch/.../datasource.sh
function refresh_interval() {
    # do nothing on default state
    echo ""
}

function generate_external_datasource() {
  local failed="false"

  if [ -n "$NON_XA_DATASOURCE" ] && [ "$NON_XA_DATASOURCE" = "true" ]; then
    ds="<datasource jta=\"${jta}\" jndi-name=\"${jndi_name}\" pool-name=\"${pool_name}\" enabled=\"true\" use-java-context=\"true\">
          <connection-url>${url}</connection-url>
          <driver>$driver</driver>"
  else
    ds=" <xa-datasource jndi-name=\"${jndi_name}\" pool-name=\"${pool_name}\" enabled=\"true\" use-java-context=\"true\">"
    local xa_props=$(compgen -v | grep -s "${prefix}_XA_CONNECTION_PROPERTY_")
    if [ -z "$xa_props" ] && [ "$driver" != "postgresql" ] && [ "$driver" != "mysql" ]; then
      log_warning "At least one ${prefix}_XA_CONNECTION_PROPERTY_property for datasource ${service_name} is required. Datasource will not be configured."
      failed="true"
    else

      for xa_prop in $(echo $xa_props); do
        prop_name=$(echo "${xa_prop}" | sed -e "s/${prefix}_XA_CONNECTION_PROPERTY_//g")
        prop_val=$(find_env $xa_prop)
        if [ ! -z ${prop_val} ]; then
          ds="$ds <xa-datasource-property name=\"${prop_name}\">${prop_val}</xa-datasource-property>"
        fi
      done

      ds="$ds
             <driver>${driver}</driver>"
    fi

    if [ -n "$tx_isolation" ]; then
      ds="$ds
             <transaction-isolation>$tx_isolation</transaction-isolation>"
    fi
  fi

  if [ -n "$min_pool_size" ] || [ -n "$max_pool_size" ]; then
    if [ -n "$NON_XA_DATASOURCE" ] && [ "$NON_XA_DATASOURCE" = "true" ]; then
       ds="$ds
             <pool>"
    else
      ds="$ds
             <xa-pool>"
    fi

    if [ -n "$min_pool_size" ]; then
      ds="$ds
             <min-pool-size>$min_pool_size</min-pool-size>"
    fi
    if [ -n "$max_pool_size" ]; then
      ds="$ds
             <max-pool-size>$max_pool_size</max-pool-size>"
    fi
    if [ -n "$NON_XA_DATASOURCE" ] && [ "$NON_XA_DATASOURCE" = "true" ]; then
      ds="$ds
             </pool>"
    else
      ds="$ds
             </xa-pool>"
    fi
  fi

   ds="$ds
         <security>
           <user-name>${username}</user-name>
           <password>${password}</password>
         </security>"

  if [ "$validate" == "true" ]; then

    validation_conf="<validate-on-match>true</validate-on-match>
                       <background-validation>false</background-validation>"

    if [ $(find_env "${prefix}_BACKGROUND_VALIDATION" "false") == "true" ]; then

        millis=$(find_env "${prefix}_BACKGROUND_VALIDATION_MILLIS" 10000)
        validation_conf="<validate-on-match>false</validate-on-match>
                           <background-validation>true</background-validation>
                           <background-validation-millis>${millis}</background-validation-millis>"
    fi

    ds="$ds
           <validation>
             ${validation_conf}
             <valid-connection-checker class-name=\"${checker}\"></valid-connection-checker>
             <exception-sorter class-name=\"${sorter}\"></exception-sorter>
           </validation>"
  fi

  if [ -n "$NON_XA_DATASOURCE" ] && [ "$NON_XA_DATASOURCE" = "true" ]; then
    ds="$ds
           </datasource>"
  else
    ds="$ds
           </xa-datasource>"
  fi

  if [ "$failed" == "true" ]; then
    echo ""
  else
    echo $ds
  fi
}

function generate_default_datasource() {
  ds="<datasource jta=\"true\" jndi-name=\"${jndi_name}\" pool-name=\"${pool_name}\" enabled=\"true\" use-java-context=\"true\">"

  if [ -n "$url" ]; then
    ds="$ds
           <connection-url>${url}</connection-url>"
  else
    ds="$ds
           <connection-url>jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE</connection-url>"
  fi

  ds="$ds
         <driver>h2</driver>
           <security>
             <user-name>sa</user-name>
             <password>sa</password>
           </security>
         </datasource>"

  echo $ds
}

# Arguments:
# $1 - timer service datastore
function inject_timer_service() {
  local defaultdatastore="${1}"

  local timerservice="            <timer-service thread-pool-name=\"default\" default-data-store=\"${defaultdatastore}\">\
                <data-stores>\
                    <file-data-store name=\"default-file-store\" path=\"timer-service-data\" relative-to=\"jboss.server.data.dir\"/>\
                    <!-- ##DATASTORES## -->\
                </data-stores>\
            </timer-service>"
  sed -i "s|<!-- ##TIMER_SERVICE## -->|${timerservice}|" $CONFIG_FILE
}

# Arguments:
# $1 - service name
# $2 - datasource jndi name
# $3 - datasource databasename
# $4 - datastore refresh-interval (only applicable on eap7.x)
function inject_datastore() {
  local servicename="${1}"
  local jndi_name="${2}"
  local databasename="${3}"
  local refresh_interval="${4}"

  local datastore="<database-data-store name=\"${servicename}_ds\" datasource-jndi-name=\"${jndi_name}\" database=\"${databasename}\" partition=\"${servicename}_part\" ${refresh_interval}/>\
        <!-- ##DATASTORES## -->"
  sed -i "s|<!-- ##DATASTORES## -->|${datastore}|" $CONFIG_FILE
}

function map_properties() {
  local protocol=${1}
  local serverNameVar=${2}
  local portVar=${3}
  local databaseNameVar=${4}

  if [ -n "$host" ] && [ -n "$port" ] && [ -n "$database" ]; then
    if [ -z "$url" ]; then
      url="${protocol}://${host}:${port}/${database}"
    fi

    if [ "$NON_XA_DATASOURCE" == "false" ] && [ -z "$(eval echo \$${prefix}_XA_CONNECTION_PROPERTY_URL)" ]; then

      if [ -z "${!serverNameVar}" ]; then
        eval ${serverNameVar}=${host}
      fi

      if [ -z "${!portVar}" ]; then
        eval ${portVar}=${port}
      fi

      if [ -z "${!databaseNameVar}" ]; then
        eval ${databaseNameVar}=${database}
      fi
    fi
  elif [ "$NON_XA_DATASOURCE" == "false" ]; then
    if [ -z "$(eval echo \$${prefix}_XA_CONNECTION_PROPERTY_URL)" ]; then
      if [ -z "${!serverNameVar}" ] || [ -z "${!portVar}" ] || [ -z "${!databaseNameVar}" ]; then
        if [ "$prefix" != "$service" ]; then
          log_warning "Missing configuration for datasource $prefix. ${service}_SERVICE_HOST, ${service}_SERVICE_PORT, and/or ${prefix}_DATABASE is missing. Datasource will not be configured."
        else
          log_warning "Missing configuration for XA datasource $prefix. Either ${prefix}_XA_CONNECTION_PROPERTY_URL or $serverNameVar, and $portVar, and $databaseNameVar is required. Datasource will not be configured."
        fi
      else
        host="${!serverNameVar}"
        port="${!portVar}"
        database="${!databaseNameVar}"
      fi
    fi
  else
    log_warning "Missing configuration for datasource $prefix. ${service}_SERVICE_HOST, ${service}_SERVICE_PORT, and/or ${prefix}_DATABASE is missing. Datasource will not be configured."
  fi

}

function inject_datasource() {
  local prefix=$1
  local service=$2
  local service_name=$3

  local host
  local port
  local jndi
  local username
  local password
  local database
  local tx_isolation
  local min_pool_size
  local max_pool_size
  local jta
  local NON_XA_DATASOURCE
  local driver
  local validate
  local checker
  local sorter
  local url
  local service_name

  host=$(find_env "${service}_SERVICE_HOST")

  port=$(find_env "${service}_SERVICE_PORT")

  # Custom JNDI environment variable name format: [NAME]_[DATABASE_TYPE]_JNDI
  jndi=$(get_jndi_name "$prefix" "$service")

  # Database username environment variable name format: [NAME]_[DATABASE_TYPE]_USERNAME
  username=$(find_env "${prefix}_USERNAME")

  # Database password environment variable name format: [NAME]_[DATABASE_TYPE]_PASSWORD
  password=$(find_env "${prefix}_PASSWORD")

  # Database name environment variable name format: [NAME]_[DATABASE_TYPE]_DATABASE
  database=$(find_env "${prefix}_DATABASE")

  if [ -z "$jndi" ] || [ -z "$username" ] || [ -z "$password" ]; then
    log_warning "Ooops, there is a problem with the ${db,,} datasource!"
    log_warning "In order to configure ${db,,} datasource for $prefix service you need to provide following environment variables: ${prefix}_USERNAME and ${prefix}_PASSWORD."
    log_warning
    log_warning "Current values:"
    log_warning
    log_warning "${prefix}_USERNAME: $username"
    log_warning "${prefix}_PASSWORD: $password"
    log_warning "${prefix}_JNDI: $jndi"
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

  # jta environment variable name format: [NAME]_[DATABASE_TYPE]_JTA
  jta=$(find_env "${prefix}_JTA" true)

  # $NON_XA_DATASOURCE: [NAME]_[DATABASE_TYPE]_NONXA (DB_NONXA)
  NON_XA_DATASOURCE=$(find_env "${prefix}_NONXA" false)

  url=$(find_env "${prefix}_URL")

  case "$db" in
    "MYSQL")
      map_properties "jdbc:mysql" "${prefix}_XA_CONNECTION_PROPERTY_ServerName" "${prefix}_XA_CONNECTION_PROPERTY_Port" "${prefix}_XA_CONNECTION_PROPERTY_DatabaseName"

      driver="mysql"
      validate="true"
      checker="org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLValidConnectionChecker"
      sorter="org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLExceptionSorter"
      ;;
    "POSTGRESQL")
      map_properties "jdbc:postgresql" "${prefix}_XA_CONNECTION_PROPERTY_ServerName" "${prefix}_XA_CONNECTION_PROPERTY_PortNumber" "${prefix}_XA_CONNECTION_PROPERTY_DatabaseName"

      driver="postgresql"
      validate="true"
      checker="org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLValidConnectionChecker"
      sorter="org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLExceptionSorter"
      ;;
    "MONGODB")
      continue
      ;;
    *)
      driver=$(find_env "${prefix}_DRIVER" )
      checker=$(find_env "${prefix}_CONNECTION_CHECKER" )
      sorter=$(find_env "${prefix}_EXCEPTION_SORTER" )
      url=$(find_env "${prefix}_URL" )
      if [ -n "$checker" ] && [ -n "$sorter" ]; then
        validate=true
      else
        validate="false"
      fi

      service_name=$prefix
      ;;
  esac

  if [ -z "$jta" ]; then
    log_warning "JTA flag not set, defaulting to true for datasource  ${service_name}"
    jta=false
  fi

  if [ -z "$driver" ]; then
    log_warning "DRIVER not set for datasource ${service_name}. Datasource will not be configured."
  else
    datasource=$(generate_datasource "${service,,}-${prefix}" "$jndi" "$username" "$password" "$host" "$port" "$database" "$checker" "$sorter" "$driver" "$service_name" "$jta" "$validate" "$url")

    if [ -n "$datasource" ]; then
      sed -i "s|<!-- ##DATASOURCES## -->|${datasource}\n<!-- ##DATASOURCES## -->|" $CONFIG_FILE
    fi
  fi
}

function get_jndi_name() {
  local prefix=$1
  echo $(find_env "${prefix}_JNDI" "java:jboss/datasources/${service,,}")
}
