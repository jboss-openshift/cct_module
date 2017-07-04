@openshift @datagrid_7_1
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
    Then container log should contain WFLYSRV0025: Data Grid 7.1.0
    Then run /opt/datagrid/bin/readinessProbe.sh in container once
    Then run /opt/datagrid/bin/livenessProbe.sh in container once
