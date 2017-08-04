Feature: JDG OpenShift simple authentication

  @jboss-datagrid-6 @jboss-datagrid-7
  Scenario: check username, password and roles
    When container is started with env
       | variable               | value          |
       | USERNAME               | openshift      |
       | PASSWORD               | p@ssw0rd       |
    Then file /opt/datagrid/standalone/configuration/application-users.properties should contain openshift=7d540d09717694371fc426a7190c6021
    And file /opt/datagrid/standalone/configuration/application-roles.properties should contain openshift=REST,admin

  @jboss-datagrid-7
  Scenario: check management interface security realm
    When container is started with env
       | variable               | value             |
       | MGMT_IFACE_REALM       | ApplicationRealm  |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ApplicationRealm on XPATH //*[local-name()='http-interface']/@security-realm
