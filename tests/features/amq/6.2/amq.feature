@jboss-amq-6/amq62-openshift
Feature: Openshift AMQ tests

  Scenario: Check that the readinessProbe correctly identifies the transport ports
    When container is started with env
       | variable                    | value                    |
       | AMQ_TRANSPORTS              | openwire,mqtt,amqp,stomp |
       | AMQ_KEYSTORE_TRUSTSTORE_DIR | /opt/amq/conf            |
       | AMQ_KEYSTORE                | broker.ks                |
       | AMQ_KEYSTORE_PASSWORD       | password                 |
       | AMQ_TRUSTSTORE              | broker.ts                |
       | AMQ_TRUSTSTORE_PASSWORD     | password                 |
    Then container log should contain INFO | Apache ActiveMQ
     And check that port 61616 is open
    Then run sh -c '/opt/amq/bin/readinessProbe.sh 1 1 true && echo all good' in container and check its output for all good
    Then file /tmp/readiness-log should contain openwire port 61616
    Then file /tmp/readiness-log should contain Transport is listening on port 61616
    Then file /tmp/readiness-log should contain ssl port 61617
    Then file /tmp/readiness-log should contain Transport is listening on port 61617
    Then file /tmp/readiness-log should contain mqtt port 1883
    Then file /tmp/readiness-log should contain Transport is listening on port 1883
    Then file /tmp/readiness-log should contain mqtt+ssl port 8883
    Then file /tmp/readiness-log should contain Transport is listening on port 8883
    Then file /tmp/readiness-log should contain amqp port 5672
    Then file /tmp/readiness-log should contain Transport is listening on port 5672
    Then file /tmp/readiness-log should contain amqp+ssl port 5671
    Then file /tmp/readiness-log should contain Transport is listening on port 5671
    Then file /tmp/readiness-log should contain stomp port 61613
    Then file /tmp/readiness-log should contain Transport is listening on port 61613
    Then file /tmp/readiness-log should contain stomp+ssl port 61612
    Then file /tmp/readiness-log should contain Transport is listening on port 61612
