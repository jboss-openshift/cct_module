@jboss-datagrid-7
Feature: Openshift JDG7.1 memcached tests

  Scenario: Do not create memcached cache if it'snamed default (CLOUD-2064)
    When container is started with env
       | variable                                     | value                            |
       | CACHE_NAMES                                  | testcache                        |
       | INFINISPAN_CONNECTORS                        | memcached                        |
       | MEMCACHED_CACHE                              | default                          |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='memcached-connector']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value clustered on XPath //*[local-name()='memcached-connector']/@cache-container
     And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value testcache on XPath //*[local-name()='distributed-cache']/@name
     And file /opt/datagrid/standalone/configuration/clustered-openshift.xml should not contain <distributed-cache name="default"

