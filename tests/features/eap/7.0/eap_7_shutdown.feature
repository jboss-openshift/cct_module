@openshift @eap_7_0
Feature: Openshift EAP 7.0 shutdown tests

  Scenario: Check if image shuts down with TERM signal
    When container is ready
    Then container log should contain WFLYSRV0025
    And run kill -TERM 1 in container once
    And container log should contain received TERM signal
    And container log should contain WFLYSRV0050

  Scenario: Check if image does not shutdown with TERM signal when CLI_GRACEFUL_SHUTDOWN is set
    When container is started with env
       | variable                  | value           |
       | CLI_GRACEFUL_SHUTDOWN     | true            |
    Then container log should contain WFLYSRV0025
    And run kill -TERM 1 in container once
    And container log should not contain received TERM signal
    And container log should not contain WFLYSRV0050

  Scenario: Check if image shuts down with cli when CLI_GRACEFUL_SHUTDOWN is set
    When container is started with env
       | variable                  | value           |
       | CLI_GRACEFUL_SHUTDOWN     | true            |
    Then container log should contain WFLYSRV0025
    And run /opt/eap/bin/jboss-cli.sh -c ":shutdown(timeout=60)" in container once
    And container log should not contain received TERM signal
    And container log should contain WFLYSRV0050
