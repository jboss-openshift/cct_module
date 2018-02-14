@jboss-datagrid-7/datagrid71-openshift
Feature: Openshift JDG JDV caches
  Scenario: default jdv caches
    When container is started with env
       | variable                                          | value                            |
       | DATAVIRT_CACHE_NAMES                              | StockCache                       |
       | JDBC_STORE_DATASOURCE                             | java:jboss/datasources/ExampleDS |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value StockCache on XPath //*[local-name()='distributed-cache']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ST_StockCache on XPath //*[local-name()='distributed-cache']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value teiid-alias-naming-cache on XPath //*[local-name()='distributed-cache']/@name

    Scenario: default replicated jdv caches
      Given XML namespaces
       | prefix | url                            |
       | ns     | urn:infinispan:server:core:8.4 |
      When container is started with env
         | variable                                          | value                            |
         | DATAVIRT_CACHE_NAMES                              | StockCache                       |
         | JDBC_STORE_DATASOURCE                             | java:jboss/datasources/ExampleDS |
         | CACHE_TYPE_DEFAULT                                | replicated                       |
      Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value StockCache on XPath //*[local-name()='replicated-cache']/@name
      And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ST_StockCache on XPath //*[local-name()='replicated-cache']/@name
      And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value teiid-alias-naming-cache on XPath //*[local-name()='replicated-cache']/@name
