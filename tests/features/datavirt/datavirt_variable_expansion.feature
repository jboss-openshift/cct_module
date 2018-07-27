@jboss-datavirt-6 
Feature: Check correct JDV variable expansion used
  Scenario: Check HTTPS basic config
    When container is started with env
      | variable                      | value                        |
      | DATAVIRT_TRANSPORT_KEY_ALIAS  | jboss                        |
      | HTTPS_PASSWORD                | mykeystorepass               |
      | HTTPS_KEY_PASSWORD            | mykeypass                    |
      | HTTPS_KEYSTORE_DIR            | /etc/eap-secret-volume       |
      | HTTPS_KEYSTORE                | keystore.jks                 |
      | HTTPS_KEYSTORE_TYPE           | JKS                          |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /etc/eap-secret-volume/keystore.jks on XPath //*[local-name()='transport'][@name='secure-jdbc']/*[local-name()='ssl']/*[local-name()='keystore']/@name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mykeystorepass on XPath //*[local-name()='transport'][@name='secure-jdbc']/*[local-name()='ssl']/*[local-name()='keystore']/@password
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value JKS on XPath //*[local-name()='transport'][@name='secure-jdbc']/*[local-name()='ssl']/*[local-name()='keystore']/@type
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mykeypass on XPath //*[local-name()='transport'][@name='secure-jdbc']/*[local-name()='ssl']/*[local-name()='keystore']/@key-password
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jboss on XPath //*[local-name()='transport'][@name='secure-jdbc']/*[local-name()='ssl']/*[local-name()='keystore']/@key-alias
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /etc/eap-secret-volume/keystore.jks on XPath //*[local-name()='transport'][@name='secure-jdbc']/*[local-name()='ssl']/*[local-name()='truststore']/@name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mykeystorepass on XPath //*[local-name()='transport'][@name='secure-jdbc']/*[local-name()='ssl']/*[local-name()='truststore']/@password
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /etc/eap-secret-volume/keystore.jks on XPath //*[local-name()='transport'][@name='secure-odbc']/*[local-name()='ssl']/*[local-name()='keystore']/@name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mykeystorepass on XPath //*[local-name()='transport'][@name='secure-odbc']/*[local-name()='ssl']/*[local-name()='keystore']/@password
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value JKS on XPath //*[local-name()='transport'][@name='secure-odbc']/*[local-name()='ssl']/*[local-name()='keystore']/@type
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mykeypass on XPath //*[local-name()='transport'][@name='secure-odbc']/*[local-name()='ssl']/*[local-name()='keystore']/@key-password
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jboss on XPath //*[local-name()='transport'][@name='secure-odbc']/*[local-name()='ssl']/*[local-name()='keystore']/@key-alias
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /etc/eap-secret-volume/keystore.jks on XPath //*[local-name()='transport'][@name='secure-odbc']/*[local-name()='ssl']/*[local-name()='truststore']/@name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mykeystorepass on XPath //*[local-name()='transport'][@name='secure-odbc']/*[local-name()='ssl']/*[local-name()='truststore']/@password

