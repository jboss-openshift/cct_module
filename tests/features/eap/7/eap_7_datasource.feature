@redhat-sso-7/sso71-openshift
Feature: EAP 7 Openshift datasources

  Scenario: CLOUD-2068, test timer datasource refresh-interval
    When container is started with env
      | variable                                  | value                                  |
      | DATASOURCES                               | TEST                                   |
      | TEST_JNDI                                 | java:/jboss/datasources/testds         |
      | TEST_DRIVER                               | oracle                                 |
      | TEST_USERNAME                             | tombrady                               |
      | TEST_PASSWORD                             | password                               |
      | TEST_URL                                  | jdbc:oracle:thin:@10.1.1.1:1521:testdb |
      | TEST_NONXA                                | true                                   |
      | TEST_JTA                                  | true                                   |
      | TIMER_SERVICE_DATA_STORE                  | TEST                                   |
      | TIMER_SERVICE_DATA_STORE_REFRESH_INTERVAL | 60000                                  |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/jboss/datasources/testds on XPath //*[local-name()='datasource']/@jndi-name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:oracle:thin:@10.1.1.1:1521:testdb on XPath //*[local-name()='connection-url']
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value oracle on XPath //*[local-name()='datasource']/*[local-name()='driver']
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value tombrady on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='user-name']
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value password on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='password']
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test-TEST_part on XPath //*[local-name()='database-data-store']/@partition
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 60000 on XPath //*[local-name()='database-data-store']/@refresh-interval

  Scenario: CLOUD-2068, test timer datasource refresh-interval
    When container is started with env
      | variable                 | value                                  |
      | DATASOURCES              | TEST                                   |
      | TEST_JNDI                | java:/jboss/datasources/testds         |
      | TEST_DRIVER              | oracle                                 |
      | TEST_USERNAME            | tombrady                               |
      | TEST_PASSWORD            | password                               |
      | TEST_URL                 | jdbc:oracle:thin:@10.1.1.1:1521:testdb |
      | TEST_NONXA               | true                                   |
      | TEST_JTA                 | true                                   |
      | TIMER_SERVICE_DATA_STORE | TEST                                   |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/jboss/datasources/testds on XPath //*[local-name()='datasource']/@jndi-name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:oracle:thin:@10.1.1.1:1521:testdb on XPath //*[local-name()='connection-url']
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value oracle on XPath //*[local-name()='datasource']/*[local-name()='driver']
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value tombrady on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='user-name']
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value password on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='password']
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test-TEST_part on XPath //*[local-name()='database-data-store']/@partition
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value -1 on XPath //*[local-name()='database-data-store']/@refresh-interval

  Scenario: Test background-validation configuration with custom background-validation-milis value
    When container is started with env
      | variable                                  | value                |
      | DB_SERVICE_PREFIX_MAPPING                 | test-postgresql=TEST |
      | TEST_DATABASE                             | 007                  |
      | TEST_USERNAME                             | hello                |
      | TEST_PASSWORD                             | world                |
      | TEST_POSTGRESQL_SERVICE_HOST              | 10.1.1.1             |
      | TEST_POSTGRESQL_SERVICE_PORT              | 5432                 |
      | TEST_NONXA                                | true                 |
      | TEST_BACKGROUND_VALIDATION                | true                 |
      | TEST_BACKGROUND_VALIDATION_MILLIS         | 3000                 |
      | TIMER_SERVICE_DATA_STORE_REFRESH_INTERVAL | 60000                |
      | TIMER_SERVICE_DATA_STORE                  | test-postgresql      |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_postgresql on XPath //*[local-name()='datasource']/@jndi-name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hello on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='user-name']
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value world on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='password']
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //*[local-name()='validation']/*[local-name()='validate-on-match']
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value true on XPath //*[local-name()='validation']/*[local-name()='background-validation']
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 3000 on XPath //*[local-name()='validation']/*[local-name()='background-validation-millis']
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 60000 on XPath //*[local-name()='database-data-store']/@refresh-interval
