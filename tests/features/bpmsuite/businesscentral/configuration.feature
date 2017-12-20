@jboss-bpmsuite-7/bpmsuite70-businesscentral-openshift @jboss-bpmsuite-7/bpmsuite70-businesscentral-monitoring-openshift
Feature: Business Central configuration tests

  # https://issues.jboss.org/browse/CLOUD-2221
  Scenario: Check KieLoginModule is configured
      When container is ready

      Then file /opt/eap/standalone/configuration/standalone-openshift.xml should contain <login-module code="org.kie.security.jaas.KieLoginModule"
