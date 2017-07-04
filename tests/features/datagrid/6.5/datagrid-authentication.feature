@openshift @datagrid_6_5
Feature: JDG OpenShift simple authentication

  Scenario: check username, password and roles
    When container is started with env
       | variable               | value          |
       | USERNAME               | openshift      |
       | PASSWORD               | p@ssw0rd       |
    Then file /opt/datagrid/standalone/configuration/application-users.properties should contain openshift=7d540d09717694371fc426a7190c6021
    And file /opt/datagrid/standalone/configuration/application-roles.properties should contain openshift=REST,admin

  Scenario: Check password policy, container should fail to start
    When container is started with env
       | variable               	| value          	|
       | USERNAME              		| openshift      	|
       | PASSWORD              		| 123456         	|
       | SECDOMAIN_USERS_PROPERTIES	| users-file.properties |
       | SECDOMAIN_ROLES_PROPERTIES	| user-roles.properties |
       | SECDOMAIN_REALM		| someRealm		|
    Then container log should contain Failed to create the user openshift
    And container log should contain JBAS015269: Password must have at least 8 characters!
