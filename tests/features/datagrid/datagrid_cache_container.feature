 @openshift @datagrid
 Feature: Openshift JDG cache

  Scenario: jdg cache container eager start
    When container is started with env
       | variable                                          | value                            |
       | CACHE_CONTAINER_START                             | EAGER                            |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value EAGER on XPath //*[local-name()='cache-container']/@start

  Scenario: jdg cache container lazy start
    When container is started with env
       | variable                                          | value                           |
       | CACHE_CONTAINER_START                             | LAZY                            |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value LAZY on XPath //*[local-name()='cache-container']/@start

  Scenario: jdg cache statistics enabled
    When container is started with env
       | variable                                          | value                            |
       | CACHE_CONTAINER_STATISTICS                        | true                             |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPath //*[local-name()='cache-container']/@statistics

  Scenario: jdg cache statistics disabled
    When container is started with env
       | variable                                          | value                            |
       | CACHE_CONTAINER_STATISTICS                        | false                            |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value false on XPath //*[local-name()='cache-container']/@statistics

  Scenario: jdg cache partition handling enabled
    When container is started with env
       | variable                                          | value                            |
       | CACHE_NAMES                                       | MYAPPCACHE                       |
       | MYAPPCACHE_CACHE_PARTITION_HANDLING_ENABLED       | true                            |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPath //*[local-name()='partition-handling']/@enabled
