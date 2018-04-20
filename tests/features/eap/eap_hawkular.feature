@jboss-eap-7 @jboss-eap-6 @jboss-eap-7-tech-preview
Feature: OpenShift EAP Hawkular agent tests

   Scenario: Check default Hawkular
     When container is ready
     Then container log should not contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml,delay=10 

   # Need to mount an actual keystore to test security-realm configuration
   @ignore
   Scenario: Check full Hawkular configuration
     When container is started with env
       | variable                            | value                           |
       | AB_HAWKULAR_REST_URL                | https://hawkular:5280/hawkular  |
       | AB_HAWKULAR_REST_USER               | hawkW1nd                        |
       | AB_HAWKULAR_REST_PASSWORD           | QSandC77!                       |
       | AB_HAWKULAR_REST_FEED_ID            | project:podid                   |
       | AB_HAWKULAR_REST_TENANT_ID          | project                         |
       | AB_HAWKULAR_REST_KEYSTORE           | keystore.jks                    |
       | AB_HAWKULAR_REST_KEYSTORE_DIR       | /etc/hawkular-agent-volume      |
       | AB_HAWKULAR_REST_KEYSTORE_PASSWORD  | 53same!                         |
     Then container log should contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml,delay=10
       And container log should contain hawkular.agent.in-container = true
       And container log should contain hawkular.rest.user = hawkW1nd
       And container log should contain -Dhawkular.rest.password=QSandC77!
       And container log should contain hawkular.rest.host = https://hawkular:5280/hawkular
       And container log should contain hawkular.rest.tenantId = project
       And container log should contain hawkular.rest.feedId = project:podid
       And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should contain security-realm: HawkularRealm
       And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should contain name: HawkularRealm

   Scenario: Check unsecured Hawkular configuration
     When container is started with env
       | variable                            | value                           |
       | AB_HAWKULAR_REST_URL                | http://hawkular:5280/hawkular   |
       | AB_HAWKULAR_REST_USER               | hawkW1nd                        |
       | AB_HAWKULAR_REST_PASSWORD           | QSandC77!                       |
     Then container log should contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml,delay=10
       And container log should contain hawkular.agent.in-container = true
       And container log should contain hawkular.rest.user = hawkW1nd
       And container log should contain -Dhawkular.rest.password=QSandC77!
       And container log should contain hawkular.rest.host = http://hawkular:5280/hawkular
       And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain security-realm: HawkularRealm
       And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain name: HawkularRealm

   Scenario: Check error on Hawkular configuration without keystore
     When container is started with env
       | variable                            | value                           |
       | AB_HAWKULAR_REST_URL                | https://hawkular:5280/hawkular  |
       | AB_HAWKULAR_REST_USER               | hawkW1nd                        |
       | AB_HAWKULAR_REST_PASSWORD           | QSandC77!                       |
     Then container log should contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml,delay=10
       And container log should contain hawkular.agent.in-container = true
       And container log should contain hawkular.rest.user = hawkW1nd
       And container log should contain -Dhawkular.rest.password=QSandC77!
       And container log should contain hawkular.rest.host = https://hawkular:5280/hawkular
       And container log should contain WARN No AB_HAWKULAR_REST_KEYSTORE configuration defined.  HawkularRealm security-realm will not be configured and https access to the Hawkular REST service may fail.
       And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain security-realm: HawkularRealm
       And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain name: HawkularRealm

   Scenario: Check error on Hawkular configuration with partial keystore
     When container is started with env
       | variable                            | value                           |
       | AB_HAWKULAR_REST_URL                | https://hawkular:5280/hawkular  |
       | AB_HAWKULAR_REST_USER               | hawkW1nd                        |
       | AB_HAWKULAR_REST_PASSWORD           | QSandC77!                       |
       | AB_HAWKULAR_REST_KEYSTORE           | keystore.jks                    |
     Then container log should contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml,delay=10
       And container log should contain hawkular.agent.in-container = true
       And container log should contain hawkular.rest.user = hawkW1nd
       And container log should contain -Dhawkular.rest.password=QSandC77!
       And container log should contain hawkular.rest.host = https://hawkular:5280/hawkular
       And container log should contain WARN Partial AB_HAWKULAR_REST_KEYSTORE configuration defined.  HawkularRealm security-realm will not be configured and https access to the Hawkular REST service may fail.
       And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain security-realm: HawkularRealm
       And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain name: HawkularRealm

  Scenario: CLOUD-1680 - CTF tests does not test all Hawkular related parameters
    When container is started with env
      | variable                                 | value                               |
      | AB_HAWKULAR_REST_URL                     | https://hawkular:5280/hawkular      |
      | AB_HAWKULAR_REST_USER                    | hawkW1nd                            |
      | AB_HAWKULAR_REST_PASSWORD                | QSandC77!                           |
      | AB_HAWKULAR_REST_KEYSTORE                | keystore.jks                        |
      | AB_HAWKULAR_REST_KEYSTORE_DIR            | /etc/hawkular-agent-volume          |
      | AB_HAWKULAR_REST_KEYSTORE_PASSWORD       | 53same!                             |
      | AB_HAWKULAR_REST_KEYSTORE_TYPE           | pkcs12                              |
      | AB_HAWKULAR_REST_KEY_MANAGER_ALGORITHM   | SunX509                             |
      | AB_HAWKULAR_REST_TRUST_MANAGER_ALGORITHM | RSA                                 |
      | AB_HAWKULAR_REST_SSL_PROTOCOL            | TLSv3                               |
      | AB_HAWKULAR_AGENT_OPTS                   | delay=100                           |
    Then container log should contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml,delay=100
    And container log should contain hawkular.agent.in-container = true
    And container log should contain hawkular.rest.user = hawkW1nd
    And container log should contain -Dhawkular.rest.password=QSandC77!
    And container log should contain hawkular.rest.host = https://hawkular:5280/hawkular
    And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should contain keystore-type: pkcs12
    And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should contain key-manager-algorithm: SunX509
    And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should contain trust-manager-algorithm: RSA
    And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should contain ssl-protocol: TLSv3

  Scenario: CLOUD-1680 - test only custom location of agent conf file
    When container is started with env
      | variable                                 | value                               |
      | AB_HAWKULAR_REST_URL                     | https://hawkular:5280/hawkular      |
      | AB_HAWKULAR_REST_USER                    | hawkW1nd                            |
      | AB_HAWKULAR_REST_PASSWORD                | QSandC77!                           |
      | AB_HAWKULAR_AGENT_CONFIG                 | /opt/jboss/container/hawkular-javaagent-config.yaml |
    Then container log should contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular-javaagent-config.yaml,delay=10