@openshift @datagrid_6_5
Feature: Openshift JDG distributed-cache tests

  Scenario: distributed-cache common variables test
    When container is started with env
       | variable                                          | value                            |
       | CACHE_NAMES                                       | MYAPPCACHE                       |
       | MYAPPCACHE_CACHE_START                            | EAGER                            |
       | MYAPPCACHE_CACHE_BATCHING                         | true                             |
       | MYAPPCACHE_CACHE_STATISTICS                       | true                             |
       | MYAPPCACHE_CACHE_MODE                             | ASYNC                            |
       | MYAPPCACHE_CACHE_QUEUE_SIZE                       | 100                              |
       | MYAPPCACHE_CACHE_QUEUE_FLUSH_INTERVAL             | 20                               |
       | MYAPPCACHE_CACHE_REMOTE_TIMEOUT                   | 25000                            |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value EAGER on XPATH //*[local-name()='distributed-cache']/@start
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPATH  //*[local-name()='distributed-cache']/@batching
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPATH  //*[local-name()='distributed-cache']/@statistics
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ASYNC on XPATH  //*[local-name()='distributed-cache']/@mode
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 100 on XPATH  //*[local-name()='distributed-cache']/@queue-size
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 20 on XPATH  //*[local-name()='distributed-cache']/@queue-flush-interval
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 25000 on XPATH  //*[local-name()='distributed-cache']/@remote-timeout
