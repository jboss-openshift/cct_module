@openshift @eap_6_4 @eap_7_0
Feature: Openshift EAP s2i tests
  # Always force IPv4 (CLOUD-188)
  # Append user-supplied arguments (CLOUD-412)
  # Allow the user to clear down the maven repository after running s2i (CLOUD-413)
  Scenario: Test to ensure that maven is run with -Djava.net.preferIPv4Stack=true and user-supplied arguments, even when MAVEN_ARGS is overridden, and doesn't clear the local repository after the build
    Given s2i build https://github.com/jboss-openshift/openshift-examples from helloworld
       | variable          | value                                                                                  |
       | MAVEN_ARGS        | -e -P jboss-eap-repository-insecure,-securecentral,insecurecentral -DskipTests package |
       | MAVEN_ARGS_APPEND | -Dfoo=bar                                                                              |
    Then s2i build log should contain -Djava.net.preferIPv4Stack=true
    Then s2i build log should contain -Dfoo=bar
    Then s2i build log should contain -XX:+UseParallelGC -XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=40 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:MaxMetaspaceSize=100m
    Then run sh -c 'test -d /home/jboss/.m2/repository/org && echo all good' in container and immediately check its output for all good

  # CLOUD-458
  Scenario: Test s2i build with environment only
    Given s2i build https://github.com/jboss-openshift/openshift-examples from environment-only
    Then run sh -c 'echo FOO is $FOO' in container and check its output for FOO is Iedieve8
    And s2i build log should not contain cp: cannot stat '/tmp/src/*': No such file or directory

  # CLOUD-579
  Scenario: Test that maven is executed in batch mode
    Given s2i build https://github.com/jboss-openshift/openshift-examples from helloworld
    Then s2i build log should contain --batch-mode
    And s2i build log should not contain \r

  # CLOUD-807
  Scenario: Test if the container have the JavaScript engine available
    Given s2i build https://github.com/jboss-openshift/openshift-examples from eap-tests/jsengine
    Then container log should contain Engine found: jdk.nashorn.api.scripting.NashornScriptEngine
    And container log should contain Engine class provider found.
    And container log should not contain JavaScript engine not found.

  # Always force IPv4 (CLOUD-188)
  # Append user-supplied arguments (CLOUD-412)
  # Allow the user to clear down the maven repository after running s2i (CLOUD-413)
  Scenario: Test to ensure that maven is run with -Djava.net.preferIPv4Stack=true and user-supplied arguments, and clears the local repository after the build
    Given s2i build https://github.com/jboss-openshift/openshift-examples from helloworld
       | variable          | value     |
       | MAVEN_ARGS_APPEND | -Dfoo=bar |
       | MAVEN_CLEAR_REPO  | true      |
    Then s2i build log should contain -Djava.net.preferIPv4Stack=true
    Then s2i build log should contain -Dfoo=bar
    Then run sh -c 'test -d /home/jboss/.m2/repository/org && echo oops || echo all good' in container and immediately check its output for all good

  #CLOUD-512: Copy configuration files, after the build has had a chance to generate them.
  Scenario: custom configuration deployment for existing and dynamically created files
    Given s2i build https://github.com/jboss-openshift/openshift-examples from eap-dynamic-configuration
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='root-logger']/*[local-name()='level'][@name='DEBUG']

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

  # https://issues.jboss.org/browse/CLOUD-1168
  Scenario: Make sure that custom data is being copied
    Given s2i build https://github.com/jboss-openshift/openshift-examples.git from helloworld-ws
      | variable    | value                           |
      | APP_DATADIR | src/main/java/org/jboss/as/quickstarts/wshelloworld |
    Then file /opt/eap/standalone/data/HelloWorldService.java should exist
     And file /opt/eap/standalone/data/HelloWorldServiceImpl.java should exist
     And run stat -c "%a %n" /opt/eap/standalone/data in container and immediately check its output contains 775 /opt/eap/standalone/data

  # https://issues.jboss.org/browse/CLOUD-1143
  Scenario: Make sure that custom data is being copied even if no source code is found
    Given s2i build https://github.com/jboss-openshift/openshift-examples.git from binary
      | variable    | value                           |
      | APP_DATADIR | deployments |
    Then file /opt/eap/standalone/data/node-info.war should exist
     And run stat -c "%a %n" /opt/eap/standalone/data in container and immediately check its output contains 775 /opt/eap/standalone/data
