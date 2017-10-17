@jboss-eap-6/eap64-openshift
Feature: Openshift EAP jgroups secure
  Scenario: jgroups-encrypt
    Given XML namespaces
     | prefix | url                          |
     | ns     | urn:jboss:domain:jgroups:1.1 |
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_SECRET                       | eap_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //ns:protocol[@type='SYM_ENCRYPT']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value /etc/jgroups-encrypt-secret-volume/keystore.jks on XPath //ns:protocol[@type='SYM_ENCRYPT']/ns:property[@name='keystore_name']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jboss on XPath //ns:protocol[@type='SYM_ENCRYPT']/ns:property[@name='alias']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mykeystorepass on XPath //ns:protocol[@type='SYM_ENCRYPT']/ns:property[@name='store_password']
     # https://issues.jboss.org/browse/CLOUD-1188
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK for udp stack
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.NAKACK on XPath //ns:stack[@name='udp']/ns:protocol[@type='SYM_ENCRYPT']/following-sibling::*[1]/@type
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK for tcp stack
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.NAKACK on XPath //ns:stack[@name='tcp']/ns:protocol[@type='SYM_ENCRYPT']/following-sibling::*[1]/@type

  # CLOUD-336
  Scenario: Check if jgroups is secure
    Given XML namespaces
     | prefix | url                          |
     | ns     | urn:jboss:domain:jgroups:1.1 |
    When container is started with env
       | variable                 | value    |
       | JGROUPS_CLUSTER_PASSWORD | asdfasdf |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //ns:protocol[@type='AUTH']

  Scenario: Check jgroups encryption does not create invalid configuration with missing name
    Given XML namespaces
     | prefix | url                            |
     | ns     | urn:infinispan:server:jgroups:6.1 |
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
    Then container log should contain JBAS015874:
    And available container log should contain WARN Partial JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted.

  Scenario: Check jgroups encryption does not create invalid configuration with missing password
    Given XML namespaces
     | prefix | url                            |
     | ns     | urn:infinispan:server:jgroups:6.1 |
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
    Then container log should contain JBAS015874:
    And available container log should contain WARN Partial JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted.
