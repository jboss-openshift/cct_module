Feature: Openshift EAP common tests (EAP and EAP derived images)

  @jboss-decisionserver-6 @jboss-processserver-6
  Scenario: Management interface is secured and JAVA_OPTS is modified
    When container is started with env
       | variable                    | value             |
       | ADMIN_USERNAME          | admin2            |
       | ADMIN_PASSWORD          | lollerskates11$   |
       | JAVA_OPTS_APPEND            | -Dfoo=bar         |
    Then container log should contain JBAS015874
     And run /opt/eap/bin/jboss-cli.sh -c --no-local-auth --user=admin2 --password=lollerskates11$ deployment-info in container and immediately check its output contains activemq-rar
     # We expect this command to fail, so make sure the return code is zero, we're interested only in output here
     And run sh -c '/opt/eap/bin/jboss-cli.sh -c --no-local-auth --user=wronguser --password=wrongpass deployment-info || true' in container and immediately check its output contains Authentication failed
     And container log should contain -Dfoo=bar

  @jboss-decisionserver-6 @jboss-processserver-6 @redhat-sso-7 
  Scenario: Java 1.8 is installed and set as default one
    When container is ready
    Then run java -version in container and check its output for openjdk version "1.8.0
    Then run javac -version in container and check its output for javac 1.8.0

  # test readinessProbe and livenessProbe (CLOUD-612)
  @jboss-decisionserver-6 @jboss-processserver-6 @jboss-kieserver-6 
  # @redhat-sso-7 excluded at the moment - needs to be investigated
  Scenario: readinessProbe runs successfully
    When container is ready
    Then run /opt/eap/bin/readinessProbe.sh in container once
    Then run /opt/eap/bin/livenessProbe.sh in container once

  @redhat-sso-7 
  # https://issues.jboss.org/browse/CLOUD-204
  Scenario: Check if kube ping protocol is used by default
    When container is ready
    # 2 matches, one for TCP, one for UDP
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='protocol'][@type='openshift.KUBE_PING']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 0 elements on XPath //*[local-name()='protocol'][@type='openshift.DNS_PING']

  @redhat-sso-7 
  # https://issues.jboss.org/browse/CLOUD-1958
  Scenario: Check if kube ping protocol is used when specified
    When container is started with env
      | variable                             | value           |
      | JGROUPS_PING_PROTOCOL                | openshift.KUBE_PING     |
    # 2 matches, one for TCP, one for UDP
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='protocol'][@type='openshift.KUBE_PING']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 0 elements on XPath //*[local-name()='protocol'][@type='openshift.DNS_PING']

  @redhat-sso-7 
  # https://issues.jboss.org/browse/CLOUD-1958
  Scenario: Check if dns ping protocol is used when specified
    When container is started with env
      | variable                             | value           |
      | JGROUPS_PING_PROTOCOL                | openshift.DNS_PING     |
    # 2 matches, one for TCP, one for UDP
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='protocol'][@type='openshift.DNS_PING']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 0 elements on XPath //*[local-name()='protocol'][@type='openshift.KUBE_PING']

  @jboss-decisionserver-6 @jboss-processserver-6 
  Scenario: Check if jolokia is configured correctly
    When container is ready
    Then container log should contain -javaagent:/usr/share/java/jolokia-jvm-agent/jolokia-jvm.jar=config=/opt/jboss/container/jolokia/etc/jolokia.properties

  @redhat-sso-7/sso72-openshift @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: jgroups-encrypt
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
     # https://issues.jboss.org/browse/CLOUD-1192
     # https://issues.jboss.org/browse/CLOUD-1196
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK for udp stack
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.NAKACK on XPath //ns:stack[@name='udp']/ns:protocol[@type='SYM_ENCRYPT']/following-sibling::*[1]/@type
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK for tcp stack
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.NAKACK on XPath //ns:stack[@name='tcp']/ns:protocol[@type='SYM_ENCRYPT']/following-sibling::*[1]/@type

  @redhat-sso-7/sso72-openshift @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  # https://issues.jboss.org/browse/CLOUD-295
  # https://issues.jboss.org/browse/CLOUD-336
  Scenario: Check if jgroups is secure
    When container is started with env
       | variable                 | value    |
       | JGROUPS_CLUSTER_PASSWORD | asdfasdf |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='protocol'][@type='AUTH']

  @redhat-sso-7 @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups AUTH protocol is disabled when using SYM_ENCRYPT and JGROUPS_CLUSTER_PASSWORD undefined
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_PROTOCOL                     | SYM_ENCRYPT                            |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 0 elements on XPath //*[local-name()='protocol'][@type='AUTH']
     And container log should contain WARN No password defined for JGroups cluster. AUTH protocol will be disabled. Please define JGROUPS_CLUSTER_PASSWORD.

  @redhat-sso-7  @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption does not create invalid configuration when using SYM_ENCRYPT with encrypt secret undefined
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_PROTOCOL                     | SYM_ENCRYPT                            |
    Then container log should contain WARN Detected missing JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted.

  @redhat-sso-7  @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption does not create invalid configuration when using SYM_ENCRYPT with missing name
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_PROTOCOL                     | SYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
    Then container log should contain WARN Detected partial JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted.

  @redhat-sso-7  @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption does not create invalid configuration when using SYM_ENCRYPT with missing password
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_PROTOCOL                     | SYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
    Then container log should contain WARN Detected partial JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted.

  @redhat-sso-7  @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption does not create invalid configuration when using SYM_ENCRYPT with missing keystore dir
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_PROTOCOL                     | SYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
    Then container log should contain WARN Detected partial JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted.

  @redhat-sso-7  @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption does not create invalid configuration when using SYM_ENCRYPT with missing keystore file
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_PROTOCOL                     | SYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
    Then container log should contain WARN Detected partial JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted.

  @redhat-sso-7/sso72-openshift @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption requires AUTH protocol to be set when using ASYM_ENCRYPT protocol
    When container is started with env
       | variable                                     | value                                   |
       | JGROUPS_ENCRYPT_PROTOCOL                     | ASYM_ENCRYPT                            |
    Then container log should contain WARN No password defined for JGroups cluster. AUTH protocol is required when using JGroups ASYM_ENCRYPT cluster traffic encryption protocol.

  @redhat-sso-7/sso72-openshift @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption issues a warning when using ASYM_ENCRYPT with JGROUPS_ENCRYPT_SECRET defined
    When container is started with env
       | variable                                     | value                                   |
       | JGROUPS_ENCRYPT_PROTOCOL                     | ASYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret              |
    Then container log should contain WARN The specified JGroups SYM_ENCRYPT JCEKS keystore definition will be ignored when using ASYM_ENCRYPT.

  @redhat-sso-7/sso72-openshift @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption issues a warning when using ASYM_ENCRYPT with JGROUPS_ENCRYPT_NAME defined
    When container is started with env
       | variable                                     | value                                   |
       | JGROUPS_ENCRYPT_PROTOCOL                     | ASYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                   |
    Then container log should contain WARN The specified JGroups SYM_ENCRYPT JCEKS keystore definition will be ignored when using ASYM_ENCRYPT.

  @redhat-sso-7/sso72-openshift @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption issues a warning when using ASYM_ENCRYPT with JGROUPS_ENCRYPT_PASSWORD defined
    When container is started with env
       | variable                                     | value                                   |
       | JGROUPS_ENCRYPT_PROTOCOL                     | ASYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                          |
    Then container log should contain WARN The specified JGroups SYM_ENCRYPT JCEKS keystore definition will be ignored when using ASYM_ENCRYPT.

  @redhat-sso-7/sso72-openshift @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption issues a warning when using ASYM_ENCRYPT with JGROUPS_ENCRYPT_KEYSTORE_DIR defined
    When container is started with env
       | variable                                     | value                                   |
       | JGROUPS_ENCRYPT_PROTOCOL                     | ASYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume      |
    Then container log should contain WARN The specified JGroups SYM_ENCRYPT JCEKS keystore definition will be ignored when using ASYM_ENCRYPT.

  @redhat-sso-7/sso72-openshift @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption issues a warning when using ASYM_ENCRYPT with JGROUPS_ENCRYPT_KEYSTORE file defined
    When container is started with env
       | variable                                     | value                                   |
       | JGROUPS_ENCRYPT_PROTOCOL                     | ASYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                            |
    Then container log should contain WARN The specified JGroups SYM_ENCRYPT JCEKS keystore definition will be ignored when using ASYM_ENCRYPT.

  @redhat-sso-7 
  Scenario: No duplicate module jars
    When container is ready
    Then files at /opt/eap/modules/system/layers/openshift/org/jgroups/main should have count of 2

  # Disabling @redhat-sso-7 for now - needs to be adjusted for EAP 7
  @jboss-decisionserver-6 @jboss-processserver-6
  Scenario: Ensure transaction node name is set and we use urandom
    When container is ready
    Then container log should contain JBAS015874:
    And available container log should not contain JBAS010153: Node identifier property is set to the default value. Please make sure it is unique.
    And available container log should contain -Djava.security.egd

  @redhat-sso-7 @jboss-datavirt-6 
  Scenario: check ownership when started as alternative UID
    When container is started as uid 26458
    Then container log should contain Running
     And run id -u in container and check its output contains 26458
     And all files under /opt/eap are writeable by current user
     And all files under /deployments are writeable by current user

  @redhat-sso-7 @jboss-datavirt-6 @jboss-processserver-6 @jboss-decisionserver-6 
  Scenario: HTTP proxy as java properties (CLOUD-865) and disable web console (CLOUD-1040)
    When container is started with env
      | variable   | value                 |
      | HTTP_PROXY | http://localhost:1337 |
    Then container log should contain Admin console is not enabled
     And container log should contain VM Arguments:
     And available container log should contain http.proxyHost = localhost
     And available container log should contain http.proxyPort = 1337

