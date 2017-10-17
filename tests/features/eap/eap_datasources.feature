@jboss-eap-6/eap64-openshift @jboss-eap-7
Feature: EAP Openshift datasources

  Scenario: check mysql datasource
    When container is started with env
       | variable                  | value            |
       | DB_SERVICE_PREFIX_MAPPING | test-mysql=TEST |
       | TEST_DATABASE             | kitchensink      |
       | TEST_USERNAME             | marek            |
       | TEST_PASSWORD             | hardtoguess      |
       | TEST_MYSQL_SERVICE_HOST   | 10.1.1.1         |
       | TEST_MYSQL_SERVICE_PORT   | 3306             |
       | TIMER_SERVICE_DATA_STORE  | test-mysql       |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_mysql on XPath //*[local-name()='xa-datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_mysql-TEST on XPath //*[local-name()='xa-datasource']/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //*[local-name()='xa-datasource-property'][@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 3306 on XPath //*[local-name()='xa-datasource-property'][@name="Port"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink on XPath //*[local-name()='xa-datasource-property'][@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='password']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_mysql-TEST_ds on XPath //*[local-name()='timer-service']/@default-data-store
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_mysql-TEST_ds on XPath //*[local-name()='database-data-store']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_mysql on XPath //*[local-name()='database-data-store']/@datasource-jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mysql on XPath //*[local-name()='database-data-store']/@database
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_mysql-TEST_part on XPath //*[local-name()='database-data-store']/@partition

  Scenario: check mysql datasource with advanced settings
    When container is started with env
       | variable                  | value                       |
       | DB_SERVICE_PREFIX_MAPPING | test-mysql=TEST             |
       | TEST_DATABASE             | kitchensink                 |
       | TEST_USERNAME             | marek                       |
       | TEST_PASSWORD             | hardtoguess                 |
       | TEST_MIN_POOL_SIZE        | 1                           |
       | TEST_MAX_POOL_SIZE        | 10                          |
       | TEST_TX_ISOLATION         | TRANSACTION_REPEATABLE_READ |
       | TEST_MYSQL_SERVICE_HOST   | 10.1.1.1                    |
       | TEST_MYSQL_SERVICE_PORT   | 3306                        |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_mysql on XPath //*[local-name()='xa-datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_mysql-TEST on XPath //*[local-name()='xa-datasource']/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 3306 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="Port"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 1 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-pool']/*[local-name()='min-pool-size']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-pool']/*[local-name()='max-pool-size']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='password']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value TRANSACTION_REPEATABLE_READ on XPath //*[local-name()='xa-datasource']/*[local-name()='transaction-isolation']

  Scenario: check mysql datasource with partial advanced settings
    When container is started with env
       | variable                  | value                       |
       | DB_SERVICE_PREFIX_MAPPING | test-mysql=TEST             |
       | TEST_DATABASE             | kitchensink                 |
       | TEST_USERNAME             | marek                       |
       | TEST_PASSWORD             | hardtoguess                 |
       | TEST_MAX_POOL_SIZE        | 10                          |
       | TEST_MYSQL_SERVICE_HOST   | 10.1.1.1                    |
       | TEST_MYSQL_SERVICE_PORT   | 3306                        |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_mysql on XPath //*[local-name()='xa-datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_mysql-TEST on XPath //*[local-name()='xa-datasource']/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 3306 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="Port"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-pool']/*[local-name()='max-pool-size']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='password']

  # https://issues.jboss.org/browse/CLOUD-508
  Scenario: check default for timer service datastore
    When container is ready
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value default-file-store on XPath //*[local-name()='file-data-store']/@name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='timer-service']/*[local-name()='data-stores']

  Scenario: check postgresql datasource
    When container is started with env
       | variable                      | value                      |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=TEST       |
       | TEST_DATABASE                 | kitchensink                |
       | TEST_USERNAME                 | marek                      |
       | TEST_PASSWORD                 | hardtoguess                |
       | TEST_POSTGRESQL_SERVICE_HOST  | 10.1.1.1                   |
       | TEST_POSTGRESQL_SERVICE_PORT  | 5432                       |
       | TIMER_SERVICE_DATA_STORE      | test-postgresql            |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_postgresql on XPath //*[local-name()='xa-datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_postgresql-TEST on XPath //*[local-name()='xa-datasource']/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 5432 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="PortNumber"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='password']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_postgresql-TEST_ds on XPath //*[local-name()='timer-service']/@default-data-store
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_postgresql-TEST_ds on XPath //*[local-name()='database-data-store']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_postgresql on XPath //*[local-name()='database-data-store']/@datasource-jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value postgresql on XPath //*[local-name()='database-data-store']/@database
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_postgresql-TEST_part on XPath //*[local-name()='database-data-store']/@partition

  Scenario: check postgresql datasource with advanced settings
    When container is started with env
       | variable                      | value                       |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=TEST        |
       | TEST_DATABASE                 | kitchensink                 |
       | TEST_USERNAME                 | marek                       |
       | TEST_PASSWORD                 | hardtoguess                 |
       | TEST_MIN_POOL_SIZE            | 1                           |
       | TEST_MAX_POOL_SIZE            | 10                          |
       | TEST_TX_ISOLATION             | TRANSACTION_REPEATABLE_READ |
       | TEST_POSTGRESQL_SERVICE_HOST  | 10.1.1.1                    |
       | TEST_POSTGRESQL_SERVICE_PORT  | 5432                        |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_postgresql on XPath //*[local-name()='xa-datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_postgresql-TEST on XPath //*[local-name()='xa-datasource']/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 5432 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="PortNumber"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 1 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-pool']/*[local-name()='min-pool-size']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-pool']/*[local-name()='max-pool-size']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value TRANSACTION_REPEATABLE_READ on XPath //*[local-name()='xa-datasource']/*[local-name()='transaction-isolation']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='password']

  Scenario: Test database type is extracted properly even when name contains a dash (e.g. "eap-app")
    When container is started with env
      | variable                         | value                         |
      | DB_SERVICE_PREFIX_MAPPING        | eap-app-postgresql=TEST       |
      | TEST_DATABASE                    | kitchensink                   |
      | TEST_USERNAME                    | marek                         |
      | TEST_PASSWORD                    | hardtoguess                   |
      | EAP_APP_POSTGRESQL_SERVICE_HOST  | 10.1.1.1                      |
      | EAP_APP_POSTGRESQL_SERVICE_PORT  | 5432                          |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/eap_app_postgresql on XPath //*[local-name()='xa-datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value eap_app_postgresql-TEST on XPath //*[local-name()='xa-datasource']/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 5432 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="PortNumber"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='password']

  Scenario: check mysql and postgresql datasource
    When container is started with env
       | variable                      | value                                                  |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=TEST_POSTGRESQL,test-mysql=TEST_MYSQL  |
       | TEST_MYSQL_DATABASE           | kitchensink-m                                          |
       | TEST_MYSQL_USERNAME           | marek-m                                                |
       | TEST_MYSQL_PASSWORD           | hardtoguess-m                                          |
       | TEST_MYSQL_SERVICE_HOST       | 10.1.1.1                                               |
       | TEST_MYSQL_SERVICE_PORT       | 3306                                                   |
       | TEST_POSTGRESQL_DATABASE      | kitchensink-p                                          |
       | TEST_POSTGRESQL_USERNAME      | marek-p                                                |
       | TEST_POSTGRESQL_PASSWORD      | hardtoguess-p                                          |
       | TEST_POSTGRESQL_SERVICE_HOST  | 10.1.1.2                                               |
       | TEST_POSTGRESQL_SERVICE_PORT  | 5432                                                   |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_postgresql on XPath //*[local-name()='xa-datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_postgresql-TEST_POSTGRESQL on XPath //*[local-name()='xa-datasource']/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 5432 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="PortNumber"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink-p on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek-p on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess-p on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='password']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_mysql on XPath //*[local-name()='xa-datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_mysql-TEST_MYSQL on XPath //*[local-name()='xa-datasource']/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.2 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 3306 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="Port"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink-m on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek-m on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess-m on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='password']

  Scenario: check that exampleDS is generated by default (CLOUD-7)
    When container is started with env
       | variable                      | value                                                  |
       | TIMER_SERVICE_DATA_STORE      | ExampleDS            |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/ExampleDS on XPath //*[local-name()='datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value ExampleDS on XPath //*[local-name()='datasource']/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value ExampleDS_ds on XPath //*[local-name()='database-data-store']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/ExampleDS on XPath //*[local-name()='database-data-store']/@datasource-jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hsql on XPath //*[local-name()='database-data-store']/@database
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value ExampleDS_part on XPath //*[local-name()='database-data-store']/@partition

  Scenario: Test warning no username is provided
    When container is started with env
       | variable                      | value                      |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=TEST       |
       | TEST_DATABASE                 | kitchensink                |
       | TEST_PASSWORD                 | hardtoguess                |
       | TEST_POSTGRESQL_SERVICE_HOST  | 10.1.1.1                   |
       | TEST_POSTGRESQL_SERVICE_PORT  | 5432                       |
    Then container log should contain WARN The postgresql datasource for TEST service WILL NOT be configured.
    And container log should contain TEST_PASSWORD: hardtoguess

  Scenario: Test warning on missing database type
    When container is started with env
       | variable                      | value                |
       | DB_SERVICE_PREFIX_MAPPING     | test=TEST            |
       | TEST_DATABASE                 | kitchensink          |
       | TEST_USERNAME                 | marek                |
       | TEST_PASSWORD                 | hardtoguess          |
       | TEST_SERVICE_HOST             | 10.1.1.1             |
       | TEST_SERVICE_PORT             | 5432                 |
    Then container log should contain The mapping does not contain the database type.
    Then container log should contain WARN The datasource for TEST service WILL NOT be configured.

  @redhat-sso-7/sso71-openshift
  Scenario: Test warning on missing driver
    When container is started with env
       | variable                       | value                                  |
       | DATASOURCES                    | TEST                                   |
       | TEST_JNDI                      | java:/jboss/datasources/testds         |
       | TEST_USERNAME                  | tombrady                               |
       | TEST_PASSWORD                  | password                               |
       | TEST_SERVICE_HOST              | 10.1.1.1                               |
       | TEST_SERVICE_PORT              | 5432                                   |
       | TEST_DATABASE                  | pgdb                                   |
       | TEST_NONXA                     | false                                  |
       | TEST_JTA                       | true                                   |
    Then container log should contain WARN DRIVER not set for datasource TEST. Datasource will not be configured.

  @redhat-sso-7/sso71-openshift
  Scenario: Test postgresql xa datasource extension
    When container is started with env
       | variable                       | value                                  |
       | DATASOURCES                    | TEST                                   |
       | TEST_JNDI                      | java:/jboss/datasources/testds         |
       | TEST_DRIVER                    | postgresql                             |
       | TEST_USERNAME                  | tombrady                               |
       | TEST_PASSWORD                  | password                               |
       | TEST_SERVICE_HOST              | 10.1.1.1                               |
       | TEST_SERVICE_PORT              | 5432                                   |
       | TEST_DATABASE                  | pgdb                                   |
       | TEST_NONXA                     | false                                  |
       | TEST_JTA                       | true                                   |
       | JDBC_STORE_JNDI_NAME           | java:/jboss/datasources/testds         |
       | NODE_NAME                      | TestStoreNodeName                      |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/jboss/datasources/testds on XPath //*[local-name()='xa-datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 5432 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="PortNumber"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pgdb on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value tombrady on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value password on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='password']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 3 elements on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/jboss/datasources/testds on XPath //*[local-name()='jdbc-store']/@datasource-jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value osTestStoreNodeName on XPath //*[local-name()='jdbc-store']/*[local-name()='action']/@table-prefix
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value osTestStoreNodeName on XPath //*[local-name()='jdbc-store']/*[local-name()='communication']/@table-prefix
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value osTestStoreNodeName on XPath //*[local-name()='jdbc-store']/*[local-name()='state']/@table-prefix

  @redhat-sso-7/sso71-openshift
  Scenario: Test postgresql xa datasource extension with TX_DATABASE_PREFIX_MAPPING
    When container is started with env
       | variable                       | value                                  |
       | TX_DATABASE_PREFIX_MAPPING     | TEST_POSTGRESQL                        |
       | TEST_POSTGRESQL_JNDI           | java:/jboss/datasources/testds         |
       | TEST_POSTGRESQL_USERNAME       | tombrady                               |
       | TEST_POSTGRESQL_PASSWORD       | password                               |
       | TEST_POSTGRESQL_SERVICE_HOST   | 10.1.1.1                               |
       | TEST_POSTGRESQL_SERVICE_PORT   | 5432                                   |
       | TEST_POSTGRESQL_DATABASE       | pgdb                                   |
       | NODE_NAME                      | TestStoreNodeName                      |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/jboss/datasources/testdsObjectStore on XPath //*[local-name()='datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //*[local-name()='datasource']/@jta
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_postgresqlObjectStorePool on XPath //*[local-name()='datasource']/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value true on XPath //*[local-name()='datasource']/@enabled
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:postgresql://10.1.1.1:5432/pgdb on XPath //*[local-name()='datasource']/*[local-name()='connection-url']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value postgresql on XPath //*[local-name()='datasource']/*[local-name()='driver']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value tombrady on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value password on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='password']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value osTestStoreNodeName on XPath //*[local-name()='jdbc-store']/*[local-name()='action']/@table-prefix
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value osTestStoreNodeName on XPath //*[local-name()='jdbc-store']/*[local-name()='communication']/@table-prefix
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value osTestStoreNodeName on XPath //*[local-name()='jdbc-store']/*[local-name()='state']/@table-prefix

  @redhat-sso-7/sso71-openshift
  Scenario: Test postgresql xa datasource extension with hyphenated node name
    When container is started with env
       | variable                       | value                                  |
       | DATASOURCES                    | TEST                                   |
       | TEST_JNDI                      | java:/jboss/datasources/testds         |
       | TEST_DRIVER                    | postgresql                             |
       | TEST_USERNAME                  | tombrady                               |
       | TEST_PASSWORD                  | password                               |
       | TEST_SERVICE_HOST              | 10.1.1.1                               |
       | TEST_SERVICE_PORT              | 5432                                   |
       | TEST_DATABASE                  | pgdb                                   |
       | TEST_NONXA                     | false                                  |
       | TEST_JTA                       | true                                   |
       | JDBC_STORE_JNDI_NAME           | java:/jboss/datasources/testds         |
       | NODE_NAME                      | Test-Store-Node-Name                   |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/jboss/datasources/testds on XPath //*[local-name()='xa-datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 5432 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="PortNumber"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pgdb on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value tombrady on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value password on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='password']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 3 elements on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/jboss/datasources/testds on XPath //*[local-name()='jdbc-store']/@datasource-jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value osTestStoreNodeName on XPath //*[local-name()='jdbc-store']/*[local-name()='action']/@table-prefix
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value osTestStoreNodeName on XPath //*[local-name()='jdbc-store']/*[local-name()='communication']/@table-prefix
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value osTestStoreNodeName on XPath //*[local-name()='jdbc-store']/*[local-name()='state']/@table-prefix

  @redhat-sso-7/sso71-openshift
  Scenario: Test postgresql xa datasource extension with TX_DATABASE_PREFIX_MAPPING and hyphenated node name
    When container is started with env
       | variable                       | value                                  |
       | TX_DATABASE_PREFIX_MAPPING     | TEST_POSTGRESQL                        |
       | TEST_POSTGRESQL_JNDI           | java:/jboss/datasources/testds         |
       | TEST_POSTGRESQL_USERNAME       | tombrady                               |
       | TEST_POSTGRESQL_PASSWORD       | password                               |
       | TEST_POSTGRESQL_SERVICE_HOST   | 10.1.1.1                               |
       | TEST_POSTGRESQL_SERVICE_PORT   | 5432                                   |
       | TEST_POSTGRESQL_DATABASE       | pgdb                                   |
       | NODE_NAME                      | Test-Store-Node-Name                   |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/jboss/datasources/testdsObjectStore on XPath //*[local-name()='datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //*[local-name()='datasource']/@jta
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_postgresqlObjectStorePool on XPath //*[local-name()='datasource']/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value true on XPath //*[local-name()='datasource']/@enabled
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:postgresql://10.1.1.1:5432/pgdb on XPath //*[local-name()='datasource']/*[local-name()='connection-url']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value postgresql on XPath //*[local-name()='datasource']/*[local-name()='driver']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value tombrady on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value password on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='password']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value osTestStoreNodeName on XPath //*[local-name()='jdbc-store']/*[local-name()='action']/@table-prefix
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value osTestStoreNodeName on XPath //*[local-name()='jdbc-store']/*[local-name()='communication']/@table-prefix
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value osTestStoreNodeName on XPath //*[local-name()='jdbc-store']/*[local-name()='state']/@table-prefix

  @redhat-sso-7/sso71-openshift
  Scenario: Test postgresql non-xa datasource extension
    When container is started with env
       | variable                       | value                                  |
       | DATASOURCES                    | TEST                                   |
       | TEST_JNDI                      | java:/jboss/datasources/testds         |
       | TEST_DRIVER                    | postgresql                             |
       | TEST_USERNAME                  | tombrady                               |
       | TEST_PASSWORD                  | password                               |
       | TEST_SERVICE_HOST              | 10.1.1.1                               |
       | TEST_SERVICE_PORT              | 5432                                   |
       | TEST_DATABASE                  | pgdb                                   |
       | TEST_NONXA                     | true                                   |
       | TEST_JTA                       | false                                  |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/jboss/datasources/testds on XPath //*[local-name()='datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value tombrady on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value password on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='password']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:postgresql://10.1.1.1:5432/pgdb on XPath //*[local-name()='datasource']/*[local-name()='connection-url']

  @redhat-sso-7/sso71-openshift
  Scenario: Test postgresql xa datasource extension w/URL
    When container is started with env
       | variable                        | value                                  |
       | DATASOURCES                     | TEST                                   |
       | TEST_JNDI                       | java:/jboss/datasources/testds         |
       | TEST_DRIVER                     | postgresql                             |
       | TEST_USERNAME                   | tombrady                               |
       | TEST_PASSWORD                   | password                               |
       | TEST_XA_CONNECTION_PROPERTY_URL | jdbc:postgresql://10.1.1.1:5432/pgdb   |
       | TEST_NONXA                      | false                                  |
       | TEST_JTA                        | true                                   |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/jboss/datasources/testds on XPath //*[local-name()='xa-datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value tombrady on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value password on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='password']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:postgresql://10.1.1.1:5432/pgdb on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="URL"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property']

  @redhat-sso-7/sso71-openshift
  Scenario: Test mysql xa datasource extension
    When container is started with env
       | variable                       | value                                  |
       | DATASOURCES                    | TEST                                   |
       | TEST_JNDI                      | java:/jboss/datasources/testds         |
       | TEST_DRIVER                    | mysql                                  |
       | TEST_USERNAME                  | tombrady                               |
       | TEST_PASSWORD                  | password                               |
       | TEST_SERVICE_HOST              | 10.1.1.1                               |
       | TEST_SERVICE_PORT              | 3306                                   |
       | TEST_DATABASE                  | kitchensink                            |
       | TEST_NONXA                     | false                                  |
       | TEST_JTA                       | true                                   |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/jboss/datasources/testds on XPath //*[local-name()='xa-datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 3306 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="Port"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value tombrady on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value password on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='password']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 3 elements on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property']

  @redhat-sso-7/sso71-openshift
  Scenario: Test mysql non-xa datasource extension
    When container is started with env
       | variable                       | value                                  |
       | DATASOURCES                    | TEST                                   |
       | TEST_JNDI                      | java:/jboss/datasources/testds         |
       | TEST_DRIVER                    | mysql                                  |
       | TEST_USERNAME                  | tombrady                               |
       | TEST_PASSWORD                  | password                               |
       | TEST_SERVICE_HOST              | 10.1.1.1                               |
       | TEST_SERVICE_PORT              | 3306                                   |
       | TEST_DATABASE                  | kitchensink                            |
       | TEST_NONXA                     | true                                   |
       | TEST_JTA                       | false                                  |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/jboss/datasources/testds on XPath //*[local-name()='datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value tombrady on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value password on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='password']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:mysql://10.1.1.1:3306/kitchensink on XPath //*[local-name()='datasource']/*[local-name()='connection-url']

  @redhat-sso-7/sso71-openshift
  Scenario: Test mysql xa datasource extension w/URL
    When container is started with env
       | variable                        | value                                  |
       | DATASOURCES                     | TEST                                   |
       | TEST_JNDI                       | java:/jboss/datasources/testds         |
       | TEST_DRIVER                     | mysql                                  |
       | TEST_USERNAME                   | tombrady                               |
       | TEST_PASSWORD                   | password                               |
       | TEST_XA_CONNECTION_PROPERTY_URL | jdbc:mysql://10.1.1.1:3306/kitchensink |
       | TEST_NONXA                      | false                                  |
       | TEST_JTA                        | true                                   |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/jboss/datasources/testds on XPath //*[local-name()='xa-datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value tombrady on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value password on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='password']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:mysql://10.1.1.1:3306/kitchensink on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="URL"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property']

  @redhat-sso-7/sso71-openshift
  Scenario: Test external xa datasource extension
    When container is started with env
       | variable                          | value                                      |
       | DATASOURCES                       | TEST                                       |
       | TEST_JNDI                         | java:/jboss/datasources/testds             |
       | TEST_DRIVER                       | oracle                                     |
       | TEST_USERNAME                     | tombrady                                   |
       | TEST_PASSWORD                     | password                                   |
       | TEST_XA_CONNECTION_PROPERTY_URL   | jdbc:oracle:thin:@samplehost:1521:oracledb |
       | TEST_NONXA                        | false                                      |
       | TEST_JTA                          | true                                       |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/jboss/datasources/testds on XPath //*[local-name()='xa-datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:oracle:thin:@samplehost:1521:oracledb on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="URL"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value oracle on XPath //*[local-name()='xa-datasource']/*[local-name()='driver']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value tombrady on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value password on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='password']

  @redhat-sso-7/sso71-openshift
  Scenario: Test external non-xa datasource extension
    When container is started with env
       | variable                          | value                                      |
       | DATASOURCES                       | TEST                                       |
       | TEST_JNDI                         | java:/jboss/datasources/testds             |
       | TEST_DRIVER                       | oracle                                     |
       | TEST_USERNAME                     | tombrady                                   |
       | TEST_PASSWORD                     | password                                   |
       | TEST_SERVICE_PORT                 | 1521                                       |
       | TEST_SERVICE_HOST                 | 10.1.1.1                                   |
       | TEST_DATABASE                     | oracledb                                   |
       | TEST_URL                          | jdbc:oracle:thin:@samplehost:1521:oracledb |
       | TEST_NONXA                        | true                                       |
       | TEST_JTA                          | false                                      |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/jboss/datasources/testds on XPath //*[local-name()='datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:oracle:thin:@samplehost:1521:oracledb on XPath //*[local-name()='connection-url']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value oracle on XPath //*[local-name()='datasource']/*[local-name()='driver']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value tombrady on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value password on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='password']

  @redhat-sso-7/sso71-openshift
  Scenario: Test warning no xa-connection-properties for external xa db
    When container is started with env
       | variable                       | value                                  |
       | DATASOURCES                    | TEST                                   |
       | TEST_JNDI                      | java:/jboss/datasources/testds         |
       | TEST_DRIVER                    | oracle                                 |
       | TEST_USERNAME                  | tombrady                               |
       | TEST_PASSWORD                  | password                               |
       | TEST_SERVICE_HOST              | 10.1.1.1                               |
       | TEST_DATABASE                  | testdb                                 |
       | TEST_SERVICE_PORT              | 5432                                   |
       | TEST_NONXA                     | false                                  |
       | TEST_JTA                       | true                                   |
    Then container log should contain WARN At least one TEST_XA_CONNECTION_PROPERTY_property for datasource TEST is required. Datasource will not be configured.

  Scenario: Test warning no password is provided
    When container is started with env
       | variable                      | value                      |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=TEST       |
       | TEST_DATABASE                 | kitchensink                |
       | TEST_USERNAME                 | marek                      |
       | TEST_POSTGRESQL_SERVICE_HOST  | 10.1.1.1                   |
       | TEST_POSTGRESQL_SERVICE_PORT  | 5432                       |
    Then container log should contain WARN The postgresql datasource for TEST service WILL NOT be configured.
    And container log should contain TEST_JNDI: java:jboss/datasources/test_postgresql
    And container log should contain TEST_USERNAME: marek

  Scenario: Test warning no database is provided
    When container is started with env
       | variable                      | value                      |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=TEST       |
       | TEST_USERNAME                 | marek                      |
       | TEST_PASSWORD                 | hardtoguess                |
       | TEST_POSTGRESQL_SERVICE_HOST  | 10.1.1.1                   |
       | TEST_POSTGRESQL_SERVICE_PORT  | 5432                       |
   Then container log should contain WARN Missing configuration for datasource TEST. TEST_POSTGRESQL_SERVICE_HOST, TEST_POSTGRESQL_SERVICE_PORT, and/or TEST_DATABASE is missing. Datasource will not be configured.

  Scenario: Test warning on wrong mapping
    When container is started with env
       | variable                      | value                                      |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=MAREK,abc-mysql=DB         |
       | MAREK_USERNAME                | marek                                      |
       | MAREK_PASSWORD                | hardtoguess                                |
   Then container log should contain WARN Missing configuration for datasource MAREK. TEST_POSTGRESQL_SERVICE_HOST, TEST_POSTGRESQL_SERVICE_PORT, and/or MAREK_DATABASE is missing. Datasource will not be configured.
   And container log should contain In order to configure mysql datasource for DB service you need to provide following environment variables: DB_USERNAME and DB_PASSWORD.

  @redhat-sso-7/sso71-openshift
  Scenario: Test warning for missing postgresql xa properties
    When container is started with env
       | variable                      | value                      |
       | DATASOURCES                   | TEST                       |
       | TEST_USERNAME                 | tombrady                   |
       | TEST_PASSWORD                 | Need6Rings!                |
       | TEST_DRIVER                   | postgresql                 |
    Then container log should contain WARN Missing configuration for XA datasource TEST. Either TEST_XA_CONNECTION_PROPERTY_URL or TEST_XA_CONNECTION_PROPERTY_ServerName, and TEST_XA_CONNECTION_PROPERTY_PortNumber, and TEST_XA_CONNECTION_PROPERTY_DatabaseName is required. Datasource will not be configured.

  @redhat-sso-7/sso71-openshift
  Scenario: Test warning for missing mysql xa properties
    When container is started with env
       | variable                      | value                      |
       | DATASOURCES                   | TEST                       |
       | TEST_USERNAME                 | tombrady                   |
       | TEST_PASSWORD                 | Need6Rings!                |
       | TEST_DRIVER                   | mysql                      |
    Then container log should contain WARN Missing configuration for XA datasource TEST. Either TEST_XA_CONNECTION_PROPERTY_URL or TEST_XA_CONNECTION_PROPERTY_ServerName, and TEST_XA_CONNECTION_PROPERTY_Port, and TEST_XA_CONNECTION_PROPERTY_DatabaseName is required. Datasource will not be configured.

   Scenario: Test multiple datasources with one incorrect
    When container is started with env
       | variable                      | value                                      |
       | DB_SERVICE_PREFIX_MAPPING     | pg-postgresql=PG,mysql-mysql=MYSQL         |
       | PG_USERNAME                   | pguser                                     |
       | PG_PASSWORD                   | pgpass                                     |
       | PG_POSTGRESQL_SERVICE_HOST    | 10.1.1.1                                   |
       | PG_POSTGRESQL_SERVICE_PORT    | 5432                                       |
       | MYSQL_DATABASE                | kitchensink                                |
       | MYSQL_USERNAME                | mysqluser                                  |
       | MYSQL_PASSWORD                | mysqlpass                                  |
       | MYSQL_MYSQL_SERVICE_HOST      | 10.1.1.1                                   |
       | MYSQL_MYSQL_SERVICE_PORT      | 3306                                       |
    Then container log should contain WARN Missing configuration for datasource PG. PG_POSTGRESQL_SERVICE_HOST, PG_POSTGRESQL_SERVICE_PORT, and/or PG_DATABASE is missing. Datasource will not be configured.
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/mysql_mysql on XPath //*[local-name()='xa-datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mysql_mysql-MYSQL on XPath //*[local-name()='xa-datasource']/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 3306 on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="Port"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink on XPath //*[local-name()='xa-datasource']/*[local-name()='xa-datasource-property'][@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mysqluser on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mysqlpass on XPath //*[local-name()='xa-datasource']/*[local-name()='security']/*[local-name()='password']

  Scenario: Test tx db service mapping w/multiple datasources
    When container is started with env
       | variable                      | value                                      |
       | DB_SERVICE_PREFIX_MAPPING     | pg-postgresql=PG,mysql-mysql=MYSQL         |
       | TX_DATABASE_PREFIX_MAPPING    | mysql-mysql=MYSQL                          |
       | PG_DATABASE                   | kitchensink                                |
       | PG_USERNAME                   | pguser                                     |
       | PG_PASSWORD                   | pgpass                                     |
       | PG_POSTGRESQL_SERVICE_HOST    | 10.1.1.1                                   |
       | PG_POSTGRESQL_SERVICE_PORT    | 5432                                       |
       | MYSQL_DATABASE                | kitchensink                                |
       | MYSQL_USERNAME                | mysqluser                                  |
       | MYSQL_PASSWORD                | mysqlpass                                  |
       | MYSQL_MYSQL_SERVICE_HOST      | 10.1.1.1                                   |
       | MYSQL_MYSQL_SERVICE_PORT      | 3306                                       |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/mysql_mysqlObjectStore on XPath //*[local-name()='datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mysql_mysqlObjectStorePool on XPath //*[local-name()='datasource']/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:mysql://10.1.1.1:3306/kitchensink on XPath //*[local-name()='datasource']/*[local-name()='connection-url']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mysql on XPath //*[local-name()='datasource']/*[local-name()='driver']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mysqluser on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mysqlpass on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='password']

  Scenario: Test tx db service mapping w/multiple datasources and tx is first
    When container is started with env
       | variable                      | value                                      |
       | DB_SERVICE_PREFIX_MAPPING     | pg-postgresql=PG,mysql-mysql=MYSQL         |
       | TX_DATABASE_PREFIX_MAPPING    | pg-postgresql=PG                           |
       | PG_DATABASE                   | kitchensink                                |
       | PG_USERNAME                   | pguser                                     |
       | PG_PASSWORD                   | pgpass                                     |
       | PG_POSTGRESQL_SERVICE_HOST    | 10.1.1.1                                   |
       | PG_POSTGRESQL_SERVICE_PORT    | 5432                                       |
       | MYSQL_DATABASE                | kitchensink                                |
       | MYSQL_USERNAME                | mysqluser                                  |
       | MYSQL_PASSWORD                | mysqlpass                                  |
       | MYSQL_MYSQL_SERVICE_HOST      | 10.1.1.1                                   |
       | MYSQL_MYSQL_SERVICE_PORT      | 3306                                       |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/pg_postgresqlObjectStore on XPath //*[local-name()='datasource']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pg_postgresqlObjectStorePool on XPath //*[local-name()='datasource']/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:postgresql://10.1.1.1:5432/kitchensink on XPath //*[local-name()='datasource']/*[local-name()='connection-url']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value postgresql on XPath //*[local-name()='datasource']/*[local-name()='driver']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pguser on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='user-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pgpass on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='password']

  Scenario: Test validation's default configuration
    When container is started with env
      | variable                          | value                                      |
      | DB_SERVICE_PREFIX_MAPPING         | test-postgresql=TEST                       |
      | TEST_DATABASE                     | 007                                        |
      | TEST_USERNAME                     | hello                                      |
      | TEST_PASSWORD                     | world                                      |
      | TEST_POSTGRESQL_SERVICE_HOST      | 10.1.1.1                                   |
      | TEST_POSTGRESQL_SERVICE_PORT      | 5432                                       |
      | TEST_NONXA                        | true                                       |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_postgresql on XPath //*[local-name()='datasource']/@jndi-name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hello on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='user-name']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value world on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='password']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value true on XPath //*[local-name()='validation']/*[local-name()='validate-on-match']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //*[local-name()='validation']/*[local-name()='background-validation']

  Scenario: Test background-validation configuration with default background-validation-milis
    When container is started with env
      | variable                          | value                                      |
      | DB_SERVICE_PREFIX_MAPPING         | test-postgresql=TEST                       |
      | TEST_DATABASE                     | 007                                        |
      | TEST_USERNAME                     | hello                                      |
      | TEST_PASSWORD                     | world                                      |
      | TEST_POSTGRESQL_SERVICE_HOST      | 10.1.1.1                                   |
      | TEST_POSTGRESQL_SERVICE_PORT      | 5432                                       |
      | TEST_NONXA                        | true                                       |
      | TEST_BACKGROUND_VALIDATION        | true                                       |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_postgresql on XPath //*[local-name()='datasource']/@jndi-name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hello on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='user-name']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value world on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='password']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //*[local-name()='validation']/*[local-name()='validate-on-match']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value true on XPath //*[local-name()='validation']/*[local-name()='background-validation']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10000 on XPath //*[local-name()='validation']/*[local-name()='background-validation-millis']

  Scenario: Test background-validation configuration with custom background-validation-milis value
    When container is started with env
      | variable                          | value                                      |
      | DB_SERVICE_PREFIX_MAPPING         | test-postgresql=TEST                       |
      | TEST_DATABASE                     | 007                                        |
      | TEST_USERNAME                     | hello                                      |
      | TEST_PASSWORD                     | world                                      |
      | TEST_POSTGRESQL_SERVICE_HOST      | 10.1.1.1                                   |
      | TEST_POSTGRESQL_SERVICE_PORT      | 5432                                       |
      | TEST_NONXA                        | true                                       |
      | TEST_BACKGROUND_VALIDATION        | true                                       |
      | TEST_BACKGROUND_VALIDATION_MILLIS | 3000                                       |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_postgresql on XPath //*[local-name()='datasource']/@jndi-name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hello on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='user-name']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value world on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='password']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //*[local-name()='validation']/*[local-name()='validate-on-match']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value true on XPath //*[local-name()='validation']/*[local-name()='background-validation']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 3000 on XPath //*[local-name()='validation']/*[local-name()='background-validation-millis']

  Scenario: Test invalid prefix mapping CLOUD-1743
    When container is started with env
      | variable                          | value                                      |
      | DB_SERVICE_PREFIX_MAPPING         | test-microsoftsql=TEST                     |
      | TX_SERVICE_PREFIX_MAPPING         | test-microsoftsql=TEST                     |
      | TEST_JNDI                         | java:/jboss/datasources/testdb             |
      | TEST_DATABASE                     | 007                                        |
      | TEST_USERNAME                     | hello                                      |
      | TEST_PASSWORD                     | world                                      |
     Then container log should contain WARN DRIVER not set for datasource TEST. Datasource will not be configured.
     And container log should not contain sed -e expression #1 
