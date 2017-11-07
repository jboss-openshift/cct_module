@jboss-eap-6/eap64-openshift
Feature: EAP 6.4 Openshift datasources

  Scenario: Test no warning for MongoDB
    When container is started with env
      | variable                      | value              |
      | DB_SERVICE_PREFIX_MAPPING     | eap-app-mongodb=DB |
      | DB_DATABASE                   | mydb               |
      | DB_USERNAME                   | root               |
      | DB_PASSWORD                   | password           |
      | EAP_APP_MONGODB_SERVICE_HOST  | 10.1.1.1           |
      | EAP_APP_MONGODB_SERVICE_PORT  | 27017              |
    Then container log should contain Running jboss-eap-6/eap64-openshift image
     And available container log should not contain There is a problem with the DB_SERVICE_PREFIX_MAPPING environment variable

  Scenario: check refresh interval is not set on the EAP 6.4 datasource when environment variable is specified
    When container is started with env
       | variable                                  | value            |
       | DB_SERVICE_PREFIX_MAPPING                 | test-mysql=TEST |
       | TEST_DATABASE                             | kitchensink      |
       | TEST_USERNAME                             | marek            |
       | TEST_PASSWORD                             | hardtoguess      |
       | TEST_MYSQL_SERVICE_HOST                   | 10.1.1.1         |
       | TEST_MYSQL_SERVICE_PORT                   | 3306             |
       | TIMER_SERVICE_DATA_STORE                  | test-mysql       |
       | TIMER_SERVICE_DATA_STORE_REFRESH_INTERVAL | 9999             |
    Then file /opt/eap/standalone/configuration/standalone-openshift.xml should not contain refresh-interval
