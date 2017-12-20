@jboss-processserver-6
Feature: Openshift Process Server s2i tests

  Scenario: deploys the library example, then checks if it's deployed.
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from processserver/library using 1.3
       | variable                         | value                                                                        |
       | KIE_CONTAINER_DEPLOYMENT         | LibraryContainer=org.openshift.quickstarts:processserver-library:1.3.0.Final |
       | KIE_CONTAINER_REDIRECT_ENABLED   | false |
    Then container log should contain Container LibraryContainer

  # Always force IPv4 (CLOUD-188)
  # Support user-supplied arguments (CLOUD-412)
  # Allow the user to clear down the maven repository after running s2i (CLOUD-413)
  Scenario: Test to ensure that maven is run with -Djava.net.preferIPv4Stack=true and user-supplied arguments, even when MAVEN_ARGS is overridden, and maven repo is ALWAYS left alone
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from processserver/library using 1.3
       | variable          | value                                                                                  |
       | MAVEN_ARGS        | -e -P jboss-eap-repository-insecure,-securecentral,insecurecentral -DskipTests package |
       | MAVEN_ARGS_APPEND | -Dfoo=bar                                                                              |
       | MAVEN_CLEAR_REPO  | true                                                                                   |
     Then s2i build log should contain -Djava.net.preferIPv4Stack=true
     Then s2i build log should contain -Dfoo=bar
     Then s2i build log should contain -XX:+UseParallelGC -XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=40 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:MaxMetaspaceSize=100m
     Then run sh -c 'test -d /home/jboss/.m2/repository/org && echo all good' in container and check its output for all good

  # CLOUD-579
  Scenario: Test that maven is executed in batch mode
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from processserver/library using 1.3 
    Then s2i build log should contain --batch-mode
    And s2i build log should not contain \r

  # CLOUD-1145 - base test
  Scenario: Check custom war file was successfully deployed via CUSTOM_INSTALL_DIRECTORIES
    Given s2i build https://github.com/jboss-openshift/openshift-examples.git from custom-install-directories
      | variable   | value                    |
      | CUSTOM_INSTALL_DIRECTORIES | custom   |
    Then file /opt/eap/standalone/deployments/node-info.war should exist

  # CLOUD-1145 - CSV test
  Scenario: Check all modules are successfully deployed using comma-separated CUSTOM_INSTALL_DIRECTORIES value
    Given s2i build https://github.com/jboss-openshift/openshift-examples.git from custom-install-directories
      | variable   | value                    |
      | CUSTOM_INSTALL_DIRECTORIES | foo,bar  |
    Then file /opt/eap/standalone/deployments/foo.jar should exist
    Then file /opt/eap/standalone/deployments/bar.jar should exist
