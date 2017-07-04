@openshift @sso
Feature: OpenShift SSO tests

  Scenario: Test console is available
    When container is ready
    Then check that page is served
         | property | value |
         | port     | 8080  |
         | path     | /auth/admin/master/console/#/realms/master |
         | expected_status_code | 200 |

  Scenario: Test root context is available
    When container is ready
    Then check that page is served
         | property             | value |
         | port                 | 8080  |
         | path                 | /     |
         | expected_status_code | 200   |

  Scenario: check for keycloak datasource
    Given XML namespaces
      | prefix | url                           |
      | ns     | urn:jboss:domain:datasources:4.0 |
    When container is ready
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/datasources/KeycloakDS on XPath //ns:datasource/@jndi-name    

    Scenario: check for keycloak server
    Given XML namespaces
      | prefix | url                           |
      | ns     | urn:jboss:domain:keycloak-server:1.1 |
    When container is ready
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value auth on XPath //ns:web-context

  Scenario: check for keycloak deployment
    When container is ready
    Then container log should contain WFLYSRV0010: Deployed "keycloak-server.war"

   Scenario: check for realm creation
    Given XML namespaces
     | prefix | url                            |
     | ns     | urn:infinispan:server:core:6.3 |
    When container is started with env
       | variable                                          | value                            |
       | SSO_REALM                                         | demo                             |
    Then check that page is served
         | property | value |
         | port     | 8080  |
         | path     | /auth/admin/master/console/#/realms/demo |
         | expected_status_code | 200 |

  # CLOUD-612
  Scenario: test SSO probes
    When container is ready
    Then container log should contain WFLYSRV0025
    Then run /opt/eap/bin/readinessProbe.sh in container once
    Then run /opt/eap/bin/livenessProbe.sh in container once

  # CLOUD-769
  Scenario: test jolokia started
    When container is ready
    Then container log should contain -javaagent:/opt/jolokia/jolokia.jar=config=/opt/jolokia/etc/jolokia.properties
     And available container log should not contain java.net.BindException

  Scenario: Test REST API is available and secure
    When container is ready
    Then check that page is served
         | property             | value                     |
         | port                 | 8080                      |
         | path                 | /auth/admin/realms/master |
         | username             | admin                     |
         | password             | admin                     |
         | expected_status_code | 401                       |
         | expected_phrase      | Bearer                    |

