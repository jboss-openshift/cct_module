
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
  Scenario: authenticated rest-endpoint for JDG 7.1
    When container is started with env
       | variable                                     | value                            |
       | INFINISPAN_CONNECTORS                        | rest                             |
       | REST_SECURITY_DOMAIN                         | ApplicationRealm                 |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='rest-connector']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value clustered on XPath //*[local-name()='rest-connector']/@cache-container
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ApplicationRealm on XPath //*[local-name()='rest-connector']/*[local-name()='authentication']/@security-realm
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value BASIC on XPath //*[local-name()='rest-connector']/*[local-name()='authentication']/@auth-method

  @jboss-datagrid-7/datagrid71-openshift
  Scenario: Should create endpoint with encryption
    When container is started with env
      | variable                                     | value                                  |
      | INFINISPAN_CONNECTORS                        | rest                                   |
      | HTTPS_NAME                                   | jboss                                  |
      | HTTPS_PASSWORD                               | mykeystorepass                         |
      | HTTPS_KEYSTORE_DIR                           | /etc/datagrid-secret-volume            |
      | HTTPS_KEYSTORE                               | keystore.jks                           |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ApplicationRealm on XPath //*[local-name()='rest-connector'][@name='rest-ssl']/*[local-name()='encryption']/@security-realm
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value rest on XPath //*[local-name()='rest-connector'][@name='rest']/@socket-binding    

  @jboss-datagrid-7/datagrid71-openshift
  Scenario: Should create endpoint with encryption and specified security domain
    When container is started with env
      | variable                                     | value                                  |
      | INFINISPAN_CONNECTORS                        | rest                                   |
      | HTTPS_NAME                                   | jboss                                  |
      | HTTPS_PASSWORD                               | mykeystorepass                         |
      | HTTPS_KEYSTORE_DIR                           | /etc/datagrid-secret-volume            | 
      | HTTPS_KEYSTORE                               | keystore.jks                           |
      | REST_SECURITY_DOMAIN                         | ManagementRealm                        |
Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ManagementRealm on XPath //*[local-name()='rest-connector']/*[local-name()='encryption']/@security-realm

  @jboss-datagrid-7/datagrid71-openshift
  Scenario: Should create security realm that maps to security domain
    When container is started with env
      | variable                                     | value                                  |
      | INFINISPAN_CONNECTORS                        | rest                                   |
      | USERNAME                                     | tombrady                               |
      | PASSWORD                                     | sixrings                               |
      | HTTPS_NAME                                   | jboss                                  |
      | HTTPS_PASSWORD                               | mykeystorepass                         |
      | HTTPS_KEYSTORE_DIR                           | /etc/datagrid-secret-volume            |
      | HTTPS_KEYSTORE                               | keystore.jks                           |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value jdg-openshift on XPath //*[local-name()='security-realms']/*[local-name()='security-realm']/@name
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value jdg-openshift on XPath //*[local-name()='security-realms']/*[local-name()='security-realm'][@name='jdg-openshift']/*[local-name()='authentication']/*[local-name()='jaas']/@name
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value mykeystorepass on XPath //*[local-name()='security-realms']/*[local-name()='security-realm'][@name='jdg-openshift']/*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@keystore-password
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value jdg-openshift on XPath //*[local-name()='rest-connector']/*[local-name()='encryption']/@security-realm

