@openshift @datagrid
Feature: Check correct variable expansion used

  Scenario: Set DEFAULT_CACHE to null
    When container is started with env
      | variable        | value                            |
      | DEFAULT_CACHE   |                                  |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='cache-container'][@name='clustered' and @default-cache='default']

  Scenario: Set DEFAULT_CACHE to my-default-cache
    When container is started with env
      | variable        | value                            |
      | DEFAULT_CACHE   | my-default-cache                 |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='cache-container'][@name='clustered' and @default-cache='my-default-cache']

  Scenario: Set JDG_ADMIN_USERNAME to null
    When container is started with env
      | variable           | value                            |
      | JDG_ADMIN_PASSWORD | p@ssw0rd                         |
      | JDG_ADMIN_USERNAME |                                  |
    Then container log should contain Added user 'jdgadmin' to file '/opt/datagrid/standalone/configuration/mgmt-users.properties'

  Scenario: Set ADMIN_USERNAME to null
    When container is started with env
      | variable           | value                            |
      | JDG_ADMIN_PASSWORD | p@ssw0rd                         |
      | ADMIN_USERNAME     |                                  |
    Then container log should contain Added user 'jdgadmin' to file '/opt/datagrid/standalone/configuration/mgmt-users.properties'

  Scenario: Set ADMIN_PASSWORD to null
    When container is started with env
      | variable           | value                            |
      | JDG_ADMIN_PASSWORD | p@ssw0rd                         |
      | ADMIN_PASSWORD     |                                  |
    Then container log should contain Added user 'jdgadmin' to file '/opt/datagrid/standalone/configuration/mgmt-users.properties'

  Scenario: Set NODE_NAME to null
    When container is started with env
      | variable           | value                            |
      | JDG_NODE_NAME      | jdg-test-node-name               |
      | NODE_NAME          |                                  |
    Then container log should contain jboss.node.name = jdg-test-node-name

  Scenario: Set JDG_SECDOMAIN_USERS_PROPERTIES to null
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
      | variable                       | value                        |
      | JDG_SECDOMAIN_NAME             | jdg-secdomain-name           |
      | JDG_SECDOMAIN_USERS_PROPERTIES |                              |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='security-domain'][@name='jdg-secdomain-name']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option'][@name='usersProperties' and @value='${jboss.server.config.dir}/users.properties']

  Scenario: Set SECDOMAIN_USERS_PROPERTIES to null
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
      | variable                   | value                        |
      | JDG_SECDOMAIN_NAME         | jdg-secdomain-name           |
      | SECDOMAIN_USERS_PROPERTIES |                              |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='security-domain'][@name='jdg-secdomain-name']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option'][@name='usersProperties' and @value='${jboss.server.config.dir}/users.properties']

  Scenario: Set JDG_SECDOMAIN_ROLES_PROPERTIES to null
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
      | variable                       | value                        |
      | JDG_SECDOMAIN_NAME             | jdg-secdomain-name           |
      | JDG_SECDOMAIN_ROLES_PROPERTIES |                              |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='security-domain'][@name='jdg-secdomain-name']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option'][@name='rolesProperties' and @value='${jboss.server.config.dir}/roles.properties']

  Scenario: Set SECDOMAIN_ROLES_PROPERTIES to null
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
      | variable                   | value                        |
      | JDG_SECDOMAIN_NAME         | jdg-secdomain-name           |
      | SECDOMAIN_ROLES_PROPERTIES |                              |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='security-domain'][@name='jdg-secdomain-name']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option'][@name='rolesProperties' and @value='${jboss.server.config.dir}/roles.properties']

  Scenario: Set SECDOMAIN_NAME to null
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
      | variable               | value                        |
      | JDG_SECDOMAIN_NAME     | jdg-secdomain-name           |
      | SECDOMAIN_NAME         |                              |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='security-domain'][@name='jdg-secdomain-name']

  Scenario: Set SECDOMAIN_PASSWORD_STACKING to null
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
      | variable                        | value                           |
      | JDG_SECDOMAIN_NAME              | jdg-secdomain-name              |
      | JDG_SECDOMAIN_PASSWORD_STACKING | jdg-secdomain-password-stacking |
      | SECDOMAIN_PASSWORD_STACKING     |                                 |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='security-domain'][@name='jdg-secdomain-name']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option'][@name='password-stacking']
