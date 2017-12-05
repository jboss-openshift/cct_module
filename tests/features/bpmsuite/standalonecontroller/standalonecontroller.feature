@jboss-bpmsuite-7/bpmsuite70-standalonecontroller-openshift
Feature: Standalone Controller tests

  Scenario: Check if image version and release is printed on boot
    When container is ready
    Then container log should contain jboss-bpmsuite-7/bpmsuite70-standalonecontroller-openshift image, version

  Scenario: Check for product and version  environment variables
    When container is ready
    Then run sh -c 'echo $JBOSS_PRODUCT' in container and check its output for bpmsuite-standalonecontroller
    And run sh -c 'echo $JBOSS_BPMSUITE_STANDALONECONTROLLER_VERSION' in container and check its output for 7.0.0

  Scenario: Test REST API is available and valid,
    When container is started with env
      | variable                    | value            |
      | KIE_SERVER_CONTROLLER_USER  | controllerUser   |
      | KIE_SERVER_CONTROLLER_PWD   | controllerUser1! |
    Then check that page is served
      | property             | value                               |
      | port                 | 8080                                |
      | wait                 | 60                                  |
      | path                 | /rest/controller/management/servers |
      | username             | controllerUser                      |
      | password             | controllerUser1!                    |
      | expected_status_code | 200                                 |