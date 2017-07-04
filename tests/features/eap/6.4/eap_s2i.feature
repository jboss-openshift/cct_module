@openshift @eap_6_4
Feature: Openshift EAP s2i tests

  # test incremental builds; handles custom module test; custom config test
  Scenario: Check custom modules and configs are copied in; check incremental builds cache .m2
    Given s2i build https://github.com/jboss-openshift/openshift-examples from helloworld
       | variable   | value                                                                                  |
       | MAVEN_ARGS | -e -P jboss-eap-repository-insecure,-securecentral,insecurecentral -DskipTests package |
    Then file /opt/eap/standalone/configuration/standalone-openshift.xml should contain <driver name="postgresql94" module="org.postgresql94">
     And container log should contain JBAS010404: Deploying non-JDBC-compliant driver class org.postgresql.Driver (version 9.4)
     And s2i build log should contain Downloading:
     And check that page is served
        | property | value                        |
        | path     | /jboss-helloworld/HelloWorld |
        | port     | 8080                         |
    Given s2i build https://github.com/jboss-openshift/openshift-examples from helloworld with env and incremental
    Then s2i build log should contain Expanding artifacts from incremental build...
     And s2i build log should not contain Downloading:

  # handles binary deployment
  Scenario: deploys the spring-eap6-quickstart example, then checks if it's deployed.
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-eap6-quickstart
    Then container log should contain Initializing Spring FrameworkServlet 'jboss-as-kitchensink'
    Then container log should contain JBAS015859: Deployed "ROOT.war"

  Scenario: deploys the binary example, then checks if both war files are deployed.
    Given s2i build https://github.com/jboss-openshift/openshift-examples from binary
    Then container log should contain JBAS015874
    And available container log should contain JBAS015859: Deployed "node-info.war"
    And file /opt/eap/standalone/deployments/node-info.war should exist
    And available container log should contain JBAS015859: Deployed "top-level.war"
    And file /opt/eap/standalone/deployments/top-level.war should exist

   # test multiple artifacts via ARTIFACT_DIR
   Scenario: Check custom modules and configs are copied in; check incremental builds cache .m2
   Given s2i build https://github.com/jboss-developer/jboss-eap-quickstarts from inter-app using 6.4.x
      | variable   | value                                                                                  |
      | ARTIFACT_DIR | appA/target,appB/target,shared/target |
   Then container log should contain JBAS015859: Deployed "jboss-inter-app-shared.jar"
   Then container log should contain JBAS015859: Deployed "jboss-inter-app-appB.war"
   Then container log should contain JBAS015859: Deployed "jboss-inter-app-appA.war"
