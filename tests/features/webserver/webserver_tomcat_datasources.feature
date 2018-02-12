@jboss-webserver-3/webserver30-tomcat7-openshift @jboss-webserver-3/webserver31-tomcat7-openshift @jboss-webserver-3/webserver30-tomcat8-openshift @jboss-webserver-3/webserver31-tomcat8-openshift
Feature: Tomcat Openshift datasources

  Scenario: check mysql datasource
    When container is started with env
       | variable                  | value           |
       | DB_SERVICE_PREFIX_MAPPING | test-mysql=TEST |
       | TEST_DATABASE             | kitchensink     |
       | TEST_USERNAME             | marek           |
       | TEST_PASSWORD             | hardtoguess     |
       | TEST_MYSQL_SERVICE_HOST   | 10.1.1.1        |
       | TEST_MYSQL_SERVICE_PORT   | 3306            |
    Then XML file /opt/webserver/conf/context.xml should contain value jboss/datasources/test_mysql on XPath //Resource/@name
    Then XML file /opt/webserver/conf/context.xml should contain value marek on XPath //Resource/@username
    Then XML file /opt/webserver/conf/context.xml should contain value hardtoguess on XPath //Resource/@password
    Then file /opt/webserver/conf/context.xml should contain url="jdbc:mysql://10.1.1.1:3306/kitchensink"

  Scenario: check mysql datasource with advanced settings
    When container is started with env
       | variable                  | value           |
       | DB_SERVICE_PREFIX_MAPPING | test-mysql=TEST |
       | TEST_DATABASE             | kitchensink     |
       | TEST_USERNAME             | marek           |
       | TEST_PASSWORD             | hardtoguess     |
       | TEST_MIN_POOL_SIZE        | 1               |
       | TEST_MAX_POOL_SIZE        | 10              |
       | TEST_TX_ISOLATION         | REPEATABLE_READ |
       | TEST_MYSQL_SERVICE_HOST   | 10.1.1.1        |
       | TEST_MYSQL_SERVICE_PORT   | 3306            |
    Then XML file /opt/webserver/conf/context.xml should contain value jboss/datasources/test_mysql on XPath //Resource/@name
    Then XML file /opt/webserver/conf/context.xml should contain value marek on XPath //Resource/@username
    Then XML file /opt/webserver/conf/context.xml should contain value hardtoguess on XPath //Resource/@password
    Then XML file /opt/webserver/conf/context.xml should contain value 1 on XPath //Resource/@minIdle
    Then XML file /opt/webserver/conf/context.xml should contain value 10 on XPath //Resource/@maxActive
    Then XML file /opt/webserver/conf/context.xml should contain value REPEATABLE_READ on XPath //Resource/@defaultTransactionIsolation
    Then file /opt/webserver/conf/context.xml should contain url="jdbc:mysql://10.1.1.1:3306/kitchensink"

  Scenario: check mysql datasource with partial advanced settings
    When container is started with env
       | variable                  | value           |
       | DB_SERVICE_PREFIX_MAPPING | test-mysql=TEST |
       | TEST_DATABASE             | kitchensink     |
       | TEST_USERNAME             | marek           |
       | TEST_PASSWORD             | hardtoguess     |
       | TEST_MAX_POOL_SIZE        | 10              |
       | TEST_MYSQL_SERVICE_HOST   | 10.1.1.1        |
       | TEST_MYSQL_SERVICE_PORT   | 3306            |
    Then XML file /opt/webserver/conf/context.xml should contain value jboss/datasources/test_mysql on XPath //Resource/@name
    Then XML file /opt/webserver/conf/context.xml should contain value marek on XPath //Resource/@username
    Then XML file /opt/webserver/conf/context.xml should contain value hardtoguess on XPath //Resource/@password
    Then XML file /opt/webserver/conf/context.xml should contain value 10 on XPath //Resource/@maxActive
    Then file /opt/webserver/conf/context.xml should contain url="jdbc:mysql://10.1.1.1:3306/kitchensink"

  Scenario: check postgresql datasource
    When container is started with env
       | variable                      | value                |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=TEST |
       | TEST_DATABASE                 | kitchensink          |
       | TEST_USERNAME                 | marek                |
       | TEST_PASSWORD                 | hardtoguess          |
       | TEST_POSTGRESQL_SERVICE_HOST  | 10.1.1.1             |
       | TEST_POSTGRESQL_SERVICE_PORT  | 5432                 |
    Then XML file /opt/webserver/conf/context.xml should contain value jboss/datasources/test_postgresql on XPath //Resource/@name
    Then XML file /opt/webserver/conf/context.xml should contain value marek on XPath //Resource/@username
    Then XML file /opt/webserver/conf/context.xml should contain value hardtoguess on XPath //Resource/@password
    Then file /opt/webserver/conf/context.xml should contain url="jdbc:postgresql://10.1.1.1:5432/kitchensink"

  Scenario: check postgresql datasource with advanced settings
    When container is started with env
       | variable                      | value                |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=TEST |
       | TEST_DATABASE                 | kitchensink          |
       | TEST_USERNAME                 | marek                |
       | TEST_PASSWORD                 | hardtoguess          |
       | TEST_MIN_POOL_SIZE            | 1                    |
       | TEST_MAX_POOL_SIZE            | 10                   |
       | TEST_TX_ISOLATION             | REPEATABLE_READ      |
       | TEST_POSTGRESQL_SERVICE_HOST  | 10.1.1.1             |
       | TEST_POSTGRESQL_SERVICE_PORT  | 5432                 |
    Then XML file /opt/webserver/conf/context.xml should contain value jboss/datasources/test_postgresql on XPath //Resource/@name
    Then XML file /opt/webserver/conf/context.xml should contain value marek on XPath //Resource/@username
    Then XML file /opt/webserver/conf/context.xml should contain value hardtoguess on XPath //Resource/@password
    Then XML file /opt/webserver/conf/context.xml should contain value 1 on XPath //Resource/@minIdle
    Then XML file /opt/webserver/conf/context.xml should contain value 10 on XPath //Resource/@maxActive
    Then XML file /opt/webserver/conf/context.xml should contain value REPEATABLE_READ on XPath //Resource/@defaultTransactionIsolation
    Then file /opt/webserver/conf/context.xml should contain url="jdbc:postgresql://10.1.1.1:5432/kitchensink"
  Scenario: Check external datasource
    When container is started with env
       | variable                      | value                                         |
       | RESOURCES                     | PG                                            |
       | PG_NAME                       | jboss/datasources/defaultDS                   |
       | PG_TYPE                       | javax.sql.DataSource                          |
       | PG_AUTH                       | Container                                     |
       | PG_USERNAME                   | tombrady                                      |
       | PG_PASSWORD                   | Password1%                                    |
       | PG_DRIVER                     | org.postgresql.Driver                         |
       | PG_PROTOCOL                   | jdbc:postgresql                               |
       | PG_HOST                       | hostname                                      |
       | PG_PORT                       | 5432                                          |
       | PG_DATABASE                   | root                                          |
       | PG_MAX_WAIT                   | 10000                                         |
       | PG_MAX_IDLE                   | 30                                            |
       | PG_VALIDATION_QUERY           | SELECT 1                                      |
       | PG_TEST_WHEN_IDLE             | true                                          |
       | PG_TEST_ON_BORROW             | true                                          |
       | PG_FACTORY                    | org.apache.tomcat.jdbc.pool.DataSourceFactory |
       | PG_TRANSACTION_ISOLATION      | READ_COMMITTED                                |
       | PG_MIN_IDLE                   | 1                                             |
       | PG_MAX_ACTIVE                 | 10                                            |
    Then XML file /opt/webserver/conf/context.xml should contain value jboss/datasources/defaultDS on XPath //Resource/@name
    Then XML file /opt/webserver/conf/context.xml should contain value Container on XPath //Resource/@auth
    Then XML file /opt/webserver/conf/context.xml should contain value tombrady on XPath //Resource/@username
    Then XML file /opt/webserver/conf/context.xml should contain value Password1% on XPath //Resource/@password
    Then XML file /opt/webserver/conf/context.xml should contain value 10000 on XPath //Resource/@maxWait
    Then XML file /opt/webserver/conf/context.xml should contain value 30 on XPath //Resource/@maxIdle
    Then XML file /opt/webserver/conf/context.xml should contain value jdbc:postgresql://hostname:5432/root on XPath //Resource/@url
    Then XML file /opt/webserver/conf/context.xml should contain value javax.sql.DataSource on XPath //Resource/@type
    Then XML file /opt/webserver/conf/context.xml should contain value org.postgresql.Driver on XPath //Resource/@driverClassName
    Then XML file /opt/webserver/conf/context.xml should contain value SELECT 1 on XPath //Resource/@validationQuery
    Then XML file /opt/webserver/conf/context.xml should contain value true on XPath //Resource/@testWhenIdle
    Then XML file /opt/webserver/conf/context.xml should contain value true on XPath //Resource/@testOnBorrow
    Then XML file /opt/webserver/conf/context.xml should contain value org.apache.tomcat.jdbc.pool.DataSourceFactory on XPath //Resource/@factory
    Then XML file /opt/webserver/conf/context.xml should contain value READ_COMMITTED on XPath //Resource/@defaultTransactionIsolation
    Then XML file /opt/webserver/conf/context.xml should contain value 1 on XPath //Resource/@minIdle
    Then XML file /opt/webserver/conf/context.xml should contain value 10 on XPath //Resource/@maxActive

  Scenario: Check external datasource w/url
    When container is started with env
       | variable                      | value                                         |
       | RESOURCES                     | PG                                            |
       | PG_NAME                       | jboss/datasources/defaultDS                   |
       | PG_TYPE                       | javax.sql.DataSource                          |
       | PG_AUTH                       | Container                                     |
       | PG_USERNAME                   | tombrady                                      |
       | PG_PASSWORD                   | Password1%                                    |
       | PG_DRIVER                     | org.postgresql.Driver                         |
       | PG_URL                        | jdbc:postgresql://hostname:5432/root          |
       | PG_MAX_WAIT                   | 10000                                         |
       | PG_MAX_IDLE                   | 30                                            |
       | PG_VALIDATION_QUERY           | SELECT 1                                      |
       | PG_TEST_WHEN_IDLE             | true                                          |
       | PG_TEST_ON_BORROW             | true                                          |
       | PG_FACTORY                    | org.apache.tomcat.jdbc.pool.DataSourceFactory |
       | PG_TRANSACTION_ISOLATION      | READ_COMMITTED                                |
       | PG_MIN_IDLE                   | 1                                             |
       | PG_MAX_ACTIVE                 | 10                                            |
    Then XML file /opt/webserver/conf/context.xml should contain value jboss/datasources/defaultDS on XPath //Resource/@name
    Then XML file /opt/webserver/conf/context.xml should contain value Container on XPath //Resource/@auth
    Then XML file /opt/webserver/conf/context.xml should contain value tombrady on XPath //Resource/@username
    Then XML file /opt/webserver/conf/context.xml should contain value Password1% on XPath //Resource/@password
    Then XML file /opt/webserver/conf/context.xml should contain value 10000 on XPath //Resource/@maxWait
    Then XML file /opt/webserver/conf/context.xml should contain value 30 on XPath //Resource/@maxIdle
    Then XML file /opt/webserver/conf/context.xml should contain value jdbc:postgresql://hostname:5432/root on XPath //Resource/@url
    Then XML file /opt/webserver/conf/context.xml should contain value javax.sql.DataSource on XPath //Resource/@type
    Then XML file /opt/webserver/conf/context.xml should contain value org.postgresql.Driver on XPath //Resource/@driverClassName
    Then XML file /opt/webserver/conf/context.xml should contain value SELECT 1 on XPath //Resource/@validationQuery
    Then XML file /opt/webserver/conf/context.xml should contain value true on XPath //Resource/@testWhenIdle
    Then XML file /opt/webserver/conf/context.xml should contain value true on XPath //Resource/@testOnBorrow
    Then XML file /opt/webserver/conf/context.xml should contain value org.apache.tomcat.jdbc.pool.DataSourceFactory on XPath //Resource/@factory
    Then XML file /opt/webserver/conf/context.xml should contain value READ_COMMITTED on XPath //Resource/@defaultTransactionIsolation
    Then XML file /opt/webserver/conf/context.xml should contain value 1 on XPath //Resource/@minIdle
    Then XML file /opt/webserver/conf/context.xml should contain value 10 on XPath //Resource/@maxActive

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
    Then XML file /opt/webserver/conf/context.xml should contain value jboss/datasources/test_mysql on XPath //Resource/@name
    Then XML file /opt/webserver/conf/context.xml should contain value marek-m on XPath //Resource/@username
    Then XML file /opt/webserver/conf/context.xml should contain value hardtoguess-m on XPath //Resource/@password
    Then file /opt/webserver/conf/context.xml should contain url="jdbc:mysql://10.1.1.1:3306/kitchensink-m"
    Then XML file /opt/webserver/conf/context.xml should contain value jboss/datasources/test_postgresql on XPath //Resource/@name
    Then XML file /opt/webserver/conf/context.xml should contain value marek-p on XPath //Resource/@username
    Then XML file /opt/webserver/conf/context.xml should contain value hardtoguess-p on XPath //Resource/@password
    Then file /opt/webserver/conf/context.xml should contain url="jdbc:postgresql://10.1.1.2:5432/kitchensink-p"

  Scenario: check postgresql datasource with custom jndi name
    When container is started with env
       | variable                      | value                |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=TEST |
       | TEST_DATABASE                 | kitchensink          |
       | TEST_USERNAME                 | marek                |
       | TEST_PASSWORD                 | hardtoguess          |
       | TEST_JNDI                     | jndi/customDS        |
       | TEST_POSTGRESQL_SERVICE_HOST  | 10.1.1.1             |
       | TEST_POSTGRESQL_SERVICE_PORT  | 5432                 |
    Then XML file /opt/webserver/conf/context.xml should contain value jndi/customDS on XPath //Resource/@name
    Then XML file /opt/webserver/conf/context.xml should contain value marek on XPath //Resource/@username
    Then XML file /opt/webserver/conf/context.xml should contain value hardtoguess on XPath //Resource/@password
    Then file /opt/webserver/conf/context.xml should contain url="jdbc:postgresql://10.1.1.1:5432/kitchensink"

  Scenario: check that datasource is not created for mongodb
    When container is started with env
    | variable                  | value             |
    | DB_SERVICE_PREFIX_MAPPING | test-mongodb=TEST |
    | TEST_DATABASE             | kitchensink       |
    | TEST_USERNAME             | marek             |
    | TEST_PASSWORD             | hardtoguess       |
    | TEST_MONGODB_SERVICE_HOST | 10.1.1.1          |
    | TEST_MONGODB_SERVICE_PORT | 3306              |
    Then XML file /opt/webserver/conf/context.xml should have 0 elements on XPath //Resource

  Scenario: Test warning no username is provided
    When container is started with env
       | variable                      | value                |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=TEST |
       | TEST_DATABASE                 | kitchensink          |
       | TEST_PASSWORD                 | hardtoguess          |
       | TEST_POSTGRESQL_SERVICE_HOST  | 10.1.1.1             |
       | TEST_POSTGRESQL_SERVICE_PORT  | 5432                 |
    Then container log should contain WARN The postgresql datasource for TEST service WILL NOT be configured.
    And container log should contain TEST_DATABASE: kitchensink
    And container log should contain TEST_PASSWORD: hardtoguess

  Scenario: Test warning no password is provided
    When container is started with env
       | variable                      | value                |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=TEST |
       | TEST_DATABASE                 | kitchensink          |
       | TEST_USERNAME                 | marek                |
       | TEST_POSTGRESQL_SERVICE_HOST  | 10.1.1.1             |
       | TEST_POSTGRESQL_SERVICE_PORT  | 5432                 |
    Then container log should contain WARN The postgresql datasource for TEST service WILL NOT be configured.
    And container log should contain TEST_DATABASE: kitchensink
    And container log should contain TEST_USERNAME: marek

  Scenario: Test warning no database is provided
    When container is started with env
       | variable                      | value                |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=TEST |
       | TEST_USERNAME                 | marek                |
       | TEST_PASSWORD                 | hardtoguess          |
       | TEST_POSTGRESQL_SERVICE_HOST  | 10.1.1.1             |
       | TEST_POSTGRESQL_SERVICE_PORT  | 5432                 |
   Then container log should contain WARN The postgresql datasource for TEST service WILL NOT be configured.
   And container log should contain TEST_PASSWORD: hardtoguess
   And container log should contain TEST_USERNAME: marek

  Scenario: Test warning on wrong mapping
    When container is started with env
       | variable                      | value                              |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=MAREK,abc-mysql=DB |
   Then container log should contain You provided following database mapping (via DB_SERVICE_PREFIX_MAPPING environment variable): test-postgresql=MAREK. To configure datasources we expect TEST_POSTGRESQL_SERVICE_HOST and TEST_POSTGRESQL_SERVICE_PORT to be set
   And container log should contain You provided following database mapping (via DB_SERVICE_PREFIX_MAPPING environment variable): abc-mysql=DB. To configure datasources we expect ABC_MYSQL_SERVICE_HOST and ABC_MYSQL_SERVICE_PORT to be set.
