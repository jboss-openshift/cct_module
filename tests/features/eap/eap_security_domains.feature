@jboss-eap-6/eap64-openshift @jboss-eap-7
Feature: EAP Openshift security domains

  Scenario: check security-domain configured
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
       | variable           | value       |
       | SECDOMAIN_NAME | HiThere     |
     Then container log should contain Running jboss-eap-
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='security-domain'][@name='HiThere'][@cache-type='default']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option'][@name='rolesProperties'][@value='${jboss.server.config.dir}/roles.properties']

  Scenario: check security-domain unconfigured
    When container is started with env
       | variable                  | value       |
       | UNRELATED_ENV_VARIABLE    | whatever    |
    Then container log should contain Running jboss-eap-
     And file /opt/eap/standalone/configuration/standalone-openshift.xml should contain <!-- no additional security domains configured -->
    # 3 OOTB are: jboss-web-policy; jboss-ejb-policy; other
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 3 elements on XPath //*[local-name()='security-domain']

  Scenario: check security-domain custom user properties
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
       | variable                        | value                 |
       | SECDOMAIN_NAME              | HiThere               |
       | SECDOMAIN_USERS_PROPERTIES  | otherusers.properties |
     Then container log should contain Running jboss-eap-
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='security-domain'][@name='HiThere'][@cache-type='default']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option'][@name='usersProperties'][@value='${jboss.server.config.dir}/otherusers.properties']

  Scenario: check security-domain custom role properties
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
       | variable                        | value                 |
       | SECDOMAIN_NAME              | HiThere               |
       | SECDOMAIN_ROLES_PROPERTIES  | otherroles.properties |
     Then container log should contain Running jboss-eap-
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='security-domain'][@name='HiThere'][@cache-type='default']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option'][@name='rolesProperties'][@value='${jboss.server.config.dir}/otherroles.properties']

  # CLOUD-431
  Scenario: check security-domain custom role and user properties specified as absolute path
    When container is started with env
       | variable                        | value                 |
       | SECDOMAIN_NAME              | HiThere                   |
       | SECDOMAIN_ROLES_PROPERTIES  | /opt/eap/standalone/configuration/application-roles.properties |
       | SECDOMAIN_USERS_PROPERTIES  | /opt/eap/standalone/configuration/application-users.properties |
     Then container log should contain Running jboss-eap-
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /opt/eap/standalone/configuration/application-roles.properties on XPath //*[local-name()='security-domain'][@name='HiThere'][@cache-type='default']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option'][@name='rolesProperties']/@value
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /opt/eap/standalone/configuration/application-users.properties on XPath //*[local-name()='security-domain'][@name='HiThere'][@cache-type='default']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option'][@name='usersProperties']/@value

  Scenario: check security-domain classic login module
    When container is started with env
      | variable                        | value                        |
      | SECDOMAIN_NAME                  | jdg-openshift                |
      | SECDOMAIN_USERS_PROPERTIES      | application-users.properties |
      | SECDOMAIN_ROLES_PROPERTIES      | application-roles.properties |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value UsersRoles on XPath //*[local-name()='security-domain'][@name='jdg-openshift']//*[local-name()='login-module']/@code

  Scenario: check security-domain realm login module
    When container is started with env
      | variable                        | value                        |
      | SECDOMAIN_NAME                  | jdg-openshift                |
      | SECDOMAIN_LOGIN_MODULE          | RealmUsersRoles              |
      | SECDOMAIN_USERS_PROPERTIES      | application-users.properties |
      | SECDOMAIN_ROLES_PROPERTIES      | application-roles.properties |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value RealmUsersRoles on XPath //*[local-name()='security-domain'][@name='jdg-openshift']//*[local-name()='login-module']/@code
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value ApplicationRealm on XPath //*[local-name()='security-domain'][@name='jdg-openshift']//*[local-name()='login-module']/*[local-name()='module-option'][@name='realm']/@value

  Scenario: check security-domain configured with prefix
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
       | variable           | value       |
       | EAP_SECDOMAIN_NAME | HiThere     |
     Then container log should contain Running jboss-eap-
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='security-domain'][@name='HiThere'][@cache-type='default']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option'][@name='rolesProperties'][@value='${jboss.server.config.dir}/roles.properties']

  Scenario: check security-domain unconfigured with prefix
    When container is started with env
       | variable                  | value       |
       | UNRELATED_ENV_VARIABLE    | whatever    |
    Then file /opt/eap/standalone/configuration/standalone-openshift.xml should contain <!-- no additional security domains configured -->
    # 3 OOTB are: jboss-web-policy; jboss-ejb-policy; other
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 3 elements on XPath //*[local-name()='security-domain']

  Scenario: check security-domain custom user properties with prefix
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
       | variable                        | value                 |
       | EAP_SECDOMAIN_NAME              | HiThere               |
       | EAP_SECDOMAIN_USERS_PROPERTIES  | otherusers.properties |
     Then container log should contain Running jboss-eap-
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='security-domain'][@name='HiThere'][@cache-type='default']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option'][@name='usersProperties'][@value='${jboss.server.config.dir}/otherusers.properties']

  Scenario: check security-domain custom role properties with prefix
    Given s2i build https://github.com/jboss-openshift/openshift-examples from security-custom-configuration with env
       | variable                        | value                 |
       | EAP_SECDOMAIN_NAME              | HiThere               |
       | EAP_SECDOMAIN_ROLES_PROPERTIES  | otherroles.properties |
     Then container log should contain Running jboss-eap-
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='security-domain'][@name='HiThere'][@cache-type='default']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option'][@name='rolesProperties'][@value='${jboss.server.config.dir}/otherroles.properties']

  @wip
  Scenario: check custom SECURITY_DOMAINS
    When container is started with env
       | variable                                             | value                                                     |
       | SECURITY_DOMAINS                                     | sso,ldap                                                  |
       | sso_LOGIN_MODULE_NAME                                | sso                                                       |
       | sso_LOGIN_MODULE_CODE                                | org.keycloak.adapters.jaas.DirectAccessGrantsLoginModule  |
       | sso_LOGIN_MODULE_MODULE                              | org.keycloak.keycloak-adapter-core                        |
       | sso_MODULE_OPTION_NAME_keycloak_config_file          | keycloak-config-file                                      |
       | sso_MODULE_OPTION_VALUE_keycloak_config_file         | /opt/eap/keycloak/keycloak.json                           |
       | sso_MODULE_OPTION_NAME_password_stacking             | password-stacking                                         |
       | sso_MODULE_OPTION_VALUE_password_stacking            | useFirstPass                                              |
       | ldap_LOGIN_MODULE_NAME                               | ldap                                                      |
       | ldap_LOGIN_MODULE_CODE                               | LdapExtended                                              |
       | ldap_MODULE_OPTION_NAME_java_naming_factory_initial  | java.naming.factory.initial                               |
       | ldap_MODULE_OPTION_VALUE_java_naming_factory_initial | com.sun.jndi.ldap.LdapCtxFactory                          |
       | ldap_MODULE_OPTION_NAME_java_naming_provider_url     | java.naming.provider.url                                  |
       | ldap_MODULE_OPTION_VALUE_java_naming_provider_url    | ldap://localhost:389                                      |
       | ldap_MODULE_OPTION_NAME_bindDN                       | bindDN                                                    |
       | ldap_MODULE_OPTION_VALUE_bindDN                      | myuser                                                    |
     Then container log should contain Running jboss-eap-
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='security-domain'][@name='sso']
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.keycloak.adapters.jaas.DirectAccessGrantsLoginModule on XPath //*[local-name()='security-domain'][@name='sso']/*[local-name()='authentication']/*[local-name()='login-module']/@code
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.keycloak.keycloak-adapter-core on XPath //*[local-name()='security-domain'][@name='sso']/*[local-name()='authentication']/*[local-name()='login-module']/@module
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value keycloak-config-file on XPath //*[local-name()='security-domain'][@name='sso']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option']/@name
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /opt/eap/keycloak/keycloak.json on XPath //*[local-name()='security-domain'][@name='sso']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option']/@value
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value password-stacking on XPath //*[local-name()='security-domain'][@name='sso']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option']/@name
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value useFirstPass on XPath //*[local-name()='security-domain'][@name='sso']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option']/@value
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 1 elements on XPath //*[local-name()='security-domain'][@name='ldap']
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value LdapExtended on XPath //*[local-name()='security-domain'][@name='ldap']/*[local-name()='authentication']/*[local-name()='login-module']/@code
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java.naming.factory.initial on XPath //*[local-name()='security-domain'][@name='ldap']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option']/@name
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value com.sun.jndi.ldap.LdapCtxFactory on XPath //*[local-name()='security-domain'][@name='ldap']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option']/@value
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java.naming.provider.url on XPath //*[local-name()='security-domain'][@name='ldap']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option']/@name
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value ldap://localhost:389 on XPath //*[local-name()='security-domain'][@name='ldap']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option']/@value
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value bindDN on XPath //*[local-name()='security-domain'][@name='ldap']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option']/@name
      And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value myuser on XPath //*[local-name()='security-domain'][@name='ldap']/*[local-name()='authentication']/*[local-name()='login-module']/*[local-name()='module-option']/@value
