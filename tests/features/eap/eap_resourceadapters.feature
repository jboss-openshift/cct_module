@jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7/sso71-openshift @jboss-eap-7-tech-preview
Feature: EAP Openshift resource adapters

  Scenario: Test resource adapter extension
    When container is started with env
       | variable                         | value                                                        |
       | RESOURCE_ADAPTERS                | TEST_1                                                       |
       | TEST_1_ID                        | fileQS                                                       |
       | TEST_1_MODULE_SLOT               | main                                                         |
       | TEST_1_MODULE_ID                 | org.jboss.teiid.resource-adapter.file                        |
       | TEST_1_CONNECTION_CLASS          | org.teiid.resource.adapter.file.FileManagedConnectionFactory |
       | TEST_1_CONNECTION_JNDI           | java:/marketdata-file                                        |
       | TEST_1_PROPERTY_ParentDirectory  | /home/jboss/source/injected/injected-files/data              |
       | TEST_1_PROPERTY_AllowParentPaths | true                                                         |
       | TEST_1_POOL_MIN_SIZE             | 1                                                            |
       | TEST_1_POOL_MAX_SIZE             | 5                                                            |
       | TEST_1_POOL_PREFILL              | false                                                        |
       | TEST_1_POOL_FLUSH_STRATEGY       | EntirePool                                                   |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value fileQS on XPath //*[local-name()='resource-adapter']/@id
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.jboss.teiid.resource-adapter.file on XPath //*[local-name()='resource-adapter']/*[local-name()='module']/@id
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.teiid.resource.adapter.file.FileManagedConnectionFactory on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/@class-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /home/jboss/source/injected/injected-files/data on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='config-property'][@name="ParentDirectory"]
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 1 on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='pool']/*[local-name()='min-pool-size']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 5 on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='pool']/*[local-name()='max-pool-size']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='pool']/*[local-name()='prefill']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value EntirePool on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='pool']/*[local-name()='flush-strategy']

  Scenario: Test warning no module slot is provided
    When container is started with env
       | variable                       | value                                                        |
       | RESOURCE_ADAPTERS              | TEST                                                         |
       | TEST_CONNECTION_CLASS          | org.teiid.resource.adapter.file.FileManagedConnectionFactory |
       | TEST_CONNECTION_JNDI           | java:/marketdata-file                                        |
       | TEST_PROPERTY_ParentDirectory  | /home/jboss/source/injected/injected-files/data              |
       | TEST_PROPERTY_AllowParentPaths | true                                                         |
    Then container log should contain WARN TEST_ID is missing from resource adapter configuration, defaulting to TEST
    And container log should contain WARN TEST_MODULE_SLOT is missing from resource adapter configuration, defaulting to main
    And container log should contain WARN TEST_MODULE_ID and TEST_ARCHIVE are missing from resource adapter configuration. One is required. Resource adapter will not be configured

   Scenario: Test AMQ resource adapter extension
    When container is started with env
       | variable                                | value                                                        |
       | MQ_SERVICE_PREFIX_MAPPING               | eap-app-amq=DUMMY                                            |
       | DUMMY_JNDI                              | java:/ConnectionFactory                                      |
       | RESOURCE_ADAPTERS                       | TEST_1                                                       |
       | TEST_1_ID                               | activemq-rar.rar                                             |
       | TEST_1_ARCHIVE                          | activemq-rar.rar                                             |
       | TEST_1_TRANSACTION_SUPPORT              | XATransaction                                                |
       | TEST_1_CONNECTION_CLASS                 | org.apache.activemq.ra.ActiveMQManagedConnectionFactory      |
       | TEST_1_CONNECTION_JNDI                  | java:/ConnectionFactory                                      |
       | TEST_1_PROPERTY_ServerUrl               | tcp://1.2.3.4:61616?jms.rmIdFromConnectionId=true            |
       | TEST_1_PROPERTY_UserName                | tombrady                                                     |
       | TEST_1_PROPERTY_Password                | P@ssword1                                                    |
       | TEST_1_POOL_XA                          | true                                                         |
       | TEST_1_POOL_MIN_SIZE                    | 1                                                            |
       | TEST_1_POOL_MAX_SIZE                    | 5                                                            |
       | TEST_1_POOL_PREFILL                     | false                                                        |
       | TEST_1_POOL_IS_SAME_RM_OVERRIDE         | false                                                        |
       | TEST_1_ADMIN_OBJECTS                    | queue,topic                                                  |
       | TEST_1_ADMIN_OBJECT_queue_CLASS_NAME    | org.apache.activemq.command.ActiveMQQueue                    |
       | TEST_1_ADMIN_OBJECT_queue_PHYSICAL_NAME | queue/HELLOWORLDMDBQueue                                     |
       | TEST_1_ADMIN_OBJECT_topic_CLASS_NAME    | org.apache.activemq.command.ActiveMQTopic                    |
       | TEST_1_ADMIN_OBJECT_topic_PHYSICAL_NAME | queue/HELLOWORLDMDBTopic                                     |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value activemq-rar.rar on XPath //*[local-name()='resource-adapter']/@id
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value activemq-rar.rar on XPath //*[local-name()='resource-adapter']/*[local-name()='archive']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.apache.activemq.ra.ActiveMQManagedConnectionFactory on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/@class-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/ConnectionFactory on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/@jndi-name
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 1 on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='xa-pool']/*[local-name()='min-pool-size']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 5 on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='xa-pool']/*[local-name()='max-pool-size']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='xa-pool']/*[local-name()='prefill']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='xa-pool']/*[local-name()='is-same-rm-override']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.apache.activemq.command.ActiveMQTopic on XPath //*[local-name()='resource-adapter']/*[local-name()='admin-objects']/*[local-name()='admin-object']/@class-name

  @jboss-eap-7
  Scenario:   Scenario: CLOUD-2455, test tracking configuration
    When container is started with env
      | variable                                | value                                                        |
      | MQ_SERVICE_PREFIX_MAPPING               | eap-app-amq=DUMMY                                            |
      | DUMMY_JNDI                              | java:/ConnectionFactory                                      |
      | RESOURCE_ADAPTERS                       | TEST_1                                                       |
      | TEST_1_ID                               | activemq-rar.rar                                             |
      | TEST_1_ARCHIVE                          | activemq-rar.rar                                             |
      | TEST_1_TRANSACTION_SUPPORT              | XATransaction                                                |
      | TEST_1_CONNECTION_CLASS                 | org.apache.activemq.ra.ActiveMQManagedConnectionFactory      |
      | TEST_1_CONNECTION_JNDI                  | java:/ConnectionFactory                                      |
      | TEST_1_PROPERTY_ServerUrl               | tcp://1.2.3.4:61616?jms.rmIdFromConnectionId=true            |
      | TEST_1_PROPERTY_UserName                | tombrady                                                     |
      | TEST_1_PROPERTY_Password                | P@ssword1                                                    |
      | TEST_1_POOL_XA                          | true                                                         |
      | TEST_1_POOL_MIN_SIZE                    | 1                                                            |
      | TEST_1_POOL_MAX_SIZE                    | 5                                                            |
      | TEST_1_POOL_PREFILL                     | false                                                        |
      | TEST_1_POOL_IS_SAME_RM_OVERRIDE         | false                                                        |
      | TEST_1_ADMIN_OBJECTS                    | queue,topic                                                  |
      | TEST_1_ADMIN_OBJECT_queue_CLASS_NAME    | org.apache.activemq.command.ActiveMQQueue                    |
      | TEST_1_ADMIN_OBJECT_queue_PHYSICAL_NAME | queue/HELLOWORLDMDBQueue                                     |
      | TEST_1_ADMIN_OBJECT_topic_CLASS_NAME    | org.apache.activemq.command.ActiveMQTopic                    |
      | TEST_1_ADMIN_OBJECT_topic_PHYSICAL_NAME | queue/HELLOWORLDMDBTopic                                     |
      | TEST_1_TRACKING                         | false                                                        |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value activemq-rar.rar on XPath //*[local-name()='resource-adapter']/@id
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value activemq-rar.rar on XPath //*[local-name()='resource-adapter']/*[local-name()='archive']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.apache.activemq.ra.ActiveMQManagedConnectionFactory on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/@class-name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/ConnectionFactory on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/@jndi-name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 1 on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='xa-pool']/*[local-name()='min-pool-size']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 5 on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='xa-pool']/*[local-name()='max-pool-size']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='xa-pool']/*[local-name()='prefill']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='xa-pool']/*[local-name()='is-same-rm-override']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.apache.activemq.command.ActiveMQTopic on XPath //*[local-name()='resource-adapter']/*[local-name()='admin-objects']/*[local-name()='admin-object']/@class-name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/@tracking

  @jboss-eap-7
  Scenario: CLOUD-2455, test tracking configuration
    When container is started with env
      | variable                         | value                                                        |
      | RESOURCE_ADAPTERS                | TEST_1                                                       |
      | TEST_1_ID                        | fileQS                                                       |
      | TEST_1_MODULE_SLOT               | main                                                         |
      | TEST_1_MODULE_ID                 | org.jboss.teiid.resource-adapter.file                        |
      | TEST_1_CONNECTION_CLASS          | org.teiid.resource.adapter.file.FileManagedConnectionFactory |
      | TEST_1_CONNECTION_JNDI           | java:/marketdata-file                                        |
      | TEST_1_PROPERTY_ParentDirectory  | /home/jboss/source/injected/injected-files/data              |
      | TEST_1_PROPERTY_AllowParentPaths | true                                                         |
      | TEST_1_POOL_MIN_SIZE             | 1                                                            |
      | TEST_1_POOL_MAX_SIZE             | 5                                                            |
      | TEST_1_POOL_PREFILL              | false                                                        |
      | TEST_1_POOL_FLUSH_STRATEGY       | EntirePool                                                   |
      | TEST_1_TRACKING                  | false                                                        |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value fileQS on XPath //*[local-name()='resource-adapter']/@id
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.jboss.teiid.resource-adapter.file on XPath //*[local-name()='resource-adapter']/*[local-name()='module']/@id
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.teiid.resource.adapter.file.FileManagedConnectionFactory on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/@class-name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /home/jboss/source/injected/injected-files/data on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='config-property'][@name="ParentDirectory"]
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 1 on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='pool']/*[local-name()='min-pool-size']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 5 on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='pool']/*[local-name()='max-pool-size']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='pool']/*[local-name()='prefill']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value EntirePool on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='pool']/*[local-name()='flush-strategy']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/@tracking

  @jboss-eap-7
  Scenario: CLOUD-2455, test tracking configuration
    When container is started with env
      | variable                      | value               |
      | MQ_SERVICE_PREFIX_MAPPING     | eap-app-amq=MQ      |
      | MQ_JNDI                       | java:jboss/mq/jndi  |
      | MQ_USERNAME                   | testUser            |
      | MQ_PASSWORD                   | testPass            |
      | MQ_PROTOCOL                   | tcp                 |
      | MQ_QUEUES                     | foo                 |
      | MQ_TOPICS                     | bar                 |
      | MQ_SERIALIZABLE_PACKAGES      | foo.bar             |
      | EAP_APP_AMQ_TCP_SERVICE_HOST  | 10.10.10.10         |
      | EAP_APP_AMQ_TCP_SERVICE_PORT  | 8000                |
      | MQ_TRACKING                   | false               |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value activemq-rar.rar on XPath //*[local-name()='resource-adapter']/@id
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value activemq-rar.rar on XPath //*[local-name()='resource-adapter']/*[local-name()='archive']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value XATransaction on XPath //*[local-name()='resource-adapter']/*[local-name()='transaction-support']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value testUser on XPath //*[local-name()='resource-adapter']/*[local-name()='config-property'][@name="UserName"]
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value testPass on XPath //*[local-name()='resource-adapter']/*[local-name()='config-property'][@name="Password"]
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value tcp://10.10.10.10:8000?jms.rmIdFromConnectionId=true on XPath //*[local-name()='resource-adapter']/*[local-name()='config-property'][@name="ServerUrl"]
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/@tracking
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.apache.activemq.ra.ActiveMQManagedConnectionFactory on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/@class-name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:jboss/mq/jndi on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/@jndi-name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value true on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/@enabled
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value eap-app-amq-ConnectionFactory on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/@pool-name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 1 on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='xa-pool']/*[local-name()='min-pool-size']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value 20 on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='xa-pool']/*[local-name()='max-pool-size']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value testUser on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='recovery']/*[local-name()='recover-credential']/*[local-name()='user-name']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value testPass on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='recovery']/*[local-name()='recover-credential']/*[local-name()='password']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.apache.activemq.command.ActiveMQQueue on XPath //*[local-name()='resource-adapter']/*[local-name()='admin-objects']/*[local-name()='admin-object']/@class-name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/queue/foo on XPath //*[local-name()='resource-adapter']/*[local-name()='admin-objects']/*[local-name()='admin-object']/@jndi-name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value true on XPath //*[local-name()='resource-adapter']/*[local-name()='admin-objects']/*[local-name()='admin-object']/@use-java-context
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value queue/foo on XPath //*[local-name()='resource-adapter']/*[local-name()='admin-objects']/*[local-name()='admin-object']/@pool-name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value queue/foo on XPath //*[local-name()='resource-adapter']/*[local-name()='admin-objects']/*[local-name()='admin-object']/*[local-name()='config-property'][@name="PhysicalName"]
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.apache.activemq.command.ActiveMQTopic on XPath //*[local-name()='resource-adapter']/*[local-name()='admin-objects']/*[local-name()='admin-object']/@class-name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/topic/bar on XPath //*[local-name()='resource-adapter']/*[local-name()='admin-objects']/*[local-name()='admin-object']/@jndi-name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value topic/bar on XPath //*[local-name()='resource-adapter']/*[local-name()='admin-objects']/*[local-name()='admin-object']/@pool-name
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value topic/bar on XPath //*[local-name()='resource-adapter']/*[local-name()='admin-objects']/*[local-name()='admin-object']/*[local-name()='config-property'][@name="PhysicalName"]
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='xa-pool']/*[local-name()='prefill']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value false on XPath //*[local-name()='resource-adapter']/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/@tracking