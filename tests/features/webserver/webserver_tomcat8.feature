
Feature: Openshift Tomcat 8 tests

  @jboss-webserver-3/webserver30-tomcat8-openshift
  Scenario: Check that the labels are correctly set
    Given image is built
    Then the image should contain label com.redhat.component with value jboss-webserver-3-webserver30-tomcat8-openshift-docker
    And the image should contain label name with value jboss-webserver-3/webserver30-tomcat8-openshift
    And the image should contain label io.openshift.expose-services with value 8080:http
    And the image should contain label io.openshift.tags with value builder,java,tomcat8

  @jboss-webserver-3/webserver31-tomcat8-openshift
  Scenario: Check that the labels are correctly set
    Given image is built
    Then the image should contain label com.redhat.component with value jboss-webserver-3-webserver31-tomcat8-openshift-docker
    And the image should contain label name with value jboss-webserver-3/webserver31-tomcat8-openshift
    And the image should contain label io.openshift.expose-services with value 8080:http
    And the image should contain label io.openshift.tags with value builder,java,tomcat8

  # https://issues.jboss.org/browse/CLOUD-180
  @jboss-webserver-3/webserver30-tomcat8-openshift
  Scenario: Check if image version and release is printed on boot
    When container is ready
    Then container log should contain Running jboss-webserver-3/webserver30-tomcat8-openshift image, version

  # https://issues.jboss.org/browse/CLOUD-180
  @jboss-webserver-3/webserver31-tomcat8-openshift
  Scenario: Check if image version and release is printed on boot
    When container is ready
    Then container log should contain Running jboss-webserver-3/webserver31-tomcat8-openshift image, version

  @ci
  @jboss-webserver-3/webserver30-tomcat8-openshift @jboss-webserver-3/webserver31-tomcat8-openshift
  Scenario: Check that the webserver image contains 6 layers
    Given image is built
     Then image should contain 6 layers

