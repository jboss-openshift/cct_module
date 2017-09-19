@jboss-datagrid-6 @jboss-datagrid-7
Feature: Openshift JDG distributed-cache tests

  Scenario: distributed-cache default caches
    When container is started with env
       | variable                                          | value                            |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 2 elements on XPath //*[local-name()='distributed-cache']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='distributed-cache'][@name="default"]
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='distributed-cache'][@name="memcached"]

  Scenario: distributed-cache single cache
    When container is started with env
       | variable                                          | value                            |
       | CACHE_NAMES                                       | addressbook                      |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='distributed-cache'][@name="addressbook"]

  Scenario: distributed-cache multiple caches
    When container is started with env
       | variable                                          | value                            |
       | CACHE_NAMES                                       | addressbook,addressbook_indexed  |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='distributed-cache'][@name="addressbook"]
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='distributed-cache'][@name="addressbook_indexed"]

  Scenario: distributed-cache with locking
    When container is started with env
       | variable                                          | value                            |
       | CACHE_NAMES                                       | DEFAULT                          |
       | DEFAULT_LOCKING_ACQUIRE_TIMEOUT                   | 20000                            |
       | DEFAULT_LOCKING_CONCURRENCY_LEVEL                 | 500                              |
       | DEFAULT_LOCKING_STRIPING                          | false                            |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPATH //*[local-name()='locking']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 20000 on XPATH //*[local-name()='locking']/@acquire-timeout
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 500 on XPATH //*[local-name()='locking']/@concurrency-level
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value false on XPATH //*[local-name()='locking']/@striping

  Scenario: CLOUD-1184 distributed-cache with expiration
    When container is started with env
       | variable                                          | value                            |
       | CACHE_NAMES                                       | DEFAULT                          |
       | DEFAULT_CACHE_EXPIRATION_LIFESPAN                 | 10000                            |
       | DEFAULT_CACHE_EXPIRATION_MAX_IDLE                 | 5000                             |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPATH //*[local-name()='expiration']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 10000 on XPATH //*[local-name()='expiration']/@lifespan
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 5000 on XPATH //*[local-name()='expiration']/@max-idle

    Scenario: CLOUD-1178 distributed-cache with expiration interval
    When container is started with env
       | variable                                          | value                            |
       | CACHE_NAMES                                       | DEFAULT                          |
       | DEFAULT_CACHE_EXPIRATION_LIFESPAN                 | 10000                            |
       | DEFAULT_CACHE_EXPIRATION_MAX_IDLE                 | 5000                             |
       | DEFAULT_CACHE_EXPIRATION_INTERVAL                 | 100                              |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPATH //*[local-name()='expiration']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 10000 on XPATH //*[local-name()='expiration']/@lifespan
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 5000 on XPATH //*[local-name()='expiration']/@max-idle
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 100 on XPATH //*[local-name()='expiration']/@interval

  Scenario: distributed-cache with interval only (CLOUD-1665)
    When container is started with env
       | variable                                          | value                            |
       | CACHE_NAMES                                       | DEFAULT                          |
       | DEFAULT_CACHE_EXPIRATION_INTERVAL                 | 100                              |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPATH //*[local-name()='expiration']
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 100 on XPATH //*[local-name()='expiration']/@interval

  Scenario: distributed-cache with transport lock timeout
    When container is started with env
       | variable                                          | value                            |
       | TRANSPORT_LOCK_TIMEOUT                            | 100                              |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='cache-container']/*[local-name()='transport']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 100 on XPath //*[local-name()='transport']/@lock-timeout

  Scenario: distributed-cache test owners, cache segments and L1 lifespan
    When container is started with env
       | variable                                          | value                            |
       | CACHE_NAMES                                       | MYCACHE                          |
       | MYCACHE_CACHE_TYPE                                | distributed                      |
       | MYCACHE_CACHE_OWNERS                              | 5                                |
       | MYCACHE_CACHE_SEGMENTS                            | 30                               |
       | MYCACHE_CACHE_L1_LIFESPAN                         | 100                              |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 5 on XPath //*[local-name()='distributed-cache']/@owners
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 30 on XPath //*[local-name()='distributed-cache']/@segments
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 100 on XPath //*[local-name()='distributed-cache']/@l1-lifespan

   Scenario: distributed-cache test owners, cache segments and L1 lifespan w/o explicit type
    When container is started with env
       | variable                                          | value                            |
       | CACHE_NAMES                                       | MYCACHE                          |
       | MYCACHE_CACHE_OWNERS                              | 5                                |
       | MYCACHE_CACHE_SEGMENTS                            | 30                               |
       | MYCACHE_CACHE_L1_LIFESPAN                         | 100                              |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 5 on XPath //*[local-name()='distributed-cache']/@owners
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 30 on XPath //*[local-name()='distributed-cache']/@segments
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 100 on XPath //*[local-name()='distributed-cache']/@l1-lifespan

  Scenario: test cache index variables
    When container is started with env
       | variable                                          | value                            |
       | CACHE_NAMES                                       | ANOTHERCACHE                     |
       | ANOTHERCACHE_CACHE_INDEX                          | LOCAL                            |
       | ANOTHERCACHE_INDEXING_PROPERTIES                  | default.directory_provider=ram   |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value LOCAL on XPATH //*[local-name()='indexing']/@index
    And file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain "default.directory_provider">ram<

  Scenario: CLOUD-2043 distributed-cache with transaction
    When container is started with env
       | variable                                          | value                            |
       | CACHE_NAMES                                       | DEFAULT                          |
       | DEFAULT_LOCKING_ISOLATION                         | READ_COMMITTED                   |
       | DEFAULT_TRANSACTION_MODE                          | NONE                             |
       | DEFAULT_STATE_TRANSFER_TIMEOUT                    | 120000                           |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPATH //*[local-name()='locking']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value READ_COMMITTED on XPATH //*[local-name()='locking']/@isolation
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value NONE on XPATH //*[local-name()='transaction']/@mode
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 120000 on XPATH //*[local-name()='state-transfer']/@timeout

