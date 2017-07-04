@openshift @eap_7_0
Feature: Openshift EAP s2i tests

  Scenario: deploys the binary example, then checks if both war files are deployed.
    Given s2i build https://github.com/jboss-openshift/openshift-examples from binary
    Then container log should contain WFLYSRV0025
    And available container log should contain WFLYSRV0010: Deployed "node-info.war"
    And file /opt/eap/standalone/deployments/node-info.war should exist
    And available container log should contain WFLYSRV0010: Deployed "top-level.war"
    And file /opt/eap/standalone/deployments/top-level.war should exist
