@jboss-eap-7/eap70-openshift @jboss-eap-7/eap71-openshift
Feature: Openshift EAP7.x Messaging Tests

  Scenario: Check default destinations
    When container is started with env
       | variable                     | value                    |
       | MQ_QUEUES                    | testqueue1,testqueue2    |
       | MQ_TOPICS                    | testtopic1,testtopic2    |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 4 elements on XPath //*[local-name()='jms-queue']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value testqueue1 on XPath //*[local-name()='jms-queue']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /queue/testqueue1 on XPath //*[local-name()='jms-queue'][@name='testqueue1']/@entries
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value testqueue1 on XPath //*[local-name()='jms-queue']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /queue/testqueue2 on XPath //*[local-name()='jms-queue'][@name='testqueue2']/@entries
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='jms-topic']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value testtopic1 on XPath //*[local-name()='jms-topic']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value testtopic2 on XPath //*[local-name()='jms-topic']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /topic/testtopic1 on XPath //*[local-name()='jms-topic'][@name='testtopic1']/@entries
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /topic/testtopic2 on XPath //*[local-name()='jms-topic'][@name='testtopic2']/@entries

  Scenario: Check custom jndi destinations
    When container is started with env
       | variable                     | value                                                                                |
       | MQ_QUEUES                    | testqueue1,testqueue2                                                                |
       | MQ_TOPICS                    | testtopic1,testtopic2                                                                |
       | MQ_QUEUE_JNDI_BINDINGS       | java:jboss/exported/jms/queue/testqueue1,java:jboss/exported/jms/queue/testqueue2    |
       | MQ_TOPIC_JNDI_BINDINGS       | java:jboss/exported/jms/topic/testtopic1,java:jboss/exported/jms/topic/testtopic2    |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 4 elements on XPath //*[local-name()='jms-queue']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value testqueue1 on XPath //*[local-name()='jms-queue']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/exported/jms/queue/testqueue1 on XPath //*[local-name()='jms-queue'][@name='testqueue1']/@entries
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value testqueue1 on XPath //*[local-name()='jms-queue']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/exported/jms/queue/testqueue2 on XPath //*[local-name()='jms-queue'][@name='testqueue2']/@entries
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='jms-topic']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value testtopic1 on XPath //*[local-name()='jms-topic']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value testtopic2 on XPath //*[local-name()='jms-topic']/@name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/exported/jms/topic/testtopic1 on XPath //*[local-name()='jms-topic'][@name='testtopic1']/@entries
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/exported/jms/topic/testtopic2 on XPath //*[local-name()='jms-topic'][@name='testtopic2']/@entries

