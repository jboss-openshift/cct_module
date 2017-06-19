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
}

function inject_datasources() {
  inject_datasources_common
}

function generate_datasource() {
  generate_datasource_common "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${9}" "${10}" "${11}" "${12}" "${13}" "${14}"
}
