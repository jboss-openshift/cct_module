@jboss-decisionserver-6/decisionserver64-openshift
Feature: OpenShift Decision Server 6.4 basic tests
  
  Scenario: Check for add-user failures
    When container is ready
    Then container log should contain Running jboss-decisionserver-6/decisionserver64-openshift image
     And available container log should not contain AddUserFailedException

  Scenario: Check for product and version  environment variables
    When container is ready
    Then run sh -c 'echo $JBOSS_PRODUCT' in container and check its output for decisionserver
     And run sh -c 'echo $JBOSS_DECISIONSERVER_VERSION' in container and check its output for 6.4

  Scenario: Checks if the kie-server webapp is deployed.
    When container is ready
    Then container log should contain JBAS015859: Deployed "kie-server.war"

  Scenario: Test REST API is secure
    When container is ready
    Then check that page is served
         | property | value |
         | port     | 8080  |
         | path     | /kie-server/services/rest/server |
         | expected_status_code | 401 |

   Scenario: Test REST API is available and valid
     When container is ready
     Then check that page is served
         | property | value |
         | port     | 8080  |
         | path     | /kie-server/services/rest/server |
         | username | kieserver |
         | password | kieserver1! |
         | expected_phrase | SUCCESS |

   Scenario: Test CLOUD-458
     Given s2i build https://github.com/jboss-openshift/application-templates using ose-v1.0.0 
     Then s2i build log should not contain cp: cannot stat '/tmp/src/*': No such file or directory
     Then s2i build log should not contain ls: cannot access /opt/eap/standalone/deployments/*.jar: No such file or directory
     Then s2i build log should not contain chmod: cannot access '/home/jboss/.m2/repository': No such file or directory

  Scenario: check ownership when started as alternative UID
    When container is started as uid 26458
    Then container log should contain Running
     And run id -u in container and check its output contains 26458
     And all files under /opt/eap are writeable by current user
     And all files under /deployments are writeable by current user

  Scenario: Checks that CLOUD-1476 patch upgrade was successful
    When container is ready
    Then file /opt/eap/standalone/deployments/kie-server.war/WEB-INF/web.xml should contain org.openshift.kieserver
    And file /opt/eap/standalone/deployments/kie-server.war/WEB-INF/security-filter-rules.properties should exist
    And file /opt/eap/standalone/deployments/kie-server.war/WEB-INF/lib/kie-api-6.5.0.Final-redhat-2.jar should not exist
    And file /opt/eap/standalone/deployments/kie-server.war/WEB-INF/lib/kie-api-6.5.0.Final-redhat-7.jar should exist
    And file /opt/eap/standalone/deployments/kie-server.war/WEB-INF/lib/openshift-kieserver-common-1.2.0.Final-redhat-1.jar should exist
