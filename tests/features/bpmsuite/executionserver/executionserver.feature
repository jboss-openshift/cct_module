@jboss-bpmsuite-7/bpmsuite70-executionserver-openshift
Feature: BPM Suite Common tests

    # https://issues.jboss.org/browse/CLOUD-180
  Scenario: Check if image version and release is printed on boot
    When container is ready
    Then container log should contain jboss-bpmsuite-7/bpmsuite70-executionserver-openshift image, version

  Scenario: Check for product and version  environment variables
    When container is ready
    Then run sh -c 'echo $JBOSS_PRODUCT' in container and check its output for bpmsuite-executionserver
    And run sh -c 'echo $JBOSS_BPMSUITE_EXECUTIONSERVER_VERSION' in container and check its output for 7.0.0

  Scenario: Test REST API is available and valid
    When container is started with env
      | variable         | value       |
      | KIE_SERVER_USER  | kieserver   |
      | KIE_SERVER_PWD   | kieserver1! |
    Then check that page is served
      | property        | value                 |
      | port            | 8080                  |
      | path            | /services/rest/server |
      | wait            | 60                    |
      | username        | kieserver             |
      | password        | kieserver1!           |
      | expected_phrase | SUCCESS               |

  # CLOUD-1145 - base test
  Scenario: Check custom war file was successfully deployed via CUSTOM_INSTALL_DIRECTORIES
    Given s2i build https://github.com/jboss-openshift/openshift-examples.git from custom-install-directories
      | variable   | value                    |
      | CUSTOM_INSTALL_DIRECTORIES | custom   |
    Then file /opt/eap/standalone/deployments/node-info.war should exist

  Scenario: deploys the library example, then checks if it's deployed.
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from processserver/library using master
      | variable                         | value                                                                        |
      | KIE_CONTAINER_DEPLOYMENT         | LibraryContainer=org.openshift.quickstarts:processserver-library:1.4.0.Final |
      | KIE_CONTAINER_REDIRECT_ENABLED   | false                                                                        |
    Then container log should contain Container LibraryContainer

    # TODO implement more tests