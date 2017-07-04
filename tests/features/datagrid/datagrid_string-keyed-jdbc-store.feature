@openshift @datagrid
Feature: Openshift JDG string-keyed-jdbc-store tests

  Scenario: string-keyed-jdbc-store
    When container is started with env
       | variable                                          | value                            |
       | DEFAULT_JDBC_STORE_TYPE                           | string                           |
       | DEFAULT_JDBC_STORE_DATASOURCE                     | java:jboss/datasources/ExampleDS |
       | DEFAULT_KEYED_TABLE_PREFIX                        | JDG                              |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value java:jboss/datasources/ExampleDS on XPath //*[local-name()='string-keyed-jdbc-store']/@datasource 
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value JDG on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/@prefix

  Scenario: string-keyed-jdbc-store with columns
    When container is started with env
       | variable                                          | value                            |
       | DEFAULT_JDBC_STORE_TYPE                           | string                           |
       | DEFAULT_JDBC_STORE_DATASOURCE                     | java:jboss/datasources/ExampleDS |
       | DEFAULT_KEYED_TABLE_PREFIX                        | JDG                              |
       | DEFAULT_ID_TYPE                                   | VARCHAR                          |
       | DEFAULT_DATA_TYPE                                 | BINARY                           |
       | DEFAULT_TIMESTAMP_TYPE                            | BIGINT                           |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value java:jboss/datasources/ExampleDS on XPath //*[local-name()='string-keyed-jdbc-store']/@datasource
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value JDG on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/@prefix
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value VARCHAR on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/*[local-name()='id-column']/@type
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value BINARY on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/*[local-name()='data-column']/@type
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value BIGINT on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/*[local-name()='timestamp-column']/@type

  Scenario: string-keyed-jdbc-store with only data column
    When container is started with env
       | variable                                          | value                            |
       | DEFAULT_JDBC_STORE_TYPE                           | string                           |
       | DEFAULT_JDBC_STORE_DATASOURCE                     | java:jboss/datasources/ExampleDS |
       | DEFAULT_KEYED_TABLE_PREFIX                        | JDG                              |
       | DEFAULT_DATA_TYPE                                 | BINARY                           |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value java:jboss/datasources/ExampleDS on XPath //*[local-name()='string-keyed-jdbc-store']/@datasource
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value JDG on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/@prefix
    Then file /opt/datagrid/standalone/configuration/clustered-openshift.xml should not contain id-column
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value BINARY on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/*[local-name()='data-column']/@type
    Then file /opt/datagrid/standalone/configuration/clustered-openshift.xml should not contain timestamp-column

  Scenario: string-keyed-jdbc-store with mysql
    When container is started with env
       | variable                                          | value                                |
       | DB_SERVICE_PREFIX_MAPPING                         | jdg-app-mysql=DB                     |
       | DB_DATABASE                                       | mydb                                 |
       | DB_USERNAME                                       | root                                 |
       | DB_PASSWORD                                       | password                             |
       | JDG_APP_MYSQL_SERVICE_HOST                        | 10.1.1.1                             |
       | JDG_APP_MYSQL_SERVICE_PORT                        | 3360                                 |
       | DEFAULT_JDBC_STORE_TYPE                           | string                               |
       | DEFAULT_JDBC_STORE_DATASOURCE                     | java:jboss/datasources/jdg_app_mysql |
       | DEFAULT_KEYED_TABLE_PREFIX                        | JDG                                  |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value id on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/*[local-name()='id-column']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value VARCHAR(255) on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/*[local-name()='id-column']/@type
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value datum on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/*[local-name()='data-column']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value BLOB on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/*[local-name()='data-column']/@type

  Scenario: string-keyed-jdbc-store with mysql and custom JNDI name
    When container is started with env
       | variable                                          | value                            |
       | DB_SERVICE_PREFIX_MAPPING                         | jdg-app-mysql=DB                 |
       | DB_DATABASE                                       | mydb                             |
       | DB_USERNAME                                       | root                             |
       | DB_PASSWORD                                       | password                         |
       | DB_JNDI                                           | java:jboss/datasources/mydb      |
       | JDG_APP_MYSQL_SERVICE_HOST                        | 10.1.1.1                         |
       | JDG_APP_MYSQL_SERVICE_PORT                        | 5432                             |
       | DEFAULT_JDBC_STORE_TYPE                           | string                           |
       | DEFAULT_JDBC_STORE_DATASOURCE                     | java:jboss/datasources/mydb      |
       | DEFAULT_KEYED_TABLE_PREFIX                        | JDG                              |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value id on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/*[local-name()='id-column']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value VARCHAR(255) on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/*[local-name()='id-column']/@type
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value datum on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/*[local-name()='data-column']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value BLOB on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/*[local-name()='data-column']/@type

  Scenario: string-keyed-jdbc-store with postgresql
    When container is started with env
       | variable                                          | value                                     |
       | DB_SERVICE_PREFIX_MAPPING                         | jdg-app-postgresql=DB                     |
       | DB_DATABASE                                       | mydb                                      |
       | DB_USERNAME                                       | root                                      |
       | DB_PASSWORD                                       | password                                  |
       | JDG_APP_POSTGRESQL_SERVICE_HOST                   | 10.1.1.1                                  |
       | JDG_APP_POSTGRESQL_SERVICE_PORT                   | 5432                                      |
       | DEFAULT_JDBC_STORE_TYPE                           | string                                    |
       | DEFAULT_JDBC_STORE_DATASOURCE                     | java:jboss/datasources/jdg_app_postgresql |
       | DEFAULT_KEYED_TABLE_PREFIX                        | JDG                                       |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value datum on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/*[local-name()='data-column']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value BYTEA on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/*[local-name()='data-column']/@type

  Scenario: string-keyed-jdbc-store with postgresql and custom JNDI name
    When container is started with env
       | variable                                          | value                            |
       | DB_SERVICE_PREFIX_MAPPING                         | jdg-app-postgresql=DB            |
       | DB_DATABASE                                       | mydb                             |
       | DB_USERNAME                                       | root                             |
       | DB_PASSWORD                                       | password                         |
       | DB_JNDI                                           | java:jboss/datasources/mydb      |
       | JDG_APP_POSTGRESQL_SERVICE_HOST                   | 10.1.1.1                         |
       | JDG_APP_POSTGRESQL_SERVICE_PORT                   | 3360                             |
       | DEFAULT_JDBC_STORE_TYPE                           | string                           |
       | DEFAULT_JDBC_STORE_DATASOURCE                     | java:jboss/datasources/mydb      |
       | DEFAULT_KEYED_TABLE_PREFIX                        | JDG                              |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value datum on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/*[local-name()='data-column']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value BYTEA on XPath //*[local-name()='string-keyed-jdbc-store']/*[local-name()='string-keyed-table']/*[local-name()='data-column']/@type

  Scenario: CLOUD-406 disable passivation when no eviction strategy isn't set
    When container is started with env
       | variable                                          | value                            |
       | DEFAULT_JDBC_STORE_TYPE                           | string                           |
       | DEFAULT_JDBC_STORE_DATASOURCE                     | java:jboss/datasources/ExampleDS |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value false on XPath //*[local-name()='string-keyed-jdbc-store']/@passivation

  Scenario: CLOUD-406 disable passivation when no eviction strategy is set
    When container is started with env
       | variable                                          | value                            |
       | DEFAULT_CACHE_EVICTION_STRATEGY                   | FIFO                             |
       | DEFAULT_JDBC_STORE_TYPE                           | string                           |
       | DEFAULT_JDBC_STORE_DATASOURCE                     | java:jboss/datasources/ExampleDS |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPath //*[local-name()='string-keyed-jdbc-store']/@passivation
