@openshift @datagrid
Feature: Openshift JDG server identities tests
  Scenario: server-identities
    When container is started with env
       | variable                                     | value                                  |
       | SSL_PROTOCOL                                 | TLS                                    |
       | SSL_KEYSTORE_PATH                            | keystore_server.jks                    |
       | SSL_KEYSTORE_PASSWORD                        | secret                                 |
       | SSL_KEYSTORE_RELATIVE_TO                     | jboss.server.config.dir                |
       | SSL_KEYSTORE_ALIAS                           | myalias                                |
       | SSL_KEY_PASSWORD                             | notsecret                              |
       | SECRET_VALUE                                 | c2VjcmV0                               |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='server-identities']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='server-identities']/*[local-name()='ssl']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value TLS on XPath //*[local-name()='server-identities']/*[local-name()='ssl']/@protocol
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value keystore_server.jks on XPath //*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@path
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value secret on XPath //*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@keystore-password
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value jboss.server.config.dir on XPath //*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@relative-to
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value myalias on XPath //*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@alias
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value notsecret on XPath //*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@key-password
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='server-identities']/*[local-name()='secret']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value c2VjcmV0 on XPath //*[local-name()='server-identities']/*[local-name()='secret']/@value

  Scenario: server-identities-from-https-config-when-ssl-config-not-set
    When container is started with env
       | variable                                     | value                                  |
       | HTTPS_KEYSTORE                               | keystore_server.jks                    |
       | HTTPS_PASSWORD                               | secret                                 |
       | HTTPS_KEYSTORE_DIR                           | /keystore/dir                          |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='server-identities']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='server-identities']/*[local-name()='ssl']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value /keystore/dir/keystore_server.jks on XPath //*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@path
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value secret on XPath //*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@keystore-password
  
  Scenario: Check if an INFO is emitted when no SSL is configured
    When container is ready
    Then container log should contain HotRod SSL will not be configured

  Scenario: Check if a WARNING is emitted when SSL is misconfigured
    When container is started with env
       | variable          | value |
       | SSL_KEYSTORE_PATH | foo   |
    Then container log should contain HotRod SSL will not be configured
  
  Scenario: There must be no warnings if SSL is correctly configured
    When container is started with env
       | variable              | value |
       | SSL_KEYSTORE_PATH     | foo   |
       | SSL_KEYSTORE_PASSWORD | bar   |
    Then container log should not contain HotRod SSL will not be configured
