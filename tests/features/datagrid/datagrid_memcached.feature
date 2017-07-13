@jboss-datagrid-6 @jboss-datagrid-7
Feature: Openshift JDG memcached tests

  Scenario: memcached-endpoint
    When container is started with env
       | variable                                     | value                            |
       | INFINISPAN_CONNECTORS                        | memcached                        |
       | MEMCACHED_CACHE                              | memcached                        |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='memcached-connector']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value clustered on XPath //*[local-name()='memcached-connector']/@cache-container
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value memcached on XPath //*[local-name()='memcached-connector']/@cache
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value memcached on XPath //*[local-name()='memcached-connector']/@socket-binding

  Scenario: memcached-endpoint use MEMCACHED_CACHE when CACHE_NAMES is set
    When container is started with env
       | variable                                     | value                            |
       | CACHE_NAMES                                  | default                          |
       | INFINISPAN_CONNECTORS                        | memcached                        |
       | MEMCACHED_CACHE                              | memcached                        |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='memcached-connector']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value clustered on XPath //*[local-name()='memcached-connector']/@cache-container
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value memcached on XPath //*[local-name()='memcached-connector']/@cache
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value memcached on XPath //*[local-name()='memcached-connector']/@socket-binding
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value memcached on XPath //*[local-name()='distributed-cache']/@name

  Scenario: memcached custom cache w/no CACHE_NAMES (CLOUD-1513)
    When container is started with env
       | variable                                     | value                            |
       | INFINISPAN_CONNECTORS                        | memcached                        |
       | MEMCACHED_CACHE                              | memcached_cache                  |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='memcached-connector']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value clustered on XPath //*[local-name()='memcached-connector']/@cache-container
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value memcached_cache on XPath //*[local-name()='memcached-connector']/@cache
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value memcached on XPath //*[local-name()='memcached-connector']/@socket-binding
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value memcached_cache on XPath //*[local-name()='distributed-cache']/@name

