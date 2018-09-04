load $BATS_TEST_DIRNAME/../../../../tests/bats/common/xml_utils.bash
load $BATS_TEST_DIRNAME/../../../../tests/bats/common/log_utils.bash

export JBOSS_HOME=$BATS_TMPDIR/jboss_home
export CONFIG_FILE=$JBOSS_HOME/standalone/configuration/standalone-openshift.xml

mkdir -p $JBOSS_HOME/bin/launch
cp $BATS_TEST_DIRNAME/../../../../os-eap-node-name/added/launch/openshift-node-name.sh $JBOSS_HOME/bin/launch
cp $BATS_TEST_DIRNAME/../../../../os-logging/added/launch/logging.sh $JBOSS_HOME/bin/launch
cp $BATS_TEST_DIRNAME/../../../../os-eap-launch/added/launch/datasource-common.sh $JBOSS_HOME/bin/launch
cp $BATS_TEST_DIRNAME/../../../added/launch/launch-common.sh $JBOSS_HOME/bin/launch
cp $BATS_TEST_DIRNAME/../../../added/launch/tx-datasource.sh $JBOSS_HOME/bin/launch
cp $BATS_TEST_DIRNAME/../../../added/launch/datasource.sh $JBOSS_HOME/bin/launch

mkdir -p $JBOSS_HOME/standalone/configuration
source $JBOSS_HOME/bin/launch/datasource.sh

setup() {
  cp $BATS_TEST_DIRNAME/../../../../os-eap71-openshift/added/standalone-openshift.xml $JBOSS_HOME/standalone/configuration
}

assert_datasources() {
  local expected=$1
  local xpath="//*[local-name()='datasources']"
  assert_xml $JBOSS_HOME/standalone/configuration/standalone-openshift.xml "$xpath" $BATS_TEST_DIRNAME/expectations/$expected
}