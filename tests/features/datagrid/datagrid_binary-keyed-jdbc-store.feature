@openshift @datagrid
Feature: Openshift JDG binary-keyed-jdbc-store tests
  Scenario: binary-keyed-jdbc-store
    When container is started with env
       | variable                                          | value                            |
       | DEFAULT_JDBC_STORE_TYPE                           | binary                           |
       | DEFAULT_JDBC_STORE_DATASOURCE                     | java:jboss/datasources/ExampleDS |
       | DEFAULT_KEYED_TABLE_PREFIX                        | JDG                              |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value java:jboss/datasources/ExampleDS on XPath //*[local-name()='binary-keyed-jdbc-store']/@datasource
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value JDG on XPath //*[local-name()='binary-keyed-jdbc-store']/*[local-name()='binary-keyed-table']//@prefix

  Scenario: binary-keyed-jdbc-store with mysql
    When container is started with env
       | variable                                          | value                                |
       | DB_SERVICE_PREFIX_MAPPING                         | jdg-app-mysql=DB                     |
       | DB_DATABASE                                       | mydb                                 |
       | DB_USERNAME                                       | root                                 |
       | DB_PASSWORD                                       | password                             |
       | JDG_APP_MYSQL_SERVICE_HOST                        | 10.1.1.1                             |
       | JDG_APP_MYSQL_SERVICE_PORT                        | 3360                                 |
       | DEFAULT_JDBC_STORE_TYPE                           | binary                               |
       | DEFAULT_JDBC_STORE_DATASOURCE                     | java:jboss/datasources/jdg_app_mysql |
       | DEFAULT_KEYED_TABLE_PREFIX                        | JDG                                  |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value id on XPath //*[local-name()='binary-keyed-jdbc-store']/*[local-name()='binary-keyed-table']/*[local-name()='id-column']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value VARCHAR(255) on XPath //*[local-name()='binary-keyed-jdbc-store']/*[local-name()='binary-keyed-table']/*[local-name()='id-column']/@type
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value datum on XPath //*[local-name()='binary-keyed-jdbc-store']/*[local-name()='binary-keyed-table']/*[local-name()='data-column']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value BLOB on XPath //*[local-name()='binary-keyed-jdbc-store']/*[local-name()='binary-keyed-table']/*[local-name()='data-column']/@type

  Scenario: binary-keyed-jdbc-store with mysql and custom JNDI name
    When container is started with env
       | variable                                          | value                            |
       | DB_SERVICE_PREFIX_MAPPING                         | jdg-app-mysql=DB                 |
       | DB_DATABASE                                       | mydb                             |
       | DB_USERNAME                                       | root                             |
       | DB_PASSWORD                                       | password                         |
       | DB_JNDI                                           | java:jboss/datasources/mydb      |
       | JDG_APP_MYSQL_SERVICE_HOST                        | 10.1.1.1                         |
       | JDG_APP_MYSQL_SERVICE_PORT                        | 5432                             |
       | DEFAULT_JDBC_STORE_TYPE                           | binary                           |
       | DEFAULT_JDBC_STORE_DATASOURCE                     | java:jboss/datasources/mydb      |
       | DEFAULT_KEYED_TABLE_PREFIX                        | JDG                              |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value id on XPath //*[local-name()='binary-keyed-jdbc-store']/*[local-name()='binary-keyed-table']/*[local-name()='id-column']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value VARCHAR(255) on XPath //*[local-name()='binary-keyed-jdbc-store']/*[local-name()='binary-keyed-table']/*[local-name()='id-column']/@type
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value datum on XPath //*[local-name()='binary-keyed-jdbc-store']/*[local-name()='binary-keyed-table']/*[local-name()='data-column']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value BLOB on XPath //*[local-name()='binary-keyed-jdbc-store']/*[local-name()='binary-keyed-table']/*[local-name()='data-column']/@type

  Scenario: binary-keyed-jdbc-store with postgresql
    When container is started with env
       | variable                                          | value                                     |
       | DB_SERVICE_PREFIX_MAPPING                         | jdg-app-postgresql=DB                     |
       | DB_DATABASE                                       | mydb                                      |
       | DB_USERNAME                                       | root                                      |
       | DB_PASSWORD                                       | password                                  |
       | JDG_APP_POSTGRESQL_SERVICE_HOST                   | 10.1.1.1                                  |
       | JDG_APP_POSTGRESQL_SERVICE_PORT                   | 5432                                      |
       | DEFAULT_JDBC_STORE_TYPE                           | binary                                    |
       | DEFAULT_JDBC_STORE_DATASOURCE                     | java:jboss/datasources/jdg_app_postgresql |
       | DEFAULT_KEYED_TABLE_PREFIX                        | JDG                                       |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value datum on XPath //*[local-name()='binary-keyed-jdbc-store']/*[local-name()='binary-keyed-table']/*[local-name()='data-column']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value BYTEA on XPath //*[local-name()='binary-keyed-jdbc-store']/*[local-name()='binary-keyed-table']/*[local-name()='data-column']/@type

  Scenario: binary-keyed-jdbc-store with postgresql and custom JNDI name
    When container is started with env
       | variable                                          | value                            |
       | DB_SERVICE_PREFIX_MAPPING                         | jdg-app-postgresql=DB            |
       | DB_DATABASE                                       | mydb                             |
       | DB_USERNAME                                       | root                             |
       | DB_PASSWORD                                       | password                         |
       | DB_JNDI                                           | java:jboss/datasources/mydb      |
       | JDG_APP_POSTGRESQL_SERVICE_HOST                   | 10.1.1.1                         |
       | JDG_APP_POSTGRESQL_SERVICE_PORT                   | 3360                             |
       | DEFAULT_JDBC_STORE_TYPE                           | binary                           |
       | DEFAULT_JDBC_STORE_DATASOURCE                     | java:jboss/datasources/mydb      |
       | DEFAULT_KEYED_TABLE_PREFIX                        | JDG                              |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value datum on XPath //*[local-name()='binary-keyed-jdbc-store']/*[local-name()='binary-keyed-table']/*[local-name()='data-column']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value BYTEA on XPath //*[local-name()='binary-keyed-jdbc-store']/*[local-name()='binary-keyed-table']/*[local-name()='data-column']/@type

  Scenario: CLOUD-406 disable passivation when no eviction strategy isn't set
    When container is started with env
       | variable                                          | value                            |
       | DEFAULT_JDBC_STORE_TYPE                           | binary                           |
       | DEFAULT_JDBC_STORE_DATASOURCE                     | java:jboss/datasources/ExampleDS |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value false on XPath //*[local-name()='binary-keyed-jdbc-store']/@passivation
