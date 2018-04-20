Feature: Hawkular agent tests

  Scenario: Verify API and defaults
    When container is started with args and env
      | arg_env                  | value |
      | env_AB_HAWKULAR_REST_URL |       |
      | arg_command              | bash -c 'source $JBOSS_CONTAINER_HAWKULAR_MODULE/hawkular-opts; test -z get_hawkular_opts; echo $?' |
    Then all files under /opt/jboss/container/hawkular are writeable by current user
      And all files under /opt/hawkular are writeable by current user
      And container log should contain 1

  # Need to mount an actual keystore to test security-realm configuration
  @ignore
  Scenario: Check full Hawkular configuration
    When container is started with args and env
      | arg_env                                | value                           |
      | env_AB_HAWKULAR_REST_URL               | https://hawkular:5280/hawkular  |
      | env_AB_HAWKULAR_REST_USER              | hawkW1nd                        |
      | env_AB_HAWKULAR_REST_PASSWORD          | QSandC77!                       |
      | env_AB_HAWKULAR_REST_FEED_ID           | project:podid                   |
      | env_AB_HAWKULAR_REST_TENANT_ID         | project                         |
      | env_AB_HAWKULAR_REST_KEYSTORE          | keystore.jks                    |
      | env_AB_HAWKULAR_REST_KEYSTORE_DIR      | /etc/hawkular-agent-volume      |
      | env_AB_HAWKULAR_REST_KEYSTORE_PASSWORD | 53same!                         |
      | arg_command                            | bash -c 'source $JBOSS_CONTAINER_HAWKULAR_MODULE/hawkular-opts; get_hawkular_opts' |
    Then container log should contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml,delay=10
      And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should contain security-realm: HawkularRealm
      And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should contain name: HawkularRealm

  Scenario: Check unsecured Hawkular configuration
    When container is started with args and env
      | arg_env                       | value                         |
      | env_AB_HAWKULAR_REST_URL      | http://hawkular:5280/hawkular |
      | env_AB_HAWKULAR_REST_USER     | hawkW1nd                      |
      | env_AB_HAWKULAR_REST_PASSWORD | QSandC77!                     |
      | arg_command                   | bash -c 'source $JBOSS_CONTAINER_HAWKULAR_MODULE/hawkular-opts; get_hawkular_opts' |
    Then container log should contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml,delay=10
      And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain security-realm: HawkularRealm
      And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain name: HawkularRealm

  Scenario: Check error on Hawkular configuration without keystore
    When container is started with args and env
      | arg_env                       | value                          |
      | env_AB_HAWKULAR_REST_URL      | https://hawkular:5280/hawkular |
      | env_AB_HAWKULAR_REST_USER     | hawkW1nd                       |
      | env_AB_HAWKULAR_REST_PASSWORD | QSandC77!                      |
      | arg_command                   | bash -c 'source $JBOSS_CONTAINER_HAWKULAR_MODULE/hawkular-opts; get_hawkular_opts' |
    Then container log should contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml,delay=10
      And container log should contain WARN No AB_HAWKULAR_REST_KEYSTORE configuration defined.  HawkularRealm security-realm will not be configured and https access to the Hawkular REST service may fail.
      And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain security-realm: HawkularRealm
      And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain name: HawkularRealm

  Scenario: Check error on Hawkular configuration with partial keystore
    When container is started with args and env
      | arg_env                       | value                          |
      | env_AB_HAWKULAR_REST_URL      | https://hawkular:5280/hawkular |
      | env_AB_HAWKULAR_REST_USER     | hawkW1nd                       |
      | env_AB_HAWKULAR_REST_PASSWORD | QSandC77!                      |
      | env_AB_HAWKULAR_REST_KEYSTORE | keystore.jks                   |
      | arg_command                   | bash -c 'source $JBOSS_CONTAINER_HAWKULAR_MODULE/hawkular-opts; get_hawkular_opts' |
    Then container log should contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml,delay=10
      And container log should contain WARN Partial AB_HAWKULAR_REST_KEYSTORE configuration defined.  HawkularRealm security-realm will not be configured and https access to the Hawkular REST service may fail.
      And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain security-realm: HawkularRealm
      And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain name: HawkularRealm

  Scenario: CLOUD-1680 - CTF tests does not test all Hawkular related parameters
    When container is started with args and env
      | arg_env                                      | value                          |
      | env_AB_HAWKULAR_REST_URL                     | https://hawkular:5280/hawkular |
      | env_AB_HAWKULAR_REST_USER                    | hawkW1nd                       |
      | env_AB_HAWKULAR_REST_PASSWORD                | QSandC77!                      |
      | env_AB_HAWKULAR_REST_KEYSTORE                | keystore.jks                   |
      | env_AB_HAWKULAR_REST_KEYSTORE_DIR            | /etc/hawkular-agent-volume     |
      | env_AB_HAWKULAR_REST_KEYSTORE_PASSWORD       | 53same!                        |
      | env_AB_HAWKULAR_REST_KEYSTORE_TYPE           | pkcs12                         |
      | env_AB_HAWKULAR_REST_KEY_MANAGER_ALGORITHM   | SunX509                        |
      | env_AB_HAWKULAR_REST_TRUST_MANAGER_ALGORITHM | RSA                            |
      | env_AB_HAWKULAR_REST_SSL_PROTOCOL            | TLSv3                          |
      | env_AB_HAWKULAR_AGENT_OPTS                   | delay=100                      |
      | arg_command                                  | bash -c 'source $JBOSS_CONTAINER_HAWKULAR_MODULE/hawkular-opts; get_hawkular_opts' |
    Then container log should contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml,delay=100
      And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should contain keystore-type: pkcs12
      And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should contain key-manager-algorithm: SunX509
      And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should contain trust-manager-algorithm: RSA
      And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should contain ssl-protocol: TLSv3

  Scenario: CLOUD-1680 - test only custom location of agent conf file
    When container is started with args and env
      | arg_env                       | value                          |
      | env_AB_HAWKULAR_REST_URL      | https://hawkular:5280/hawkular |
      | env_AB_HAWKULAR_REST_USER     | hawkW1nd                       |
      | env_AB_HAWKULAR_REST_PASSWORD | QSandC77!                      |
      | env_AB_HAWKULAR_AGENT_CONFIG  | /opt/jboss/container/hawkular-javaagent-config.yaml |
      | arg_command                   | bash -c 'source $JBOSS_CONTAINER_HAWKULAR_MODULE/hawkular-opts; get_hawkular_opts' |
    Then container log should contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular-javaagent-config.yaml,delay=10
