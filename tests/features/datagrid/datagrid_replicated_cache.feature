@jboss-datagrid-6 @jboss-datagrid-7
Feature: Openshift JDG replicated-cache tests

  Scenario: replicated-cache default caches
    When container is started with env
       | variable                                          | value                            |
       | DEFAULT_CACHE_TYPE                                | replicated                       |
       | MEMCACHED_CACHE_TYPE                              | replicated                       |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 2 elements on XPath //*[local-name()='replicated-cache']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPATH //*[local-name()='replicated-cache'][@name="default"]
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPATH //*[local-name()='replicated-cache'][@name="memcached"]

  Scenario: replicated-cache single cache
    When container is started with env
       | variable                                          | value                            |
       | CACHE_NAMES                                       | addressbook                      |
       | ADDRESSBOOK_CACHE_TYPE                            | replicated                       |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='replicated-cache']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPATH //*[local-name()='replicated-cache'][@name="addressbook"]
    Then container log should contain WARN The cache for memcached-connector is not set so the connector will not be configured.

  Scenario: replicated-cache multiple caches
    When container is started with env
       | variable                                          | value                            |
       | CACHE_NAMES                                       | addressbook,addressbook_indexed  |
       | ADDRESSBOOK_CACHE_TYPE                            | replicated                       |
       | ADDRESSBOOK_INDEXED_CACHE_TYPE                    | replicated                       |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 2 elements on XPath //*[local-name()='replicated-cache']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPATH //*[local-name()='replicated-cache'][@name="addressbook"]
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPATH //*[local-name()='replicated-cache'][@name="addressbook_indexed"]
    Then container log should contain WARN The cache for memcached-connector is not set so the connector will not be configured.
