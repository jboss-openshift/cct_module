@jboss-datagrid-7/datagrid71-openshift
Feature: Openshift DataGrid tests

  Scenario: readinessProbe and livenessProbe runs successfully with user security
    When container is started with env
       | variable                                      | value                 |
       | USERNAME                                      | jdg                   |
       | PASSWORD                                      | JBoss.123             |
       | CACHE_ROLES                                   | admin                 |
       | CONTAINER_SECURITY_ROLE_MAPPER                | identity-role-mapper  |
       | CONTAINER_SECURITY_ROLES                      | admin=ALL             |
       | DEFAULT_CACHE_SECURITY_AUTHORIZATION_ENABLED  | true                  |
       | DEFAULT_CACHE_SECURITY_AUTHORIZATION_ROLES    | admin                 |
    Then container log should contain WFLYSRV0025: Data Grid 7.1.1
    Then run /opt/datagrid/bin/readinessProbe.sh in container once
    Then run /opt/datagrid/bin/livenessProbe.sh in container once

  Scenario: Check for default debug port
    When container is started with env
       | variable            | value                   |
       | DEBUG               | true                    |
    Then container log should contain -agentlib:jdwp=transport=dt_socket,address=8787,server=y,suspend=n

  Scenario: Check for custom debug port
    When container is started with env
       | variable            | value                   |
       | DEBUG               | true                    |
       | DEBUG_PORT          | 8788                    |
    Then container log should contain -agentlib:jdwp=transport=dt_socket,address=8788,server=y,suspend=n
