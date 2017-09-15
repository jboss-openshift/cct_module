@jboss-eap-7/eap70-openshift @jboss-eap-7/eap71-openshift
Feature: Openshift EAP7 Messaging Tests

  Scenario: Check that queues are generated properly for A-MQ resource adapter
    Given XML namespace ra:urn:jboss:domain:resource-adapters:4.0
    When container is started with env
       | variable                    | value                          |
       | MQ_SERVICE_PREFIX_MAPPING   | test-amq=MQ                    |
       | TEST_AMQ_TCP_SERVICE_HOST   | 10.1.1.1                       |
       | TEST_AMQ_TCP_SERVICE_PORT   | 61616                          |
       | MQ_PROTOCOL                 | tcp                            |
       | MQ_JNDI                     | java:/jms/AMQConnectionFactory |
       | MQ_USERNAME                 | openshift                      |
       | MQ_PASSWORD                 | password                       |
       | MQ_QUEUES                   | one,two                        |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.apache.activemq.command.ActiveMQQueue on XPath //ra:resource-adapter[@id="activemq-rar.rar"]//ra:admin-object[@jndi-name="java:/queue/one"]/@class-name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.apache.activemq.command.ActiveMQQueue on XPath //ra:resource-adapter[@id="activemq-rar.rar"]//ra:admin-object[@jndi-name="java:/queue/two"]/@class-name

  Scenario: Check that topics are generated properly for A-MQ resource adapter
    Given XML namespace ra:urn:jboss:domain:resource-adapters:4.0
    When container is started with env
       | variable                    | value                          |
       | MQ_SERVICE_PREFIX_MAPPING   | test-amq=MQ                    |
       | TEST_AMQ_TCP_SERVICE_HOST   | 10.1.1.1                       |
       | TEST_AMQ_TCP_SERVICE_PORT   | 61616                          |
       | MQ_PROTOCOL                 | tcp                            |
       | MQ_JNDI                     | java:/jms/AMQConnectionFactory |
       | MQ_USERNAME                 | openshift                      |
       | MQ_PASSWORD                 | password                       |
       | MQ_TOPICS                   | alpha,beta                     |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.apache.activemq.command.ActiveMQTopic on XPath //ra:resource-adapter[@id="activemq-rar.rar"]//ra:admin-object[@jndi-name="java:/topic/alpha"]/@class-name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.apache.activemq.command.ActiveMQTopic on XPath //ra:resource-adapter[@id="activemq-rar.rar"]//ra:admin-object[@jndi-name="java:/topic/beta"]/@class-name
