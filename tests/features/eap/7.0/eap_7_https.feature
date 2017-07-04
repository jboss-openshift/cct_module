@openshift @eap_7_0
Feature: Check HTTPS configuration

  Scenario: Configure HTTPS
    When container is started with env
      | variable               | value        |
      | EAP_HTTPS_PASSWORD     | p@ssw0rd     |
      | EAP_HTTPS_KEYSTORE_DIR | /opt/eap     |
      | EAP_HTTPS_KEYSTORE     | keystore.jks |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /opt/eap/keystore.jks on XPath //*[local-name()='security-realm'][@name="ApplicationRealm"]/*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@path
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value p@ssw0rd on XPath //*[local-name()='security-realm'][@name="ApplicationRealm"]/*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@keystore-password
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value https on XPath //*[local-name()='server'][@name="default-server"]/*[local-name()='https-listener']/@name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value https on XPath //*[local-name()='server'][@name="default-server"]/*[local-name()='https-listener']/@socket-binding
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value ApplicationRealm on XPath //*[local-name()='server'][@name="default-server"]/*[local-name()='https-listener']/@security-realm

  Scenario: Configure HTTPS with JCEKS keystore
    When container is started with env
      | variable            | value          |
      | HTTPS_PASSWORD      | p@ssw0rd       |
      | HTTPS_KEYSTORE_DIR  | /opt/eap       |
      | HTTPS_KEYSTORE      | keystore.jceks |
      | HTTPS_KEYSTORE_TYPE | JCEKS |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /opt/eap/keystore.jceks on XPath //*[local-name()='security-realm'][@name="ApplicationRealm"]/*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@path
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value JCEKS on XPath //*[local-name()='security-realm'][@name="ApplicationRealm"]/*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@provider
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value p@ssw0rd on XPath //*[local-name()='security-realm'][@name="ApplicationRealm"]/*[local-name()='server-identities']/*[local-name()='ssl']/*[local-name()='keystore']/@keystore-password
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value https on XPath //*[local-name()='server'][@name="default-server"]/*[local-name()='https-listener']/@name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value https on XPath //*[local-name()='server'][@name="default-server"]/*[local-name()='https-listener']/@socket-binding
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value ApplicationRealm on XPath //*[local-name()='server'][@name="default-server"]/*[local-name()='https-listener']/@security-realm

