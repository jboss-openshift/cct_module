# Tests for jboss/container/jolokia
@openjdk
@redhat-openjdk-18
@openj9
Feature: Openshift OpenJDK Jolokia tests

  Scenario: Check Environment variable is correct
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
    Then run sh -c 'unzip -q -p /usr/share/java/jolokia-jvm-agent/jolokia-jvm.jar META-INF/maven/org.jolokia/jolokia-jvm/pom.properties | grep -F ${JOLOKIA_VERSION}' in container and check its output for version=

