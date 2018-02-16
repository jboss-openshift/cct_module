@jboss-amq-6/amq63-openshift
Feature: Openshift AMQ tests

  Scenario: check that container is started correctly
    When container is ready
    Then container log should contain INFO | Apache ActiveMQ 5.11.0.redhat-630329
    And check that port 61616 is open

  Scenario: Check that the labels are correctly set
    Given image is built
    Then the image should contain label com.redhat.component with value jboss-amq-6-amq63-openshift-docker
    And the image should contain label name with value jboss-amq-6/amq63-openshift

  # https://issues.jboss.org/browse/CLOUD-180
  Scenario: Check if image version and release is printed on boot
    When container is ready
    Then container log should contain Running jboss-amq-6/amq63-openshift image, version

  Scenario: Check that the readinessProbe correctly identifies the transport ports
    When container is started with env
       | variable                    | value                    |
       | AMQ_TRANSPORTS              | openwire,mqtt,amqp,stomp |
       | AMQ_KEYSTORE_TRUSTSTORE_DIR | /opt/amq/conf            |
       | AMQ_KEYSTORE                | broker.ks                |
       | AMQ_KEYSTORE_PASSWORD       | password                 |
       | AMQ_TRUSTSTORE              | broker.ts                |
       | AMQ_TRUSTSTORE_PASSWORD     | password                 |
    Then container log should contain INFO | Apache ActiveMQ 5.11.0.redhat-
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

  Scenario: Check IoExceptionHandler was correctly added
    Given XML namespace amq:http://activemq.apache.org/schema/core
    When container is ready
    Then XML file /opt/amq/conf/activemq.xml should have 1 elements on XPath //amq:ioExceptionHandler
