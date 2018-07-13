Feature: Openshift DataGrid SPLIT tests

  @jboss-datagrid-6 @jboss-datagrid-7
  Scenario: Ensure split doesn't happen with regular configuration
    When container is ready
    Then container log should match regex .*Data Grid.*started.*
    And available container log should contain jboss.server.data.dir = /opt/datagrid/standalone/data

  @jboss-datagrid-6 @jboss-datagrid-7
  Scenario: Ensure split happens with SPLIT_DATA
    When container is started with env
       | variable            | value                   |
       | SPLIT_DATA          | TRUE                    |
    Then container log should match regex .*Data Grid.*started.*
    And available container log should contain jboss.server.data.dir = /opt/datagrid/standalone/partitioned_data/

  @jboss-datagrid-7
  Scenario: Ensure split happens with DATAGRID_SPLIT
    When container is started with env
       | variable            | value                   |
       | DATAGRID_SPLIT      | TRUE                    |
    Then container log should match regex .*Data Grid.*started.*
    And available container log should contain jboss.server.data.dir = /opt/datagrid/standalone/partitioned_data/
