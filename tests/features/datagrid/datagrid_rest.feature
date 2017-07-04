@openshift
Feature: Openshift JDG REST tests

  @jboss-datagrid-6/datagrid65-openshift
  Scenario: rest-endpoint for JDG 6.5
    When container is started with env
       | variable                                     | value                            |
       | INFINISPAN_CONNECTORS                        | rest                             |
       | REST_SECURITY_DOMAIN                         | none                             |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='rest-connector']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value clustered on XPath //*[local-name()='rest-connector']/@cache-container
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value none on XPath //*[local-name()='rest-connector']/@security-domain

  @jboss-datagrid-7/datagrid71-openshift
  Scenario: Should create endpoint
    When container is started with env
      | variable                                     | value                                  |
      | INFINISPAN_CONNECTORS                        | rest                                   |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='rest-connector']

  @jboss-datagrid-7/datagrid71-openshift
  Scenario: Should create endpoint with authentication
    When container is started with env
      | variable                                     | value                                  |
      | INFINISPAN_CONNECTORS                        | rest                                   |
      | REST_AUTHENTICATION_BASIC                    | true                                   |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ApplicationRealm on XPath //*[local-name()='rest-connector']/*[local-name()='authentication']/@security-realm
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value BASIC on XPath //*[local-name()='rest-connector']/*[local-name()='authentication']/@auth-method

  @jboss-datagrid-7/datagrid71-openshift
  Scenario: Should create endpoint with authentication and specified security domain
    When container is started with env
      | variable                                     | value                                  |
      | INFINISPAN_CONNECTORS                        | rest                                   |
      | REST_AUTHENTICATION_BASIC                    | true                                   |
      | REST_SECURITY_DOMAIN                         | ManagmentRealm                         |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ManagmentRealm on XPath //*[local-name()='rest-connector']/*[local-name()='authentication']/@security-realm

  @jboss-datagrid-7/datagrid71-openshift
  Scenario: Should create endpoint with encryption
    When container is started with env
      | variable                                     | value                                  |
      | INFINISPAN_CONNECTORS                        | rest                                   |
      | REST_ENCRYPTION                              | true                                   |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ApplicationRealm on XPath //*[local-name()='rest-connector']/*[local-name()='encryption']/@security-realm

  @jboss-datagrid-7/datagrid71-openshift
  Scenario: Should create endpoint with encryption and specified security domain
    When container is started with env
      | variable                                     | value                                  |
      | INFINISPAN_CONNECTORS                        | rest                                   |
      | REST_ENCRYPTION                              | true                                   |
      | REST_SECURITY_DOMAIN                         | ManagementRealm                         |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ManagementRealm on XPath //*[local-name()='rest-connector']/*[local-name()='encryption']/@security-realm
