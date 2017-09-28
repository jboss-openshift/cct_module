@jboss-datagrid-7/datagrid71-openshift
Feature: OpenShift JDG Compatibility Mode tests

  Scenario: Enabling Compatibility Mode test
    When container is started with env
       | variable                                | value      |
       | CACHE_NAMES                             | MYAPPCACHE |
       | MYAPPCACHE_CACHE_PROTOCOL_COMPATIBILITY | true       |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value MYAPPCACHE on XPath //*[local-name()='distributed-cache']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPath //*[local-name()='distributed-cache'][@name='MYAPPCACHE']/*[local-name()='compatibility']/@enabled
    And container log should contain DGISPN0001: Started MYAPPCACHE cache from clustered container

  Scenario: Enabling Compatibility Mode with Marshaller test
    When container is started with env
       | variable                                  | value                                                       |
       | CACHE_NAMES                               | MYAPPCACHE                                                  |
       | MYAPPCACHE_CACHE_PROTOCOL_COMPATIBILITY   | true                                                        |
       | MYAPPCACHE_CACHE_COMPATIBILITY_MARSHALLER | org.infinispan.commons.marshall.JavaSerializationMarshaller |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value MYAPPCACHE on XPath //*[local-name()='distributed-cache']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPath //*[local-name()='distributed-cache'][@name='MYAPPCACHE']/*[local-name()='compatibility']/@enabled
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value org.infinispan.commons.marshall.JavaSerializationMarshaller on XPath //*[local-name()='distributed-cache'][@name='MYAPPCACHE']/*[local-name()='compatibility']/@marshaller
    And container log should contain DGISPN0001: Started MYAPPCACHE cache from clustered container

  Scenario: Enabling Compatibility Mode in Selected Cache test
    When container is started with env
       | variable                                  | value                                                       |
       | CACHE_NAMES                               | MYAPPCACHE1,MYAPPCACHE2                                     |
       | MYAPPCACHE2_CACHE_PROTOCOL_COMPATIBILITY  | true                                                        |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value MYAPPCACHE1 on XPath //*[local-name()='distributed-cache']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value MYAPPCACHE2 on XPath //*[local-name()='distributed-cache']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 0 elements on XPath //*[local-name()='distributed-cache'][@name='MYAPPCACHE1']/*[local-name()='compatibility']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPath //*[local-name()='distributed-cache'][@name='MYAPPCACHE2']/*[local-name()='compatibility']/@enabled
    And container log should contain DGISPN0001: Started MYAPPCACHE1 cache from clustered container
    And container log should contain DGISPN0001: Started MYAPPCACHE2 cache from clustered container

  Scenario: Enabling Compatibility Mode in Selected Cache with Marshaller test
    When container is started with env
       | variable                                   | value                                                        |
       | CACHE_NAMES                                | MYAPPCACHE1,MYAPPCACHE2                                      |
       | MYAPPCACHE1_CACHE_PROTOCOL_COMPATIBILITY   | true                                                         |
       | MYAPPCACHE1_CACHE_COMPATIBILITY_MARSHALLER | org.infinispan.commons.marshall.jboss.GenericJBossMarshaller |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value MYAPPCACHE1 on XPath //*[local-name()='distributed-cache']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value MYAPPCACHE2 on XPath //*[local-name()='distributed-cache']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPath //*[local-name()='distributed-cache'][@name='MYAPPCACHE1']/*[local-name()='compatibility']/@enabled
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 0 elements on XPath //*[local-name()='distributed-cache'][@name='MYAPPCACHE2']/*[local-name()='compatibility']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value org.infinispan.commons.marshall.jboss.GenericJBossMarshaller on XPath //*[local-name()='distributed-cache'][@name='MYAPPCACHE1']/*[local-name()='compatibility']/@marshaller
    And container log should contain DGISPN0001: Started MYAPPCACHE1 cache from clustered container
    And container log should contain DGISPN0001: Started MYAPPCACHE2 cache from clustered container

  Scenario: Enabling Compatibility Mode in Selected Caches with Marshaller in Selected Cache test
    When container is started with env
       | variable                                   | value                                                        |
       | CACHE_NAMES                                | MYAPPCACHE1,MYAPPCACHE2,MYAPPCACHE3                          |
       | MYAPPCACHE1_CACHE_PROTOCOL_COMPATIBILITY   | true                                                         |
       | MYAPPCACHE3_CACHE_PROTOCOL_COMPATIBILITY   | true                                                         |
       | MYAPPCACHE3_CACHE_COMPATIBILITY_MARSHALLER | org.infinispan.commons.marshall.jboss.GenericJBossMarshaller |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value MYAPPCACHE1 on XPath //*[local-name()='distributed-cache']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value MYAPPCACHE2 on XPath //*[local-name()='distributed-cache']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value MYAPPCACHE3 on XPath //*[local-name()='distributed-cache']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPath //*[local-name()='distributed-cache'][@name='MYAPPCACHE1']/*[local-name()='compatibility']/@enabled
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 0 elements on XPath //*[local-name()='distributed-cache'][@name='MYAPPCACHE2']/*[local-name()='compatibility']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPath //*[local-name()='distributed-cache'][@name='MYAPPCACHE3']/*[local-name()='compatibility']/@enabled
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value org.infinispan.commons.marshall.jboss.GenericJBossMarshaller on XPath //*[local-name()='distributed-cache'][@name='MYAPPCACHE3']/*[local-name()='compatibility']/@marshaller
    And container log should contain DGISPN0001: Started MYAPPCACHE1 cache from clustered container
    And container log should contain DGISPN0001: Started MYAPPCACHE2 cache from clustered container
    And container log should contain DGISPN0001: Started MYAPPCACHE3 cache from clustered container

