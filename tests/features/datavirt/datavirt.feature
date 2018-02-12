@jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
Feature: OpenShift Datavirt tests

  # CLOUD-769
  Scenario: test jolokia started
    When container is ready
    Then container log should contain -javaagent:/opt/jolokia/jolokia.jar=config=/opt/jolokia/etc/jolokia.properties
     And available container log should not contain java.net.BindException

  Scenario: check ownership when started as alternative UID
    When container is started as uid 26458
    Then container log should contain Running
     And run id -u in container and check its output contains 26458
     And all files under /opt/eap are writeable by current user
     And all files under /deployments are writeable by current user

  Scenario: check for secure jdbc/odbc config
    When container is started with env  
      | variable                                 | value                                       |
      | DATAVIRT_TRANSPORT_KEYSTORE              | keystore.jks                                |
      | DATAVIRT_TRANSPORT_KEY_ALIAS             | jboss                                       |
      | DATAVIRT_TRANSPORT_KEYSTORE_PASSWORD     | mykeystorepass                              |
      | DATAVIRT_TRANSPORT_KEYSTORE_DIR          | /etc/jdv-secret-volume                      |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value secure-jdbc on XPath //*[local-name()='transport']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 1-way on XPath //*[local-name()='transport'][@name="secure-jdbc"]/*[local-name()='ssl']/@authentication-mode 
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value TLSv1.2 on XPath //*[local-name()='transport'][@name="secure-jdbc"]/*[local-name()='ssl']/@ssl-protocol
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value SunX509 on XPath //*[local-name()='transport'][@name="secure-jdbc"]/*[local-name()='ssl']/@keymanagement-algorithm
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /etc/jdv-secret-volume/keystore.jks on XPath //*[local-name()='transport'][@name="secure-jdbc"]/*[local-name()='ssl']/*[local-name()='keystore']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /etc/jdv-secret-volume/keystore.jks on XPath //*[local-name()='transport'][@name="secure-jdbc"]/*[local-name()='ssl']/*[local-name()='truststore']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value secure-odbc on XPath //*[local-name()='transport']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 1-way on XPath //*[local-name()='transport'][@name="secure-odbc"]/*[local-name()='ssl']/@authentication-mode
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value TLSv1.2 on XPath //*[local-name()='transport'][@name="secure-odbc"]/*[local-name()='ssl']/@ssl-protocol
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value SunX509 on XPath //*[local-name()='transport'][@name="secure-odbc"]/*[local-name()='ssl']/@keymanagement-algorithm
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /etc/jdv-secret-volume/keystore.jks on XPath //*[local-name()='transport'][@name="secure-odbc"]/*[local-name()='ssl']/*[local-name()='keystore']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /etc/jdv-secret-volume/keystore.jks on XPath //*[local-name()='transport'][@name="secure-odbc"]/*[local-name()='ssl']/*[local-name()='truststore']/@name

   Scenario: check for secure jdbc/odbc config with anonymous auth mode
    When container is started with env
      | variable                                 | value                                       |
      | DATAVIRT_TRANSPORT_AUTHENTICATION_MODE   | anonymous                                   |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value secure-jdbc on XPath //*[local-name()='transport']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value anonymous on XPath //*[local-name()='transport'][@name="secure-jdbc"]/*[local-name()='ssl']/@authentication-mode
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value secure-odbc on XPath //*[local-name()='transport']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value anonymous on XPath //*[local-name()='transport'][@name="secure-odbc"]/*[local-name()='ssl']/@authentication-mode

    Scenario: check for secure jdbc config with missing config
    When container is started with env
      | variable                                 | value                                       |
      | DATAVIRT_TRANSPORT_AUTHENTICATION_MODE   | 1-way                                       |
      | DATAVIRT_TRANSPORT_KEY_ALIAS             | jboss                                       |
      | DATAVIRT_TRANSPORT_KEYSTORE_PASSWORD     | mykeystorepass                              |
      | DATAVIRT_TRANSPORT_KEYSTORE_DIR          | /etc/jdv-secret-volume                      |
    Then container log should contain WARN Secure JDBC transport missing alias, keystore, key password, and/or keystore directory for authentication mode '1-way'. Will not be enabled
