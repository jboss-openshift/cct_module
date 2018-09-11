@jboss-eap-7 @jboss-eap-tech-preview
Feature: EAP 7 Openshift filters

  Scenario: CLOUD-2877, RHDM-520, RHPAM-1434, test default filter ref name
    When container is started with env
      | variable                         | value      |
      | FILTERS                          | FOO        |
      | FOO_FILTER_RESPONSE_HEADER_NAME  | Foo-Header |
      | FOO_FILTER_RESPONSE_HEADER_VALUE | FOO        |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value Foo-Header on XPath //*[local-name()='host']/*[local-name()='filter-ref']/@name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value Foo-Header on XPath //*[local-name()='filters']/*[local-name()='response-header']/@name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value Foo-Header on XPath //*[local-name()='filters']/*[local-name()='response-header']/@header-name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value FOO on XPath //*[local-name()='filters']/*[local-name()='response-header']/@header-value

  Scenario: CLOUD-2877, RHDM-520, RHPAM-1434, test specific filter ref name
    When container is started with env
      | variable                         | value      |
      | FILTERS                          | FOO        |
      | FOO_FILTER_REF_NAME              | foo        |
      | FOO_FILTER_RESPONSE_HEADER_NAME  | Foo-Header |
      | FOO_FILTER_RESPONSE_HEADER_VALUE | FOO        |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value foo on XPath //*[local-name()='host']/*[local-name()='filter-ref']/@name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value foo on XPath //*[local-name()='filters']/*[local-name()='response-header']/@name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value Foo-Header on XPath //*[local-name()='filters']/*[local-name()='response-header']/@header-name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value FOO on XPath //*[local-name()='filters']/*[local-name()='response-header']/@header-value
