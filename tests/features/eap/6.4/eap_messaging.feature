@openshift @eap_6_4
Feature: Openshift EAP Messaging Tests

  Scenario: Check that RA generated for AMQ
   Given define variable
       | variable    | value                                                      |
       | CONFIG_FILE | /opt/eap/standalone/configuration/standalone-openshift.xml |
    When container is started with env
       | variable                     | value             |
       | MQ_SERVICE_PREFIX_MAPPING    | test-amq=TEST_AMQ |
       | TEST_AMQ_QUEUES              | in.1,out-1,barq   |
       | TEST_AMQ_TOPICS              | t.1,t-2.foo,bart  |
       | TEST_AMQ_USERNAME            | marek             |
       | TEST_AMQ_PASSWORD            | hardtoguess       |
       | TEST_AMQ_PROTOCOL            | tcp               |
       | TEST_AMQ_TCP_SERVICE_HOST    | 10.1.1.1          |
       | TEST_AMQ_TCP_SERVICE_PORT    | 61616             |
       | TEST_AMQ_QUEUE_IN_1_JNDI     | java:/queue/in    |
       | TEST_AMQ_TOPIC_T_2_FOO_JNDI  | java:/topic/foo   |
       | TEST_AMQ_QUEUE_BARQ_PHYSICAL | MyBarq            |
       | TEST_AMQ_TOPIC_BART_PHYSICAL | MyBart            |
    Then container log should contain Bound JCA ConnectionFactory [java:/test-amq/ConnectionFactory]
    And container log should contain Bound JCA AdminObject [java:/queue/in]
    And container log should contain Bound JCA AdminObject [java:/queue/out-1]
    And container log should contain Bound JCA AdminObject [java:/topic/foo]
    And container log should contain Bound JCA AdminObject [java:/topic/t.1]
    And file $CONFIG_FILE should contain jndi-name="java:/test-amq/ConnectionFactory"
    And file $CONFIG_FILE should contain jndi-name="java:/queue/in"
    And file $CONFIG_FILE should contain jndi-name="java:/queue/out-1"
    And file $CONFIG_FILE should contain jndi-name="java:/topic/foo"
    And file $CONFIG_FILE should contain jndi-name="java:/topic/t.1"
    And file $CONFIG_FILE should contain pool-name="test-amq-ConnectionFactory"
    And file $CONFIG_FILE should contain pool-name="queue/in.1"
    And file $CONFIG_FILE should contain pool-name="queue/out-1"
    And file $CONFIG_FILE should contain pool-name="topic/t.1"
    And file $CONFIG_FILE should contain pool-name="topic/t-2.foo"
    And file $CONFIG_FILE should contain pool-name="MyBarq"
    And file $CONFIG_FILE should contain pool-name="MyBart"
    And file $CONFIG_FILE should contain <archive>activemq-rar.rar</archive>
    And file $CONFIG_FILE should contain "ServerUrl">tcp://10.1.1.1:61616?jms.rmIdFromConnectionId=true<
    And file $CONFIG_FILE should contain "UserName">marek<
    And file $CONFIG_FILE should contain "Password">hardtoguess<
    And file $CONFIG_FILE should contain <user-name>marek</user-name>
    And file $CONFIG_FILE should contain <password>hardtoguess</password>
    And file $CONFIG_FILE should contain "PhysicalName">queue/in.1<
    And file $CONFIG_FILE should contain "PhysicalName">queue/out-1<
    And file $CONFIG_FILE should contain "PhysicalName">topic/t.1<
    And file $CONFIG_FILE should contain "PhysicalName">topic/t-2.foo<
    And file $CONFIG_FILE should contain "PhysicalName">MyBarq<
    And file $CONFIG_FILE should contain "PhysicalName">MyBart<

  # https://issues.jboss.org/browse/CLOUD-329
  Scenario: Check backwards-compatible RA generated destination names for AMQ
    When container is started with env
       | variable                               | value             |
       | MQ_SIMPLE_DEFAULT_PHYSICAL_DESTINATION | true              |
       | MQ_SERVICE_PREFIX_MAPPING              | test-amq=TEST_AMQ |
       | TEST_AMQ_QUEUES                        | in.1,out-1,barq   |
       | TEST_AMQ_TOPICS                        | t.1,t-2.foo,bart  |
       | TEST_AMQ_USERNAME                      | marek             |
       | TEST_AMQ_PASSWORD                      | hardtoguess       |
       | TEST_AMQ_PROTOCOL                      | tcp               |
       | TEST_AMQ_TCP_SERVICE_HOST              | 10.1.1.1          |
       | TEST_AMQ_TCP_SERVICE_PORT              | 61616             |
       | TEST_AMQ_QUEUE_BARQ_PHYSICAL           | MyBarq            |
       | TEST_AMQ_TOPIC_BART_PHYSICAL           | MyBart            |
    Then file /opt/eap/standalone/configuration/standalone-openshift.xml should contain "PhysicalName">in.1<
    And file /opt/eap/standalone/configuration/standalone-openshift.xml should contain "PhysicalName">out-1<
    And file /opt/eap/standalone/configuration/standalone-openshift.xml should contain "PhysicalName">t.1<
    And file /opt/eap/standalone/configuration/standalone-openshift.xml should contain "PhysicalName">t-2.foo<
    And file /opt/eap/standalone/configuration/standalone-openshift.xml should contain "PhysicalName">MyBarq<
    And file /opt/eap/standalone/configuration/standalone-openshift.xml should contain "PhysicalName">MyBart<

  Scenario: Check that queues are generated properly for A-MQ resource adapter
    Given XML namespace ra:urn:jboss:domain:resource-adapters:1.1
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
    Given XML namespace ra:urn:jboss:domain:resource-adapters:1.1
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
