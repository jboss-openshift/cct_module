@jboss-eap-7/eap70-openshift
Feature: EAP Openshift datasources
  Scenario: check mysql datasource
    Given XML namespaces
    | prefix | url                               |
    | ns     | urn:jboss:domain:datasources:4.0  |
    | ns2    | urn:jboss:domain:batch-jberet:1.0 |
    When container is started with env
       | variable                  | value           |
       | DB_SERVICE_PREFIX_MAPPING | test-mysql=TEST |
       | TEST_DATABASE             | kitchensink     |
       | TEST_USERNAME             | marek           |
       | TEST_PASSWORD             | hardtoguess     |
       | TEST_MYSQL_SERVICE_HOST   | 10.1.1.1        |
       | TEST_MYSQL_SERVICE_PORT   | 3306            |
       | DEFAULT_JOB_REPOSITORY    | test-mysql      |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_mysql on XPath //ns:xa-datasource/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_mysql-TEST on XPath //ns:xa-datasource/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 3306 on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="Port"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek on XPath //ns:xa-datasource/ns:security/ns:user-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess on XPath //ns:xa-datasource/ns:security/ns:password
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_mysql-TEST on XPath //ns2:default-job-repository/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_mysql-TEST on XPath //ns2:job-repository[@name="test_mysql-TEST"]/ns2:jdbc/@data-source

  Scenario: check mysql datasource with advanced settings
    Given XML namespaces
    | prefix | url                              |
    | ns     | urn:jboss:domain:datasources:4.0 |
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
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_mysql on XPath //ns:xa-datasource/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_mysql-TEST on XPath //ns:xa-datasource/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 3306 on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="Port"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 1 on XPath //ns:xa-datasource/ns:xa-pool/ns:min-pool-size
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10 on XPath //ns:xa-datasource/ns:xa-pool/ns:max-pool-size
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek on XPath //ns:xa-datasource/ns:security/ns:user-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess on XPath //ns:xa-datasource/ns:security/ns:password
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value TRANSACTION_REPEATABLE_READ on XPath //ns:xa-datasource/ns:transaction-isolation

  Scenario: check mysql datasource nonxa and jta true
    Given XML namespaces
    | prefix | url                              |
    | ns     | urn:jboss:domain:datasources:4.0 |
    When container is started with env
       | variable                  | value                       |
       | DB_SERVICE_PREFIX_MAPPING | test-mysql=TEST             |
       | TEST_DATABASE             | kitchensink                 |
       | TEST_USERNAME             | marek                       |
       | TEST_PASSWORD             | hardtoguess                 |
       | TEST_MIN_POOL_SIZE        | 1                           |
       | TEST_MAX_POOL_SIZE        | 10                          |
       | TEST_MYSQL_SERVICE_HOST   | 10.1.1.1                    |
       | TEST_MYSQL_SERVICE_PORT   | 3306                        |
       | TEST_NONXA                | true                        |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mysql on XPath //ns:datasource/ns:driver
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value true on XPath //ns:datasource/@jta
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_mysql on XPath //ns:datasource/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_mysql-TEST on XPath //ns:datasource/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:mysql://10.1.1.1:3306/kitchensink on XPath //ns:connection-url
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 1 on XPath //ns:datasource/ns:pool/ns:min-pool-size
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10 on XPath //ns:datasource/ns:pool/ns:max-pool-size
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek on XPath //ns:security/ns:user-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess on XPath //ns:security/ns:password
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLValidConnectionChecker on XPath //ns:valid-connection-checker/@class-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLExceptionSorter on XPath //ns:exception-sorter/@class-name

  Scenario: check mysql datasource nonxa and jta false
    Given XML namespaces
    | prefix | url                              |
    | ns     | urn:jboss:domain:datasources:4.0 |
    When container is started with env
       | variable                  | value                       |
       | DB_SERVICE_PREFIX_MAPPING | test-mysql=TEST             |
       | TEST_DATABASE             | kitchensink                 |
       | TEST_USERNAME             | marek                       |
       | TEST_PASSWORD             | hardtoguess                 |
       | TEST_MIN_POOL_SIZE        | 1                           |
       | TEST_MAX_POOL_SIZE        | 10                          |
       | TEST_MYSQL_SERVICE_HOST   | 10.1.1.1                    |
       | TEST_MYSQL_SERVICE_PORT   | 3306                        |
       | TEST_NONXA                | true                        |
       | TEST_JTA                  | false                       |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mysql on XPath //ns:datasource/ns:driver
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //ns:datasource/@jta
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_mysql on XPath //ns:datasource/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_mysql-TEST on XPath //ns:datasource/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:mysql://10.1.1.1:3306/kitchensink on XPath //ns:connection-url
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 1 on XPath //ns:datasource/ns:pool/ns:min-pool-size
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10 on XPath //ns:datasource/ns:pool/ns:max-pool-size
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek on XPath //ns:security/ns:user-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess on XPath //ns:security/ns:password
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLValidConnectionChecker on XPath //ns:valid-connection-checker/@class-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLExceptionSorter on XPath //ns:exception-sorter/@class-name

  Scenario: check postgresql datasource nonxa and jta true
    Given XML namespaces
    | prefix | url                              |
    | ns     | urn:jboss:domain:datasources:4.0 |
    When container is started with env
       | variable                       | value                       |
       | DB_SERVICE_PREFIX_MAPPING      | test-postgresql=TEST        |
       | TEST_DATABASE                  | kitchensink                 |
       | TEST_USERNAME                  | marek                       |
       | TEST_PASSWORD                  | hardtoguess                 |
       | TEST_MIN_POOL_SIZE             | 1                           |
       | TEST_MAX_POOL_SIZE             | 10                          |
       | TEST_POSTGRESQL_SERVICE_HOST   | 10.1.1.1                    |
       | TEST_POSTGRESQL_SERVICE_PORT   | 3306                        |
       | TEST_NONXA                     | true                        |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value postgresql on XPath //ns:datasource/ns:driver
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value true on XPath //ns:datasource/@jta
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_postgresql on XPath //ns:datasource/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_postgresql-TEST on XPath //ns:datasource/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:postgresql://10.1.1.1:3306/kitchensink on XPath //ns:connection-url
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 1 on XPath //ns:datasource/ns:pool/ns:min-pool-size
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10 on XPath //ns:datasource/ns:pool/ns:max-pool-size
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek on XPath //ns:security/ns:user-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess on XPath //ns:security/ns:password
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLValidConnectionChecker on XPath //ns:valid-connection-checker/@class-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLExceptionSorter on XPath //ns:exception-sorter/@class-name

  Scenario: check postgresql datasource nonxa and jta false
    Given XML namespaces
    | prefix | url                              |
    | ns     | urn:jboss:domain:datasources:4.0 |
    When container is started with env
       | variable                       | value                       |
       | DB_SERVICE_PREFIX_MAPPING      | test-postgresql=TEST        |
       | TEST_DATABASE                  | kitchensink                 |
       | TEST_USERNAME                  | marek                       |
       | TEST_PASSWORD                  | hardtoguess                 |
       | TEST_MIN_POOL_SIZE             | 1                           |
       | TEST_MAX_POOL_SIZE             | 10                          |
       | TEST_POSTGRESQL_SERVICE_HOST   | 10.1.1.1                    |
       | TEST_POSTGRESQL_SERVICE_PORT   | 3306                        |
       | TEST_NONXA                     | true                        |
       | TEST_JTA                       | false                       |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value postgresql on XPath //ns:datasource/ns:driver
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //ns:datasource/@jta
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_postgresql on XPath //ns:datasource/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_postgresql-TEST on XPath //ns:datasource/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:postgresql://10.1.1.1:3306/kitchensink on XPath //ns:connection-url
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 1 on XPath //ns:datasource/ns:pool/ns:min-pool-size
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10 on XPath //ns:datasource/ns:pool/ns:max-pool-size
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek on XPath //ns:security/ns:user-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess on XPath //ns:security/ns:password
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLValidConnectionChecker on XPath //ns:valid-connection-checker/@class-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLExceptionSorter on XPath //ns:exception-sorter/@class-name


  Scenario: check mysql datasource with partial advanced settings
    Given XML namespaces
    | prefix | url                              |
    | ns     | urn:jboss:domain:datasources:4.0 |
    When container is started with env
       | variable                  | value                       |
       | DB_SERVICE_PREFIX_MAPPING | test-mysql=TEST             |
       | TEST_DATABASE             | kitchensink                 |
       | TEST_USERNAME             | marek                       |
       | TEST_PASSWORD             | hardtoguess                 |
       | TEST_MAX_POOL_SIZE        | 10                          |
       | TEST_MYSQL_SERVICE_HOST   | 10.1.1.1                    |
       | TEST_MYSQL_SERVICE_PORT   | 3306                        |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_mysql on XPath //ns:xa-datasource/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_mysql-TEST on XPath //ns:xa-datasource/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 3306 on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="Port"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10 on XPath //ns:xa-datasource/ns:xa-pool/ns:max-pool-size
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek on XPath //ns:xa-datasource/ns:security/ns:user-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess on XPath //ns:xa-datasource/ns:security/ns:password

  Scenario: check postgresql datasource
    Given XML namespaces
    | prefix | url                               |
    | ns     | urn:jboss:domain:datasources:4.0  |
    | ns2    | urn:jboss:domain:batch-jberet:1.0 |
    When container is started with env
       | variable                      | value                |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=TEST |
       | TEST_DATABASE                 | kitchensink          |
       | TEST_USERNAME                 | marek                |
       | TEST_PASSWORD                 | hardtoguess          |
       | TEST_POSTGRESQL_SERVICE_HOST  | 10.1.1.1             |
       | TEST_POSTGRESQL_SERVICE_PORT  | 5432                 |
       | DEFAULT_JOB_REPOSITORY        | test-postgresql      |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_postgresql on XPath //ns:xa-datasource/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_postgresql-TEST on XPath //ns:xa-datasource/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 5432 on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="PortNumber"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek on XPath //ns:xa-datasource/ns:security/ns:user-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess on XPath //ns:xa-datasource/ns:security/ns:password
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_postgresql-TEST on XPath //ns2:default-job-repository/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_postgresql-TEST on XPath //ns2:job-repository[@name="test_postgresql-TEST"]/ns2:jdbc/@data-source

  Scenario: check postgresql datasource with advanced settings
    Given XML namespaces
    | prefix | url                              |
    | ns     | urn:jboss:domain:datasources:4.0 |
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
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_postgresql on XPath //ns:xa-datasource/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_postgresql-TEST on XPath //ns:xa-datasource/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 5432 on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="PortNumber"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek on XPath //ns:xa-datasource/ns:security/ns:user-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess on XPath //ns:xa-datasource/ns:security/ns:password
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 1 on XPath //ns:xa-datasource/ns:xa-pool/ns:min-pool-size
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10 on XPath //ns:xa-datasource/ns:xa-pool/ns:max-pool-size
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value TRANSACTION_REPEATABLE_READ on XPath //ns:xa-datasource/ns:transaction-isolation

  # https://issues.jboss.org/browse/CLOUD-509
  Scenario: check default for job repository
    When container is ready
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value in-memory on XPath //*[local-name()='default-job-repository']/@name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='job-repository']

  Scenario: Test no warning for MongoDB
    When container is started with env
      | variable                      | value              |
      | DB_SERVICE_PREFIX_MAPPING     | eap-app-mongodb=DB |
      | DB_DATABASE                   | mydb               |
      | DB_USERNAME                   | root               |
      | DB_PASSWORD                   | password           |
      | EAP_APP_MONGODB_SERVICE_HOST  | 10.1.1.1           |
      | EAP_APP_MONGODB_SERVICE_PORT  | 27017              |
    Then container log should contain Running jboss-eap-7/eap70-openshift image
     And available container log should not contain There is a problem with the DB_SERVICE_PREFIX_MAPPING environment variable

  Scenario: Test database type is extracted properly even when name contains a dash (e.g. "eap-app")
    Given XML namespaces
    | prefix | url                              |
    | ns     | urn:jboss:domain:datasources:4.0 |
    When container is started with env
      | variable                         | value                   |
      | DB_SERVICE_PREFIX_MAPPING        | eap-app-postgresql=TEST |
      | TEST_DATABASE                    | kitchensink             |
      | TEST_USERNAME                    | marek                   |
      | TEST_PASSWORD                    | hardtoguess             |
      | EAP_APP_POSTGRESQL_SERVICE_HOST  | 10.1.1.1                |
      | EAP_APP_POSTGRESQL_SERVICE_PORT  | 5432                    |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/eap_app_postgresql on XPath //ns:xa-datasource/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value eap_app_postgresql-TEST on XPath //ns:xa-datasource/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 5432 on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="PortNumber"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek on XPath //ns:xa-datasource/ns:security/ns:user-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess on XPath //ns:xa-datasource/ns:security/ns:password

  Scenario: check mysql and postgresql datasource
    Given XML namespaces
    | prefix | url                              |
    | ns     | urn:jboss:domain:datasources:4.0 |
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
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_postgresql on XPath //ns:xa-datasource/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_postgresql-TEST_POSTGRESQL on XPath //ns:xa-datasource/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 5432 on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="PortNumber"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink-p on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek-p on XPath //ns:xa-datasource/ns:security/ns:user-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess-p on XPath //ns:xa-datasource/ns:security/ns:password
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/test_mysql on XPath //ns:xa-datasource/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value test_mysql-TEST_MYSQL on XPath //ns:xa-datasource/@pool-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 10.1.1.1 on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="ServerName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 3306 on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="Port"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value kitchensink-m on XPath //ns:xa-datasource/ns:xa-datasource-property[@name="DatabaseName"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value marek-m on XPath //ns:xa-datasource/ns:security/ns:user-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value hardtoguess-m on XPath //ns:xa-datasource/ns:security/ns:password

  Scenario: check theat exampleDS is generated by default (CLOUD-7)
    Given XML namespaces
    | prefix | url                              |
    | ns     | urn:jboss:domain:datasources:4.0 |
    When container is ready
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE on XPath //ns:datasource[@jndi-name="java:jboss/datasources/ExampleDS"][@pool-name="ExampleDS"][@enabled="true"][@use-java-context="true"][ns:driver='h2'][ns:security[ns:user-name='sa'][ns:password='sa']]/ns:connection-url

  Scenario: Test warning no username is provided
    When container is started with env
       | variable                      | value                |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=TEST |
       | TEST_DATABASE                 | kitchensink          |
       | TEST_PASSWORD                 | hardtoguess          |
       | TEST_POSTGRESQL_SERVICE_HOST  | 10.1.1.1             |
       | TEST_POSTGRESQL_SERVICE_PORT  | 5432                 |
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

  Scenario: Test warning no password is provided
    When container is started with env
       | variable                      | value                |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=TEST |
       | TEST_DATABASE                 | kitchensink          |
       | TEST_USERNAME                 | marek                |
       | TEST_POSTGRESQL_SERVICE_HOST  | 10.1.1.1             |
       | TEST_POSTGRESQL_SERVICE_PORT  | 5432                 |
    Then container log should contain WARN The postgresql datasource for TEST service WILL NOT be configured.
    And container log should contain TEST_JNDI: java:jboss/datasources/test_postgresql
    And container log should contain TEST_USERNAME: marek

  Scenario: Test warning no database is provided
    When container is started with env
       | variable                      | value                |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=TEST |
       | TEST_USERNAME                 | marek                |
       | TEST_PASSWORD                 | hardtoguess          |
       | TEST_POSTGRESQL_SERVICE_HOST  | 10.1.1.1             |
       | TEST_POSTGRESQL_SERVICE_PORT  | 5432                 |
    Then container log should contain WARN Missing configuration for datasource TEST. TEST_POSTGRESQL_SERVICE_HOST, TEST_POSTGRESQL_SERVICE_PORT, and/or TEST_DATABASE is missing. Datasource will not be configured.

  Scenario: Test warning on wrong mapping
    When container is started with env
       | variable                      | value                              |
       | DB_SERVICE_PREFIX_MAPPING     | test-postgresql=MAREK,abc-mysql=DB |
       | MAREK_USERNAME                | marek                              |
       | MAREK_PASSWORD                | hardtoguess                        |
    Then container log should contain WARN Missing configuration for datasource MAREK. TEST_POSTGRESQL_SERVICE_HOST, TEST_POSTGRESQL_SERVICE_PORT, and/or MAREK_DATABASE is missing. Datasource will not be configured.
    And container log should contain In order to configure mysql datasource for DB service you need to provide following environment variables: DB_USERNAME and DB_PASSWORD.   
