@redhat-openjdk-18
Feature: Openshift OpenJDK Jolokia tests

  Scenario: Check Environment variable is correct
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
    Then run sh -c 'unzip -q -p /opt/jboss/container/jolokia/jolokia.jar META-INF/build.metadata | fgrep ${JOLOKIA_VERSION}' in container and check its output for build.version
