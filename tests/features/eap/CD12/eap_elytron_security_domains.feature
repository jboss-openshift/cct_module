@jboss-eap-7/eap-cd-openshift
Feature: EAP Openshift Elytron security domains

  Scenario: check Elytron configuration
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
       | variable           | value       |
       | SECDOMAIN_NAME     | application-security     |
     Then container log should contain Running jboss-eap-
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value application-security on XPath //*[local-name()='elytron-integration']/*[local-name()='security-realms']/*[local-name()='elytron-realm']/@name
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value application-security on XPath //*[local-name()='elytron-integration']/*[local-name()='security-realms']/*[local-name()='elytron-realm']/@legacy-jaas-config
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value application-security on XPath //*[local-name()='subsystem'][namespace-uri()='urn:jboss:domain:ejb3:5.0']/*[local-name()='application-security-domains']/*[local-name()='application-security-domain']/@name
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value application-security on XPath //*[local-name()='subsystem'][namespace-uri()='urn:jboss:domain:ejb3:5.0']/*[local-name()='application-security-domains']/*[local-name()='application-security-domain']/@security-domain
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value application-security on XPath //*[local-name()='subsystem'][namespace-uri()='urn:jboss:domain:undertow:6.0']/*[local-name()='application-security-domains']/*[local-name()='application-security-domain']/@name
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value application-security-http on XPath //*[local-name()='subsystem'][namespace-uri()='urn:jboss:domain:undertow:6.0']/*[local-name()='application-security-domains']/*[local-name()='application-security-domain']/@http-authentication-factory
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value BASIC on XPath //*[local-name()='http-authentication-factory'][@name='application-http-authentication'][@security-domain='ApplicationDomain']/*[local-name()='mechanism-configuration']/*[local-name()='mechanism'][1]/@mechanism-name
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value FORM on XPath //*[local-name()='http-authentication-factory'][@name='application-http-authentication'][@security-domain='ApplicationDomain']/*[local-name()='mechanism-configuration']/*[local-name()='mechanism'][2]/@mechanism-name
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value application-security on XPath //*[local-name()='security-domain'][@name='application-security'][@default-realm='application-security']/*[local-name()='realm']/@name


  Scenario: check security-domain unconfigured
    When container is started with env
       | variable                  | value       |
       | UNRELATED_ENV_VARIABLE    | whatever    |
    Then container log should contain Running jboss-eap-
     And file /opt/eap/standalone/configuration/standalone-openshift.xml should contain <!-- no additional security domains configured -->
