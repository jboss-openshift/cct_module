@openshift @datagrid
Feature: Openshift JDG local-cache tests

  Scenario: local-cache common variables test
    When container is started with env
       | variable                                          | value                            |
       | CACHE_NAMES                                       | MYAPPCACHE                       |
       | MYAPPCACHE_CACHE_TYPE                             | local                            |
       | MYAPPCACHE_CACHE_START                            | EAGER                            |
       | MYAPPCACHE_CACHE_BATCHING                         | true                             |
       | MYAPPCACHE_CACHE_STATISTICS                       | true                             |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value EAGER on XPATH //*[local-name()='local-cache']/@start
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPATH  //*[local-name()='local-cache']/@batching
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPATH  //*[local-name()='local-cache']/@statistics
