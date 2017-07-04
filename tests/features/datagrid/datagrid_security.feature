 @openshift @datagrid
 Feature: Openshift JDG container security

  Scenario: jdg custom rolemapper
    When container is started with env
       | variable                                          | value                            |
       | CONTAINER_SECURITY_CUSTOM_ROLE_MAPPER_CLASS       | com.foo.bar.MapperClass          |
       | CONTAINER_SECURITY_ROLE_MAPPER                    | custom-role-mapper               |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value com.foo.bar.MapperClass on XPath //*[local-name()='custom-role-mapper']/@class

  Scenario: jdg custom rolemapper without role-mapper
    When container is started with env
       | variable                                          | value                            |
       | CONTAINER_SECURITY_CUSTOM_ROLE_MAPPER_CLASS       | com.foo.bar.MapperClass          |
    Then file /opt/datagrid/standalone/configuration/clustered-openshift.xml should not contain com.foo.bar.MapperClass

  Scenario: jdg rolemapper
    When container is started with env
       | variable                                          | value                            |
       | CONTAINER_SECURITY_ROLE_MAPPER                    | identity-role-mapper             |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='identity-role-mapper']

  Scenario: jdg security roles
    When container is started with env
       | variable                                          | value                                          |
       | CONTAINER_SECURITY_ROLES                          | admin=ALL                                      |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='authorization']/*[local-name()='role']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value admin on XPath //*[local-name()='role']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ALL on XPath //*[local-name()='role']/@permissions
