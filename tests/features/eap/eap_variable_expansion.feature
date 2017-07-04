@openshift
Feature: Check correct variable expansion used
  Scenario: Set EAP_ADMIN_USERNAME to null
    When container is started with env
      | variable           | value                            |
      | EAP_ADMIN_PASSWORD | p@ssw0rd                         |
      | EAP_ADMIN_USERNAME |                                  |
    Then container log should contain Added user 'eapadmin' to file '/opt/eap/standalone/configuration/mgmt-users.properties'

  @eap_6_4 @eap_7_0
  Scenario: Set ADMIN_USERNAME to null
    When container is started with env
      | variable           | value                            |
      | EAP_ADMIN_PASSWORD | p@ssw0rd                         |
      | ADMIN_USERNAME     |                                  |
    Then container log should contain Added user 'eapadmin' to file '/opt/eap/standalone/configuration/mgmt-users.properties'

  @eap_6_4 @eap_7_0
  Scenario: Set ADMIN_PASSWORD to null
    When container is started with env
      | variable           | value                            |
      | EAP_ADMIN_PASSWORD | p@ssw0rd                         |
      | ADMIN_PASSWORD     |                                  |
    Then container log should contain Added user 'eapadmin' to file '/opt/eap/standalone/configuration/mgmt-users.properties'

  @eap_6_4 @eap_7_0
  Scenario: Set NODE_NAME to null
    When container is started with env
      | variable           | value                            |
      | EAP_NODE_NAME      | eap-test-node-name               |
      | NODE_NAME          |                                  |
    Then container log should contain jboss.node.name = eap-test-node-name

  @eap_6_4 @eap_7_0
  Scenario: Test setting DATA_DIR to null
    Given s2i build https://github.com/jboss-openshift/openshift-examples from helloworld
       | variable    | value         |
       | APP_DATADIR | configuration |
       | DATA_DIR    |               |
    Then s2i build log should contain Copying app data from configuration to /opt/eap/standalone/data
    And run ls /opt/eap/standalone/data/standalone-openshift.xml in container and check its output for /opt/eap/standalone/data/standalone-openshift.xml

  # https://issues.jboss.org/browse/CLOUD-1168
  @eap_6_4 @eap_7_0
  Scenario: Test DATA_DIR with DATA_DIR and APP_DATADIR set, DATA_DIR is not existing
    Given s2i build https://github.com/jboss-openshift/openshift-examples from helloworld
       | variable    | value                         |
       | APP_DATADIR | modules/org/postgresql94/main |
       | DATA_DIR    | /tmp/test                     |
    Then s2i build log should contain Copying app data from modules/org/postgresql94/main to /tmp/test...
     And run ls /tmp/test/module.xml in container and check its output for /tmp/test/module.xml

  # https://issues.jboss.org/browse/CLOUD-1168
  @eap_6_4 @eap_7_0
  Scenario: Test DATA_DIR with DATA_DIR and APP_DATADIR set, DATA_DIR is existing and not owned by the user
    Given s2i build https://github.com/jboss-openshift/openshift-examples from helloworld
       | variable    | value                         |
       | APP_DATADIR | modules/org/postgresql94/main |
       | DATA_DIR    | /tmp                          |
    Then s2i build log should contain Copying app data from modules/org/postgresql94/main to /tmp...
     And run ls /tmp/module.xml in container and check its output for /tmp/module.xml

  # https://issues.jboss.org/browse/CLOUD-483
  @eap_6_4
  Scenario: Test setting ARTIFACT_DIR to null
    Given s2i build https://github.com/jboss-openshift/openshift-examples from helloworld
       | variable     | value       |
       | ARTIFACT_DIR |             |
    Then container log should contain Deployed "jboss-helloworld.war"

