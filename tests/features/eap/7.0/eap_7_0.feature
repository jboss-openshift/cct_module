@openshift @eap_7_0
Feature: Openshift EAP 7.0 basic tests

  # https://issues.jboss.org/browse/CLOUD-180
  Scenario: Check if image version and release is printed on boot
    When container is ready
    Then container log should contain Running jboss-eap-7/eap70-openshift image, version

  Scenario: Check that the labels are correctly set
    Given image is built
    Then the image should contain label com.redhat.component with value jboss-eap-7-eap70-openshift-docker
     And the image should contain label name with value jboss-eap-7/eap70-openshift
     And the image should contain label io.openshift.expose-services with value 8080:http
     And the image should contain label io.openshift.tags with value builder,javaee,eap,eap7

  Scenario: Check for add-user failures
    When container is ready
    Then container log should contain Running jboss-eap-7/eap70-openshift image
     And available container log should not contain AddUserFailedException
