@openjdk
@ubi8
@redhat-openjdk-18
Feature: Openshift S2I tests
  Scenario: Check networkaddress.cache.negative.ttl has been set correctly
    Given s2i build https://github.com/jboss-openshift/openshift-examples/ from binary-cli-security-property
    Then s2i build log should contain networkaddress.cache.negative.ttl=0
