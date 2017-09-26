@jboss-eap-6/eap64-openshift
Feature: Openshift EAP basic tests

  @ci
  Scenario: Check that the jboss-eap-6/eap64-openshift image contains 6 layers
    Given image is built
     Then image should contain 6 layers

  # https://issues.jboss.org/browse/CLOUD-180
  Scenario: Check if image version and release is printed on boot
    When container is ready
    Then container log should contain Running jboss-eap-6/eap64-openshift image, version

  Scenario: Check that the labels are correctly set
    Given image is built
     Then the image should contain label com.redhat.component with value jboss-eap-6-eap64-openshift-docker
      And the image should contain label name with value jboss-eap-6/eap64-openshift
      And the image should contain label io.openshift.expose-services with value 8080:http
      And the image should contain label io.openshift.tags with value builder,javaee,eap,eap6

  Scenario: Check for add-user failures
    When container is ready
    Then container log should contain Running jboss-eap-6/eap64-openshift image
     And available container log should not contain AddUserFailedException

  Scenario: CLOUD-437 - ignore MaxPermSize with Java 8
    When container is ready
    Then container log should contain JBAS015874
     And available container log should not contain ignoring option MaxPermSize=256m

  Scenario: CLOUD-1784, make the Access Log Valve configurable (modified for CLOUD-2049)
    When container is started with env
      | variable          | value                 |
      | ENABLE_ACCESS_LOG | true                  |
    Then file /opt/eap/standalone/configuration/standalone-openshift.xml should contain <deployment-overlay name="valveoverlay">
     And file /opt/eap/standalone/configuration/standalone-openshift.xml should contain <content path="/WEB-INF/jboss-web.xml" content="38b8ef5d9c683c14b786ba47845934625a1c15d8"/>
     And file /opt/eap/standalone/data/content/38/b8ef5d9c683c14b786ba47845934625a1c15d8/content should contain <class-name>org.apache.catalina.valves.RemoteIpValve</class-name>
     And file /opt/eap/standalone/data/content/38/b8ef5d9c683c14b786ba47845934625a1c15d8/content should contain <valve><class-name>org.jboss.openshift.valves.StdoutAccessLogValve</class-name><module>org.jboss.openshift</module><param><param-name>pattern</param-name><param-value>%h %l %u %t %{X-Forwarded-Host}i &quot;%r&quot; %s %b</param-value></param></valve>
