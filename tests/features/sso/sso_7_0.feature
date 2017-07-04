@openshift @sso_7_0
Feature: OpenShift SSO 7.0 tests

  Scenario: check for legacy keycloak cache 7.0
    Given XML namespaces
      | prefix | url                           |
      | ns     | urn:jboss:domain:infinispan:4.0 |
    When container is ready
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value keycloak on XPath //ns:cache-container/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value realms on XPath //ns:invalidation-cache/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value users on XPath //ns:invalidation-cache/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value sessions on XPath //ns:replicated-cache/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value offlineSessions on XPath //ns:replicated-cache/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value loginFailures on XPath //ns:replicated-cache/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value work on XPath //ns:replicated-cache/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value realmVersions on XPath //ns:local-cache/@name

Scenario: check for keycloak cache 7.0
    Given XML namespaces
      | prefix | url                           |
      | ns     | urn:jboss:domain:infinispan:4.0 |
    When container is started with env
       | variable                         | value             |
       | LEGACY_KEYCLOAK_CACHE_CONTAINER  | false             |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value keycloak on XPath //ns:cache-container/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value realms on XPath //ns:invalidation-cache/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value users on XPath //ns:invalidation-cache/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value sessions on XPath //ns:distributed-cache/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value offlineSessions on XPath //ns:distributed-cache/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value loginFailures on XPath //ns:distributed-cache/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value work on XPath //ns:replicated-cache/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value realmVersions on XPath //ns:local-cache/@name

