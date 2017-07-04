@openshift @eap_6_4
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
