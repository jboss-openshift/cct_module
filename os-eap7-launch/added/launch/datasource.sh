source $JBOSS_HOME/bin/launch/datasource-common.sh

function prepareEnv() {
  clearDatasourcesEnv
  clearTxDatasourceEnv
}

function configure() {
  inject_datasources
}

function configureEnv() {
  inject_external_datasources

  if [ -n "$JDBC_STORE_JNDI_NAME" ]; then
    local jdbcStore="<jdbc-store datasource-jndi-name=\"${JDBC_STORE_JNDI_NAME}\"/>"
    sed -i "s|<!-- ##JDBC_STORE## -->|${jdbcStore}|" $CONFIG_FILE
  fi

}

function inject_datasources() {
  inject_datasources_common

  inject_default_job_repositories
}

function generate_datasource() {
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

  generate_datasource_common "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${9}" "${10}" "${11}" "${12}" "${13}" "${14}"

  if [ -z "$service_name" ]; then
    service_name="ExampleDS"
    pool_name="ExampleDS"
    if [ -n "$DB_POOL" ]; then
      pool_name="$DB_POOL"
    fi
  fi

  if [ -n "$DEFAULT_JOB_REPOSITORY" -a "$DEFAULT_JOB_REPOSITORY" = "${service_name}" ]; then
    inject_default_job_repository $pool_name
    inject_job_repository $pool_name
  fi

  if [ -z "$DEFAULT_JOB_REPOSITORY" ]; then
    inject_default_job_repository in-memory
  fi

}

# $1 - refresh-interval
function refresh_interval() {
    echo "refresh-interval=\"$1\""
}

function inject_default_job_repositories() {
  defaultjobrepo="     <default-job-repository name=\"in-memory\"/>"

  sed -i "s|<!-- ##DEFAULT_JOB_REPOSITORY## -->|${defaultjobrepo%$'\n'}|g" $CONFIG_FILE
}

# Arguments:
# $1 - default job repository name
function inject_default_job_repository() {
  defaultjobrepo="     <default-job-repository name=\"${1}\"/>"

  sed -i "s|<!-- ##DEFAULT_JOB_REPOSITORY## -->|${defaultjobrepo%$'\n'}|" $CONFIG_FILE
}

function inject_job_repository() {
  jobrepo="     <job-repository name=\"${1}\">\
      <jdbc data-source=\"${1}\"/>\
    </job-repository>\
    <!-- ##JOB_REPOSITORY## -->"

  sed -i "s|<!-- ##JOB_REPOSITORY## -->|${jobrepo%$'\n'}|" $CONFIG_FILE
}
