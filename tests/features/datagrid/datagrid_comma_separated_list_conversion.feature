@openshift @datagrid
Feature: Openshift JDG Comma-separated list conversion

  Scenario: cache_security_authorization_roles
    When container is started with env
      | variable                                     | value                            |
      | DEFAULT_CACHE_SECURITY_AUTHORIZATION_ENABLED | true                             |
      | DEFAULT_CACHE_SECURITY_AUTHORIZATION_ROLES   | foo,bar                          |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPath //*[local-name()='authorization']/@enabled
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value foo bar on XPath //*[local-name()='authorization']/@roles
