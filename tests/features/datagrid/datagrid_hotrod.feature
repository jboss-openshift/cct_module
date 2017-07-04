@openshift @datagrid
Feature: Openshift JDG hotrod tests

  Scenario: hotrod-internal-endpoint
    When container is started with env
       | variable                                     | value                                  |
       | INFINISPAN_CONNECTORS                        | hotrod                                 |
       | HOTROD_AUTHENTICATION                        | true                                   |
       | HOTROD_ENCRYPTION                            | true                                   |
       | ENCRYPTION_REQUIRE_SSL_CLIENT_AUTH           | false                                  |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPATH //*[local-name()='hotrod-connector']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value clustered on XPath //*[local-name()='hotrod-connector']/@cache-container
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value hotrod-internal on XPath //*[local-name()='hotrod-connector']/@socket-binding
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value hotrod-internal on XPath //*[local-name()='hotrod-connector']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ApplicationRealm on XPath //*[local-name()='hotrod-connector']/*[local-name()='authentication']/@security-realm
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value jdg-server on XPath //*[local-name()='hotrod-connector']/*[local-name()='authentication']/*[local-name()='sasl']/@server-name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value DIGEST-MD5 on XPath //*[local-name()='hotrod-connector']/*[local-name()='authentication']/*[local-name()='sasl']/@mechanisms
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value auth on XPath //*[local-name()='hotrod-connector']/*[local-name()='authentication']/*[local-name()='sasl']/@qop
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPath //*[local-name()='hotrod-connector']/*[local-name()='authentication']/*[local-name()='sasl']/*[local-name()='policy']/*[local-name()='no-anonymous']/@value
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value com.sun.security.sasl.digest.utf8 on XPath //*[local-name()='hotrod-connector']/*[local-name()='authentication']/*[local-name()='sasl']/*[local-name()='property']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPath //*[local-name()='hotrod-connector']/*[local-name()='authentication']/*[local-name()='sasl']/*[local-name()='property'][@name="com.sun.security.sasl.digest.utf8"]
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ApplicationRealm on XPath //*[local-name()='hotrod-connector']/*[local-name()='encryption']/@security-realm
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value false on XPath //*[local-name()='hotrod-connector']/*[local-name()='encryption']/@require-ssl-client-auth

  Scenario: hotrod-external-endpoint
    When container is started with env
       | variable                                     | value                                  |
       | INFINISPAN_CONNECTORS                        | hotrod                                 |
       | HOTROD_AUTHENTICATION                        | true                                   |
       | HOTROD_ENCRYPTION                            | true                                   |
       | ENCRYPTION_REQUIRE_SSL_CLIENT_AUTH           | false                                  |
       | HOTROD_SERVICE_NAME                          | DATAGRID_APP_HOTROD                    |
       | DATAGRID_APP_HOTROD_SERVICE_HOST             | 10.0.0.1                               |
       | DATAGRID_APP_HOTROD_SERVICE_PORT             | 11444                                  |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 2 elements on XPath //*[local-name()='hotrod-connector']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value clustered on XPath //*[local-name()='hotrod-connector']/@cache-container
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value hotrod-internal on XPath //*[local-name()='hotrod-connector']/@socket-binding
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value hotrod-internal on XPath //*[local-name()='hotrod-connector']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ApplicationRealm on XPath //*[local-name()='hotrod-connector']/*[local-name()='authentication']/@security-realm
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value jdg-server on XPath //*[local-name()='hotrod-connector']/*[local-name()='authentication']/*[local-name()='sasl']/@server-name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value DIGEST-MD5 on XPath //*[local-name()='hotrod-connector']/*[local-name()='authentication']/*[local-name()='sasl']/@mechanisms
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value auth on XPath //*[local-name()='hotrod-connector']/*[local-name()='authentication']/*[local-name()='sasl']/@qop
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPath //*[local-name()='hotrod-connector']/*[local-name()='authentication']/*[local-name()='sasl']/*[local-name()='policy']/*[local-name()='no-anonymous']/@value
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value com.sun.security.sasl.digest.utf8 on XPath //*[local-name()='hotrod-connector']/*[local-name()='authentication']/*[local-name()='sasl']/*[local-name()='property']/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value true on XPath //*[local-name()='hotrod-connector']/*[local-name()='authentication']/*[local-name()='sasl']/*[local-name()='property'][@name="com.sun.security.sasl.digest.utf8"]
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ApplicationRealm on XPath //*[local-name()='hotrod-connector']/*[local-name()='encryption']/@security-realm
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value false on XPath //*[local-name()='hotrod-connector']/*[local-name()='encryption']/@require-ssl-client-auth
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value clustered on XPath //*[local-name()='hotrod-connector'][@name="hotrod-external"]/@cache-container
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value hotrod-external on XPath //*[local-name()='hotrod-connector'][@name="hotrod-external"]/@socket-binding
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value hotrod-external on XPath //*[local-name()='hotrod-connector'][@name="hotrod-external"]/@name
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='hotrod-connector'][@name="hotrod-external"]/*[local-name()='topology-state-transfer']
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 10.0.0.1 on XPath //*[local-name()='hotrod-connector'][@name="hotrod-external"]/*[local-name()='topology-state-transfer']/@external-host
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 11444 on XPath //*[local-name()='hotrod-connector'][@name="hotrod-external"]/*[local-name()='topology-state-transfer']/@external-port
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ApplicationRealm on XPath //*[local-name()='hotrod-connector'][@name="hotrod-external"]/*[local-name()='authentication']/@security-realm
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value ApplicationRealm on XPath //*[local-name()='hotrod-connector'][@name="hotrod-external"]/*[local-name()='encryption']/@security-realm
    And XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value false on XPath //*[local-name()='hotrod-connector'][@name="hotrod-external"]/*[local-name()='encryption']/@require-ssl-client-auth

  Scenario: hotrod-external-endpoint-default-service-port
    When container is started with env
       | variable                                     | value                                  |
       | INFINISPAN_CONNECTORS                        | hotrod                                 |
       | HOTROD_AUTHENTICATION                        | true                                   |
       | HOTROD_ENCRYPTION                            | true                                   |
       | ENCRYPTION_REQUIRE_SSL_CLIENT_AUTH           | false                                  |
       | HOTROD_SERVICE_NAME                          | DATAGRID_APP_HOTROD                    |
       | DATAGRID_APP_HOTROD_SERVICE_HOST             | 10.0.0.1                               |
    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should contain value 11333 on XPath //*[local-name()='hotrod-connector'][@name="hotrod-external"]/*[local-name()='topology-state-transfer']/@external-port

  Scenario: authenticated cache
    When container is started with env
       | variable                                         | value               |
       | CACHE_NAMES                                      | ADDRESSBOOK         |
       | ADDRESSBOOK_CACHE_SECURITY_AUTHORIZATION_ENABLED | true                |
       | ADDRESSBOOK_CACHE_SECURITY_AUTHORIZATION_ROLES   | admin               |
       | HOTROD_AUTHENTICATION                            | true                |
       | CONTAINER_SECURITY_ROLES                         | admin=ALL           |
    Then container log should contain started in
    And available container log should not contain ParseError
