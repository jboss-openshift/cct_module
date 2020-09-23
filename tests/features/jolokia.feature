# Tests for jboss/container/jolokia
Feature: Openshift OpenJDK Jolokia tests

  @openj9
  Scenario: Check Environment variable is correct
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
    Then run sh -c 'unzip -q -p /usr/share/java/jolokia-jvm-agent/jolokia-jvm.jar META-INF/maven/org.jolokia/jolokia-jvm/pom.properties | grep -F ${JOLOKIA_VERSION}' in container and check its output for version=

  @jboss-decisionserver-6
  @jboss-processserver-6
  @jboss-webserver-3/webserver30-tomcat7-openshift
  @jboss-webserver-3/webserver31-tomcat7-openshift
  @jboss-webserver-3/webserver30-tomcat8-openshift
  @jboss-webserver-3/webserver31-tomcat8-openshift
  @jboss-amq-6
  Scenario: Check jolokia port is available
    When container is ready
    Then check that port 8778 is open
    Then inspect container
       | path                    | value       |
       | /Config/ExposedPorts    | 8778/tcp    |
