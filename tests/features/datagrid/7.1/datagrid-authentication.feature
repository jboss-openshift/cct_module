@jboss-datagrid-7
Feature: JDG OpenShift simple authentication

  Scenario: check management interface security realm
    When container is started with env
       | variable               | value             |
       | MGMT_IFACE_REALM       | ApplicationRealm  |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ApplicationRealm on XPATH //*[local-name()='http-interface']/@security-realm
