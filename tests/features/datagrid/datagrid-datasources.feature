@openshift @datagrid
Feature: JDG OpenShift datasources

  Scenario: check MySQL datasource
    When container is started with env
       | variable                   | value                       |
       | DB_SERVICE_PREFIX_MAPPING  | jdg-app-mysql=DB            |
       | DB_NONXA                   | true                        |
       | JDG_APP_MYSQL_SERVICE_HOST | 10.1.1.1                    |
       | JDG_APP_MYSQL_SERVICE_PORT | 3360                        |
       | DB_DATABASE                | mydb                        |
       | DB_USERNAME                | root                        |
       | DB_PASSWORD                | password                    |
       | DB_JNDI                    | java:jboss/datasources/mydb |
       | DB_MIN_POOL_SIZE           | 1                           |
       | DB_MAX_POOL_SIZE           | 10                          |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value mysql on XPath //*[local-name()='datasource']/*[local-name()='driver']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value java:jboss/datasources/mydb on XPath //*[local-name()='datasource']/@jndi-name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value jdg_app_mysql-DB on XPath //*[local-name()='datasource']/@pool-name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value jdbc:mysql://10.1.1.1:3360/mydb on XPath //*[local-name()='connection-url']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 1 on XPath //*[local-name()='datasource']/*[local-name()='pool']/*[local-name()='min-pool-size']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 10 on XPath //*[local-name()='datasource']/*[local-name()='pool']/*[local-name()='max-pool-size']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value root on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='user-name']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value password on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='password']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLValidConnectionChecker on XPath //*[local-name()='valid-connection-checker']/@class-name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLExceptionSorter on XPath //*[local-name()='exception-sorter']/@class-name

  Scenario: check PostgreSQL datasource
    When container is started with env
       | variable                        | value                       |
       | DB_SERVICE_PREFIX_MAPPING       | jdg-app-postgresql=DB       |
       | DB_NONXA                        | true                        |
       | JDG_APP_POSTGRESQL_SERVICE_HOST | 10.1.1.1                    |
       | JDG_APP_POSTGRESQL_SERVICE_PORT | 5432                        |
       | DB_DATABASE                     | mydb                        |
       | DB_USERNAME                     | root                        |
       | DB_PASSWORD                     | password                    |
       | DB_JNDI                         | java:jboss/datasources/mydb |
       | DB_MIN_POOL_SIZE                | 1                           |
       | DB_MAX_POOL_SIZE                | 10                          |

    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value postgresql on XPath //*[local-name()='datasource']/*[local-name()='driver']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value java:jboss/datasources/mydb on XPath //*[local-name()='datasource']/@jndi-name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value jdg_app_postgresql-DB on XPath //*[local-name()='datasource']/@pool-name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value jdbc:postgresql://10.1.1.1:5432/mydb on XPath //*[local-name()='connection-url']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 1 on XPath //*[local-name()='datasource']/*[local-name()='pool']/*[local-name()='min-pool-size']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 10 on XPath //*[local-name()='datasource']/*[local-name()='pool']/*[local-name()='max-pool-size']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value root on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='user-name']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value password on XPath //*[local-name()='datasource']/*[local-name()='security']/*[local-name()='password']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLValidConnectionChecker on XPath //*[local-name()='valid-connection-checker']/@class-name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLExceptionSorter on XPath //*[local-name()='exception-sorter']/@class-name
