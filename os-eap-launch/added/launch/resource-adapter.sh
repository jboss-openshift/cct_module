source $JBOSS_HOME/bin/launch/resource-adapters-common.sh

function prepareEnv() {
  clearResourceAdaptersEnv
}

function configure() {
  inject_resource_adapters
}

function configureEnv() {
  inject_resource_adapters
}

function inject_resource_adapters() {
  inject_resource_adapters_common
}

