@jboss-bpmsuite-7/bpmsuite70-businesscentral-openshift @jboss-bpmsuite-7/bpmsuite70-businesscentral-monitoring-openshift @jboss-bpmsuite-7/bpmsuite70-executionserver-openshift @jboss-bpmsuite-7/bpmsuite70-standalonecontroller-openshift
Feature: BPM Suite Business Central tests

  Scenario: check ownership when started as alternative UID
    When container is started as uid 26458
    Then container log should contain Running
    And run id -u in container and check its output contains 26458
    And all files under /opt/eap are writeable by current user
    And all files under /deployments are writeable by current user
