@jboss-processserver-6/processserver63-openshift
Feature: OpenShift Process Server 6.3 basic tests
  
  Scenario: Check for add-user failures
    When container is ready
    Then container log should contain Running jboss-processserver-6/processserver63-openshift image
     And available container log should not contain AddUserFailedException

  Scenario: Check for product and version  environment variables
    When container is ready
    Then run sh -c 'echo $JBOSS_PRODUCT' in container and check its output for processserver
     And run sh -c 'echo $JBOSS_PROCESSSERVER_VERSION' in container and check its output for 6.3

  Scenario: Checks if the kie-server webapp is deployed.
    When container is ready
    Then container log should contain JBAS015859: Deployed "kie-server.war"

  Scenario: Test REST API is secure
    When container is ready
    Then check that page is served
         | property | value |
         | port     | 8080  |
         | path     | /kie-server/services/rest/server |
         | expected_status_code | 401 |

   Scenario: Test REST API is available and valid
    When container is ready
    Then check that page is served
         | property | value |
         | port     | 8080  |
         | path     | /kie-server/services/rest/server |
         | username | kieserver |
         | password | kieserver1! |
         | expected_phrase | SUCCESS |

   Scenario: Checks SQL Importer behaviour if QUARTZ_JNDI variable does not exists
    When container is ready
    Then container log should contain QUARTZ_JNDI env not found, skipping SqlImporter

   Scenario: Checks if the Quartz was successfully configured with MySQL
    Given XML namespaces
       | prefix | url                              |
       | ds     | urn:jboss:domain:datasources:1.2 |
    When container is started with env
       | variable                   | value |
       | DB_SERVICE_PREFIX_MAPPING  | kie-app-mysql=DB,kie-app-mysql=QUARTZ |
       | DB_DATABASE                | mydb                        |
       | DB_USERNAME                | root                        |
       | DB_PASSWORD                | password                    |
       | DB_JNDI                    | java:jboss/datasources/ExampleDS |
       | QUARTZ_JNDI                | java:jboss/datasources/ExampleDSNotManaged |
       | QUARTZ_DATABASE            | mydb                        |
       | QUARTZ_USERNAME            | root                        |
       | QUARTZ_PASSWORD            | password                    |
       | QUARTZ_JTA                 | false |
       | QUARTZ_NONXA               | true  |
       | KIE_APP_MYSQL_SERVICE_HOST | 10.1.1.1 |
       | KIE_APP_MYSQL_SERVICE_PORT | 3306 |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mysql on XPath //ds:datasource/ds:driver
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/ExampleDS on XPath //ds:xa-datasource/@jndi-name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/ExampleDSNotManaged on XPath //ds:datasource/@jndi-name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //ds:datasource/@jta

   Scenario: Checks if the Quartz was successfully configured with PostgreSQL
    Given XML namespaces
       | prefix | url                              |
       | ds     | urn:jboss:domain:datasources:1.2 |
    When container is started with env
       | variable                   | value |
       | DB_SERVICE_PREFIX_MAPPING  | kie-app-postgresql=DB,kie-app-postgresql=QUARTZ |
       | DB_DATABASE                | mydb                        |
       | DB_USERNAME                | root                        |
       | DB_PASSWORD                | password                    |
       | DB_JNDI                    | java:jboss/datasources/ExampleDS |
       | QUARTZ_JNDI                | java:jboss/datasources/ExampleDSNotManaged |
       | QUARTZ_DATABASE            | mydb                        |
       | QUARTZ_USERNAME            | root                        |
       | QUARTZ_PASSWORD            | password                    |
       | QUARTZ_JTA                 | false |
       | QUARTZ_NONXA               | true  |
       | KIE_APP_POSTGRESQL_SERVICE_HOST | 10.1.1.1 |
       | KIE_APP_POSTGRESQL_SERVICE_PORT | 5432 |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value postgresql on XPath //ds:datasource/ds:driver
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/ExampleDS on XPath //ds:xa-datasource/@jndi-name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/ExampleDSNotManaged on XPath //ds:datasource/@jndi-name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //ds:datasource/@jta

  Scenario: check ownership when started as alternative UID
    When container is started as uid 26458
    Then container log should contain Running
     And run id -u in container and check its output contains 26458
     And all files under /opt/eap are writeable by current user
     And all files under /deployments are writeable by current user

  Scenario: Checks that CLOUD-950/CLOUD-951 upgrade to 6.3.4 was successful
    When container is ready
    Then file /opt/eap/standalone/deployments/kie-server.war/WEB-INF/web.xml should contain org.openshift.kieserver
    And file /opt/eap/standalone/deployments/kie-server.war/WEB-INF/security-filter-rules.properties should exist
    And file /opt/eap/standalone/deployments/kie-server.war/WEB-INF/lib/kie-api-6.4.0.Final-redhat-3.jar should not exist
    And file /opt/eap/standalone/deployments/kie-server.war/WEB-INF/lib/kie-api-6.4.0.Final-redhat-13.jar should exist
    And file /opt/eap/standalone/deployments/kie-server.war/WEB-INF/lib/openshift-kieserver-common-1.0.8.Final-redhat-1.jar should not exist
    And file /opt/eap/standalone/deployments/kie-server.war/WEB-INF/lib/openshift-kieserver-common-1.1.0.Final-redhat-1.jar should exist
