@openshift @amq
Feature: Openshift AMQ s2i tests

  Scenario: custom configuration deployment
    Given s2i build https://github.com/jboss-openshift/openshift-examples from amq/amq-configuration
    Then file /opt/amq/conf/hello.xml should contain hello world
