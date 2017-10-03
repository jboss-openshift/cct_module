@jboss-datagrid-6/datagrid65-openshift
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
    Then container log should contain JBAS015874: JBoss Data Grid
    Then run /opt/datagrid/bin/readinessProbe.sh in container once
    Then run /opt/datagrid/bin/livenessProbe.sh in container once

  Scenario: readinessProbe and livenessProbe runs successfully with jolokia https default
    When container is ready
    Then file /opt/datagrid/bin/standalone.conf should contain JAVA_OPTS="-Xms1303m -Xmx1303m -XX:MaxPermSize=256m -Djava.net.preferIPv4Stack=true -Dorg.jboss.resolver.warning=true -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000"

