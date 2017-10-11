@jboss-eap-7 
Feature: Check correct variable expansion used
  Scenario: Check HTTPS basic config
    When container is started with env
      | variable               | value                        |
      | HTTPS_NAME             | jboss                        |
      | HTTPS_PASSWORD         | mykeystorepass               |
      | HTTPS_KEY_PASSWORD     | mykeypass                    |
      | HTTPS_KEYSTORE_DIR     | /etc/eap-secret-volume       |
      | HTTPS_KEYSTORE         | keystore.jks                 |
      | HTTPS_KEYSTORE_TYPE    | JKS                          |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /etc/eap-secret-volume/keystore.jks on XPath //*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@path
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mykeystorepass on XPath //*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@keystore-password
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jboss on XPath //*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@alias
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mykeypass on XPath //*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@key-password
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value JKS on XPath //*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@provider

