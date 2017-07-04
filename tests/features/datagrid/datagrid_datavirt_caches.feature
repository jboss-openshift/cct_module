@openshift @datagrid_6_5
Feature: Openshift JDG JDV caches
  Scenario: default jdv caches
    When container is started with env
       | variable                                          | value                            |
       | DATAVIRT_CACHE_NAMES                              | addressbook                      |
       | JDBC_STORE_DATASOURCE                             | java:jboss/datasources/ExampleDS |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value addressbook on XPath //*[local-name()='distributed-cache']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value addressbook_staging on XPath //*[local-name()='distributed-cache']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value addressbook_alias on XPath //*[local-name()='distributed-cache']/@name
    And file /opt/datagrid/standalone/configuration/clustered-openshift.xml should not contain </indexing> 

    Scenario: default replicated jdv caches
      Given XML namespaces
       | prefix | url                            |
       | ns     | urn:infinispan:server:core:6.3 |
      When container is started with env
         | variable                                          | value                            |
         | DATAVIRT_CACHE_NAMES                              | addressbook                      |
         | JDBC_STORE_DATASOURCE                             | java:jboss/datasources/ExampleDS |
         | CACHE_TYPE_DEFAULT                                | replicated                       |
      Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value addressbook on XPath //*[local-name()='replicated-cache']/@name
      Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value addressbook_staging on XPath //*[local-name()='replicated-cache']/@name
      Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value addressbook_alias on XPath //*[local-name()='replicated-cache']/@name
