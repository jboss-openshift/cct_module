@rhdm-7/rhdm70-decisioncentral-openshift
Feature: Decision Central configuration tests

  # https://issues.jboss.org/browse/CLOUD-2221
  Scenario: Check KieLoginModule is _not_ configured
      When container is ready

      Then file /opt/eap/standalone/configuration/standalone-openshift.xml should not contain <login-module code="org.kie.security.jaas.KieLoginModule"
