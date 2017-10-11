@jboss-eap-6/eap64-openshift
Feature: Check correct variable expansion used
  Scenario: Set HTTPS_NAME to null
    Given XML namespaces
      | prefix | url                      |
      | ns     | urn:jboss:domain:web:2.2 |
    When container is started with env
      | variable               | value                        |
      | EAP_HTTPS_NAME         | eap-test-https-name          |
      | EAP_HTTPS_PASSWORD     | eap-test-https-password      |
      | EAP_HTTPS_KEYSTORE_DIR | eap-test-https-keystore-dir  |
      | EAP_HTTPS_KEYSTORE     | eap-test-https-keystore      |
      | HTTPS_NAME             |                              |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //ns:connector[@name='https']/ns:ssl[@name='eap-test-https-name']

  Scenario: Set HTTPS_PASSWORD to null
    Given XML namespaces
      | prefix | url                      |
      | ns     | urn:jboss:domain:web:2.2 |
    When container is started with env
      | variable               | value                        |
      | EAP_HTTPS_NAME         | eap-test-https-name          |
      | EAP_HTTPS_PASSWORD     | eap-test-https-password      |
      | EAP_HTTPS_KEYSTORE_DIR | eap-test-https-keystore-dir  |
      | EAP_HTTPS_KEYSTORE     | eap-test-https-keystore      |
      | HTTPS_PASSWORD         |                              |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //ns:connector[@name='https']/ns:ssl[@password='eap-test-https-password']

  Scenario: Set HTTPS_KEYSTORE_DIR to null
    Given XML namespaces
      | prefix | url                      |
      | ns     | urn:jboss:domain:web:2.2 |
    When container is started with env
      | variable               | value                        |
      | EAP_HTTPS_NAME         | eap-test-https-name          |
      | EAP_HTTPS_PASSWORD     | eap-test-https-password      |
      | EAP_HTTPS_KEYSTORE_DIR | eap-test-https-keystore-dir  |
      | EAP_HTTPS_KEYSTORE     | eap-test-https-keystore      |
      | HTTPS_KEYSTORE_DIR     |                              |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //ns:connector[@name='https']/ns:ssl[@certificate-key-file='eap-test-https-keystore-dir/eap-test-https-keystore']

  Scenario: Set HTTPS_KEYSTORE to null
    Given XML namespaces
      | prefix | url                      |
      | ns     | urn:jboss:domain:web:2.2 |
    When container is started with env
      | variable               | value                        |
      | EAP_HTTPS_NAME         | eap-test-https-name          |
      | EAP_HTTPS_PASSWORD     | eap-test-https-password      |
      | EAP_HTTPS_KEYSTORE_DIR | eap-test-https-keystore-dir  |
      | EAP_HTTPS_KEYSTORE     | eap-test-https-keystore      |
      | HTTPS_KEYSTORE         |                              |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //ns:connector[@name='https']/ns:ssl[@certificate-key-file='eap-test-https-keystore-dir/eap-test-https-keystore']

  Scenario: Set EAP_SECDOMAIN_USERS_PROPERTIES to null
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
      | variable                       | value                        |
      | EAP_SECDOMAIN_NAME             | eap-secdomain-name           |
      | EAP_SECDOMAIN_USERS_PROPERTIES |                              |
    And XML namespaces
      | prefix | url                           |
      | ns     | urn:jboss:domain:security:1.2 |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //ns:security-domain[@name='eap-secdomain-name']/ns:authentication/ns:login-module/ns:module-option[@name='usersProperties' and @value='${jboss.server.config.dir}/users.properties']

  Scenario: Set SECDOMAIN_USERS_PROPERTIES to null
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
      | variable                   | value                        |
      | EAP_SECDOMAIN_NAME         | eap-secdomain-name           |
      | SECDOMAIN_USERS_PROPERTIES |                              |
    And XML namespaces
      | prefix | url                           |
      | ns     | urn:jboss:domain:security:1.2 |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //ns:security-domain[@name='eap-secdomain-name']/ns:authentication/ns:login-module/ns:module-option[@name='usersProperties' and @value='${jboss.server.config.dir}/users.properties']

  Scenario: Set EAP_SECDOMAIN_ROLES_PROPERTIES to null
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
      | variable                       | value                        |
      | EAP_SECDOMAIN_NAME             | eap-secdomain-name           |
      | EAP_SECDOMAIN_ROLES_PROPERTIES |                              |
    And XML namespaces
      | prefix | url                           |
      | ns     | urn:jboss:domain:security:1.2 |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //ns:security-domain[@name='eap-secdomain-name']/ns:authentication/ns:login-module/ns:module-option[@name='rolesProperties' and @value='${jboss.server.config.dir}/roles.properties']

  Scenario: Set SECDOMAIN_ROLES_PROPERTIES to null
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
      | variable                   | value                        |
      | EAP_SECDOMAIN_NAME         | eap-secdomain-name           |
      | SECDOMAIN_ROLES_PROPERTIES |                              |
    And XML namespaces
      | prefix | url                           |
      | ns     | urn:jboss:domain:security:1.2 |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //ns:security-domain[@name='eap-secdomain-name']/ns:authentication/ns:login-module/ns:module-option[@name='rolesProperties' and @value='${jboss.server.config.dir}/roles.properties']

  Scenario: Set SECDOMAIN_NAME to null
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
      | variable               | value                        |
      | EAP_SECDOMAIN_NAME     | eap-secdomain-name           |
      | SECDOMAIN_NAME         |                              |
    And XML namespaces
      | prefix | url                           |
      | ns     | urn:jboss:domain:security:1.2 |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //ns:security-domain[@name='eap-secdomain-name']

  Scenario: Set SECDOMAIN_PASSWORD_STACKING to null
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
      | variable                        | value                           |
      | EAP_SECDOMAIN_NAME              | eap-secdomain-name              |
      | EAP_SECDOMAIN_PASSWORD_STACKING | eap-secdomain-password-stacking |
      | SECDOMAIN_PASSWORD_STACKING     |                                 |
    And XML namespaces
      | prefix | url                           |
      | ns     | urn:jboss:domain:security:1.2 |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //ns:security-domain[@name='eap-secdomain-name']/ns:authentication/ns:login-module/ns:module-option[@name='password-stacking']

    Scenario: Check HTTPS basic config
    When container is started with env
      | variable               | value                        |
      | HTTPS_NAME             | jboss                        |
      | HTTPS_PASSWORD         | mykeystorepass               |
      | HTTPS_KEYSTORE_DIR     | /etc/eap-secret-volume       |
      | HTTPS_KEYSTORE         | keystore.jks                 |
      | HTTPS_KEYSTORE_TYPE    | JKS                          |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /etc/eap-secret-volume/keystore.jks on XPath //*[local-name()='connector']/*[local-name()='ssl']/@certificate-key-file
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mykeystorepass on XPath //*[local-name()='connector']/*[local-name()='ssl']/@password
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jboss on XPath //*[local-name()='connector']/*[local-name()='ssl']/@key-alias
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value JKS on XPath //*[local-name()='connector']/*[local-name()='ssl']/@keystore-type

