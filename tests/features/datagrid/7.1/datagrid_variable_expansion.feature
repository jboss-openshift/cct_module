@jboss-datagrid-7 
Feature: Check correct JDG variable expansion used
  Scenario: Check HTTPS basic config
    When container is started with env
      | variable                      | value                        |
      | USERNAME                      | tombrady                     |
      | PASSWORD                      | ringsix6!                    |
      | HTTPS_NAME                    | jboss                        |
      | HTTPS_PASSWORD                | mykeystorepass               |
      | HTTPS_KEY_PASSWORD            | mykeypass                    |
      | HTTPS_KEYSTORE_DIR            | /etc/eap-secret-volume       |
      | HTTPS_KEYSTORE                | keystore.jks                 |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value /etc/eap-secret-volume/keystore.jks on XPath //*[local-name()='security-realm'][@name='ApplicationRealm']/*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@path
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value mykeystorepass on XPath //*[local-name()='security-realm'][@name='ApplicationRealm']/*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@keystore-password
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value mykeypass on XPath //*[local-name()='security-realm'][@name='ApplicationRealm']/*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@key-password
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value jboss on XPath //*[local-name()='security-realm'][@name='ApplicationRealm']/*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@alias
   Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value /etc/eap-secret-volume/keystore.jks on XPath //*[local-name()='security-realm'][@name='jdg-openshift']/*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@path
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value mykeystorepass on XPath //*[local-name()='security-realm'][@name='jdg-openshift']/*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@keystore-password
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value mykeypass on XPath //*[local-name()='security-realm'][@name='jdg-openshift']/*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@key-password
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value jboss on XPath //*[local-name()='security-realm'][@name='jdg-openshift']/*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@alias

