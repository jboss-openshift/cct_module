@jboss-bpmsuite-7/bpmsuite70-smartrouter-openshift
Feature: Standalone Smart Router tests

  Scenario: Check if image version and release is printed on boot
    When container is ready
    Then container log should contain jboss-bpmsuite-7/bpmsuite70-smartrouter-openshift image, version

  Scenario: Check for product and version  environment variables
    When container is ready
    Then run sh -c 'echo $JBOSS_PRODUCT' in container and check its output for bpmsuite-smartrouter
    And run sh -c 'echo $JBOSS_BPMSUITE_SMARTROUTER_VERSION' in container and check its output for 7.0.0

  Scenario: Test REST API is available and valid
    When container is started with env
      | variable               | value   |
      | KIE_SERVER_ROUTER_HOST | 0.0.0.0 |
    Then check that page is served
      | property        | value   |
      | port            | 9000    |
      | path            | /       |
      | expected_phrase | SUCCESS |

        # TODO implement more tests