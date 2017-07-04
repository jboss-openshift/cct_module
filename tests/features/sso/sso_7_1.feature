@openshift @sso_7_1
Feature: OpenShift SSO 7.1 tests

  Scenario: check for keycloak cache 7.1
    When container is ready
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='cache-container'][@name='keycloak']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='local-cache'][@name='realms']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='local-cache'][@name='users']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='distributed-cache'][@name='sessions']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='distributed-cache'][@name='offlineSessions']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='distributed-cache'][@name='loginFailures']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='distributed-cache'][@name='authorization']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='replicated-cache'][@name='work']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='local-cache'][@name='keys']

  # CLOUD-1599 - Verify former keycloak-server.json elements are now present in standalone-openshift.xml
  Scenario: Check standalone-openshift.xml contains SSO server configuration elements
    When container is ready
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='master-realm-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value master on XPath //*[local-name()='master-realm-name']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value eventsStore on XPath //*[local-name()='spi']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jpa on XPath //*[local-name()='spi'][@name='eventsStore']/*[local-name()='default-provider']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jpa on XPath //*[local-name()='spi'][@name='eventsStore']/*[local-name()='provider']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value true on XPath //*[local-name()='spi'][@name='eventsStore']/*[local-name()='provider']/@enabled
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value realm on XPath //*[local-name()='spi']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jpa on XPath //*[local-name()='spi'][@name='realm']/*[local-name()='default-provider']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value user on XPath //*[local-name()='spi']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jpa on XPath //*[local-name()='spi'][@name='user']/*[local-name()='default-provider']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value userCache on XPath //*[local-name()='spi']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value default on XPath //*[local-name()='spi'][@name='userCache']/*[local-name()='provider']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value true on XPath //*[local-name()='spi'][@name='userCache']/*[local-name()='provider']/@enabled
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value userSessionPersister on XPath //*[local-name()='spi']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jpa on XPath //*[local-name()='spi'][@name='userSessionPersister']/*[local-name()='default-provider']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value timer on XPath //*[local-name()='spi']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value basic on XPath //*[local-name()='spi'][@name='timer']/*[local-name()='default-provider']
