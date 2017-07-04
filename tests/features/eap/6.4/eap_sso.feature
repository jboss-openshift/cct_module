@openshift @eap_6_4 
Feature: OpenShift EAP SSO tests

   Scenario: deploys the keycloak examples, then checks if it's deployed.
     Given XML namespaces
       | prefix | url                          |
       | ns     | urn:jboss:domain:keycloak:1.1 |
     Given s2i build https://github.com/redhat-developer/redhat-sso-quickstarts using 7.0.x-ose
       | variable               | value                                            |
       | ARTIFACT_DIR           | app-jee-jsp/target,app-profile-jee-jsp/target |
       | SSO_REALM         | demo    |
       | SSO_PUBLIC_KEY    | MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAiLezsNQtZSaJvNZXTmjhlpIJnnwgGL5R1vkPLdt7odMgDzLHQ1h4DlfJPuPI4aI8uo8VkSGYQXWaOGUh3YJXtdO1vcym1SuP8ep6YnDy9vbUibA/o8RW6Wnj3Y4tqShIfuWf3MEsiH+KizoIJm6Av7DTGZSGFQnZWxBEZ2WUyFt297aLWuVM0k9vHMWSraXQo78XuU3pxrYzkI+A4QpeShg8xE7mNrs8g3uTmc53KR45+wW1icclzdix/JcT6YaSgLEVrIR9WkkYfEGj3vSrOzYA46pQe6WQoenLKtIDFmFDPjhcPoi989px9f+1HCIYP0txBS/hnJZaPdn5/lEUKQIDAQAB  |
       | SSO_URL           | http://localhost:8080/auth    |
    Then container log should contain JBAS015859: Deployed "app-profile-jsp.war"
    Then container log should contain JBAS015859: Deployed "app-jsp.war"
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value demo on XPath //ns:realm/@name

   Scenario: deploys the keycloak examples using secure-deployments then checks if it's deployed.
     Given XML namespaces
       | prefix | url                          |
       | ns     | urn:jboss:domain:keycloak:1.1 |
     Given s2i build http://github.com/bdecoste/keycloak-examples using securedeployments
       | variable                   | value                                            |
       | ARTIFACT_DIR               | app-profile-jee-saml/target,app-profile-jee/target |
    Then container log should contain JBAS015859: Deployed "app-profile-jee.war"
    Then container log should contain JBAS015859: Deployed "app-profile-jee-saml.war"
