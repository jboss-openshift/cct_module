@jboss-eap-7/eap71-openshift
Feature: EAP Openshift Elytron
  Scenario: Use Elytron for HTTPS
    When container is started with env
      | variable                      | value        |
      | HTTPS_PASSWORD                | p@ssw0rd     |
      | HTTPS_KEYSTORE_DIR            | /opt/eap     |
      | HTTPS_KEYSTORE                | keystore.jks |
      | HTTPS_KEYSTORE_TYPE           | JKS          |
      | CONFIGURE_ELYTRON_SSL         | true         |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 0 elements on XPath //*[local-name()='security-realm'][@name="ApplicationRealm"]/*[local-name()='server-identities']
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value https on XPath //*[local-name()='server'][@name="default-server"]/*[local-name()='https-listener']/@name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value https on XPath //*[local-name()='server'][@name="default-server"]/*[local-name()='https-listener']/@socket-binding
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value LocalhostSslContext on XPath //*[local-name()='server'][@name="default-server"]/*[local-name()='https-listener']/@ssl-context
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value p@ssw0rd on XPath //*[local-name()='tls']/*[local-name()='key-stores']/*[local-name()='key-store'][@name="LocalhostKeyStore"]/*[local-name()='credential-reference']/@clear-text
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value JKS on XPath //*[local-name()='tls']/*[local-name()='key-stores']/*[local-name()='key-store'][@name="LocalhostKeyStore"]/*[local-name()='implementation']/@type
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value keystore.jks on XPath //*[local-name()='tls']/*[local-name()='key-stores']/*[local-name()='key-store'][@name="LocalhostKeyStore"]/*[local-name()='file']/@path
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /opt/eap on XPath //*[local-name()='tls']/*[local-name()='key-stores']/*[local-name()='key-store'][@name="LocalhostKeyStore"]/*[local-name()='file']/@relative-to
