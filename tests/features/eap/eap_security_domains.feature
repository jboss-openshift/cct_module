@openshift @eap_6_4 @eap_7_0
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
