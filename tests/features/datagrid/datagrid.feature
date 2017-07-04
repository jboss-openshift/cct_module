@openshift @datagrid
Feature: Openshift DataGrid tests

  Scenario: readinessProbe and livenessProbe runs successfully with jolokia https default
    When container is ready
    Then container log should match regex .*Data Grid.*started.*
    Then run /opt/datagrid/bin/readinessProbe.sh in container once
    Then run /opt/datagrid/bin/livenessProbe.sh in container once

  Scenario: readinessProbe and livenessProbe runs successfully with jolokia http
    When container is started with env
       | variable            | value                   |
       | AB_JOLOKIA_HTTPS    |                         |
    Then container log should match regex .*Data Grid.*started.*
    Then run /opt/datagrid/bin/readinessProbe.sh in container once
    Then run /opt/datagrid/bin/livenessProbe.sh in container once

  Scenario: Check if jolokia is configured correctly
    When container is ready
    Then container log should contain -javaagent:/opt/jolokia/jolokia.jar=config=/opt/jolokia/etc/jolokia.properties

  Scenario: Check for add-user failures
    When container is ready
    Then container log should match regex .*Data Grid.*started.*
     And available container log should not contain AddUserFailedException

  Scenario: CLOUD-351: Check for BindException
    When container is ready
    Then container log should match regex .*Data Grid.*started.*
     And available container log should not contain BindException

  Scenario: Ensure that we have a clustered cache container
    When container is ready
    Then container log should match regex .*Data Grid.*started.*
     And available container log should not contain Failed to add DIST_SYNC default cache to non-clustered clustered cache container

  Scenario: Ensure that the server starts cleanly
    When container is ready
    Then container log should match regex .*Data Grid.*started.*
     And container log should not contain started (with errors)
