@openshift @datagrid
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

  Scenario: memcached-endpoint override MEMCACHED_CACHE when CACHE_NAMES isn't specified
    When container is started with env
       | variable                                     | value                            |
       | INFINISPAN_CONNECTORS                        | memcached                        |
       | MEMCACHED_CACHE                              | default                          |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='memcached-connector']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value clustered on XPath //*[local-name()='memcached-connector']/@cache-container
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value memcached on XPath //*[local-name()='memcached-connector']/@cache
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value memcached on XPath //*[local-name()='memcached-connector']/@socket-binding

  Scenario: memcached-endpoint don't override MEMCACHED_CACHE when CACHE_NAMES is set
    When container is started with env
       | variable                                     | value                            |
       | CACHE_NAMES                                  | default                          |
       | INFINISPAN_CONNECTORS                        | memcached                        |
       | MEMCACHED_CACHE                              | default                          |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='memcached-connector']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value clustered on XPath //*[local-name()='memcached-connector']/@cache-container
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value default on XPath //*[local-name()='memcached-connector']/@cache
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value memcached on XPath //*[local-name()='memcached-connector']/@socket-binding
