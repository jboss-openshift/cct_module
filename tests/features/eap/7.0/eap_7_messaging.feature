@openshift @eap_7_0
Feature: Openshift EAP Messaging Tests

  Scenario: deploys the helloworld-mdb example, then checks if it's deployed properly.
    Given s2i build https://github.com/jboss-developer/jboss-eap-quickstarts from helloworld-mdb using 7.0.x
    Then container log should contain Bound messaging object to jndi name java:/queue/HELLOWORLDMDBQueue
    Then container log should contain Bound messaging object to jndi name java:/topic/HELLOWORLDMDBTopic
    Then container log should contain Started message driven bean 'HelloWorldQueueMDB' with 'activemq-ra.rar' resource adapter
    Then container log should contain Started message driven bean 'HelloWorldQTopicMDB' with 'activemq-ra.rar' resource adapter
