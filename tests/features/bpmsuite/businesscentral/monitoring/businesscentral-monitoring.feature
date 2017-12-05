@jboss-bpmsuite-7/bpmsuite70-businesscentral-monitoring-openshift
Feature: BPM Suite Business Central Monitoring tests

  # https://issues.jboss.org/browse/CLOUD-180
  Scenario: Check if image version and release is printed on boot
    When container is ready
    Then container log should contain jboss-bpmsuite-7/bpmsuite70-businesscentral-monitoring-openshift image, version

  Scenario: Check for product and version  environment variables
    When container is ready
    Then run sh -c 'echo $JBOSS_PRODUCT' in container and check its output for bpmsuite-businesscentral-monitoring
    And run sh -c 'echo $JBOSS_BPMSUITE_BUSINESSCENTRAL_MONITORING_VERSION' in container and check its output for 7.0.0
