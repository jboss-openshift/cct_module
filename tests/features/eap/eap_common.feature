
Feature: Openshift EAP common tests (EAP and EAP derived images)

  @jboss-eap-6/eap64-openshift @jboss-decisionserver-6 @jboss-processserver-6
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

  # Disabling @redhat-sso-7 for now - mgmt console is not secured yet (CLOUD-625)
  @jboss-eap-7 @jboss-eap-7-tech-preview
  Scenario: Management interface is secured and JAVA_OPTS is modified
    When container is started with env
       | variable                | value             |
       | ADMIN_USERNAME          | admin2            |
       | ADMIN_PASSWORD          | lollerskates11$   |
       | JAVA_OPTS_APPEND        | -Dfoo=bar         |
    Then container log should contain WFLYSRV0025
     And run /opt/eap/bin/jboss-cli.sh -c --error-on-interact --no-local-auth --user=admin2 --password=lollerskates11$ deployment-info in container and immediately check its output contains activemq-rar
     # We expect this command to fail, so make sure the return code is zero, we're interested only in output here
     And run sh -c '/opt/eap/bin/jboss-cli.sh -c --error-on-interact --no-local-auth deployment-info || true' in container and immediately check its output contains Unable to authenticate
     And container log should contain -Dfoo=bar

  # https://issues.jboss.org/browse/CLOUD-587 (security realm for management API)
  # CLOUD-834 (probe rework) uses http interface, which cannot use "local" user,
  #     even when the request originates from localhost, which is how jboss-cli
  #     works.  Note too that http interface is only bound to localhost.
  #     setting to @ignore for now.
  # For EAP 6.4 and derived images
  @ignore @jboss-eap-6/eap64-openshift @jboss-decisionserver-6 @jboss-processserver-6
  Scenario: Management interface is secured (no warning message)
    When container is ready
    # The below should complete faster than 'should not contain' alone
    # this is the key for the "JBoss EAP 6.a.b.GA (AS x.y.z.Final-redhat-4) started" message
    Then container log should contain JBAS015874
     And available container log should not contain No security realm defined for http management service; all access will be unrestricted.

  # https://issues.jboss.org/browse/CLOUD-587 (security realm for management API)
  # CLOUD-834 (probe rework) uses http interface, which cannot use "local" user,
  #     even when the request originates from localhost, which is how jboss-cli
  #     works.  Note too that http interface is only bound to localhost.
  #     setting to @ignore for now.
  # For EAP 7.0 and derived images
  @ignore @jboss-eap-7 @jboss-eap-7-tech-preview
  Scenario: Management interface is secured (no warning message)
    When container is ready
    # The below should complete faster than 'should not contain' alone
    # this is the key for the "JBoss EAP 7.a.b.GA (WildFly Core x.y.z.Final-redhat-1) started" message
    Then container log should contain WFLYSRV0025
     And available container log should not contain No security realm defined for http management service; all access will be unrestricted.

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @jboss-decisionserver-6 @jboss-processserver-6 @redhat-sso-7 @jboss-eap-7-tech-preview
  Scenario: Java 1.8 is installed and set as default one
    When container is ready
    Then run java -version in container and check its output for openjdk version "1.8.0
    Then run javac -version in container and check its output for javac 1.8.0

  # test readinessProbe and livenessProbe (CLOUD-612)
  @jboss-eap-6/eap64-openshift @jboss-eap-7 @jboss-decisionserver-6 @jboss-processserver-6 @jboss-kieserver-6 @jboss-eap-7-tech-preview
  # @redhat-sso-7 excluded at the moment - needs to be investigated
  Scenario: readinessProbe runs successfully
    When container is ready
    Then run /opt/eap/bin/readinessProbe.sh in container once
    Then run /opt/eap/bin/livenessProbe.sh in container once

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview
  # https://issues.jboss.org/browse/CLOUD-204
  Scenario: Check if kube ping protocol is used by default
    When container is ready
    # 2 matches, one for TCP, one for UDP
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='protocol'][@type='openshift.KUBE_PING']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 0 elements on XPath //*[local-name()='protocol'][@type='openshift.DNS_PING']

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview
  # https://issues.jboss.org/browse/CLOUD-1958
  Scenario: Check if kube ping protocol is used when specified
    When container is started with env
      | variable                             | value           |
      | JGROUPS_PING_PROTOCOL                | openshift.KUBE_PING     |
    # 2 matches, one for TCP, one for UDP
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='protocol'][@type='openshift.KUBE_PING']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 0 elements on XPath //*[local-name()='protocol'][@type='openshift.DNS_PING']

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview
  # https://issues.jboss.org/browse/CLOUD-1958
  Scenario: Check if dns ping protocol is used when specified
    When container is started with env
      | variable                             | value           |
      | JGROUPS_PING_PROTOCOL                | openshift.DNS_PING     |
    # 2 matches, one for TCP, one for UDP
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='protocol'][@type='openshift.DNS_PING']
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 0 elements on XPath //*[local-name()='protocol'][@type='openshift.KUBE_PING']

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @jboss-decisionserver-6 @jboss-processserver-6 @jboss-eap-7-tech-preview
  Scenario: Check if jolokia is configured correctly
    When container is ready
    Then container log should contain -javaagent:/opt/jolokia/jolokia.jar=config=/opt/jolokia/etc/jolokia.properties

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
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

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  # https://issues.jboss.org/browse/CLOUD-295
  # https://issues.jboss.org/browse/CLOUD-336
  Scenario: Check if jgroups is secure
    When container is started with env
       | variable                 | value    |
       | JGROUPS_CLUSTER_PASSWORD | asdfasdf |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='protocol'][@type='AUTH']

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups AUTH protocol is disabled when using SYM_ENCRYPT and JGROUPS_CLUSTER_PASSWORD undefined
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_PROTOCOL                     | SYM_ENCRYPT                            |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 0 elements on XPath //*[local-name()='protocol'][@type='AUTH']
     And container log should contain WARN No password defined for JGroups cluster. AUTH protocol will be disabled. Please define JGROUPS_CLUSTER_PASSWORD.

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption does not create invalid configuration when using SYM_ENCRYPT with encrypt secret undefined
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_PROTOCOL                     | SYM_ENCRYPT                            |
    Then container log should contain WARN Detected missing JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted.

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption does not create invalid configuration when using SYM_ENCRYPT with missing name
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_PROTOCOL                     | SYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
    Then container log should contain WARN Detected partial JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted.

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption does not create invalid configuration when using SYM_ENCRYPT with missing password
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_PROTOCOL                     | SYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
    Then container log should contain WARN Detected partial JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted.

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption does not create invalid configuration when using SYM_ENCRYPT with missing keystore dir
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_PROTOCOL                     | SYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
    Then container log should contain WARN Detected partial JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted.

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption does not create invalid configuration when using SYM_ENCRYPT with missing keystore file
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_PROTOCOL                     | SYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
    Then container log should contain WARN Detected partial JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted.

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption requires AUTH protocol to be set when using ASYM_ENCRYPT protocol
    When container is started with env
       | variable                                     | value                                   |
       | JGROUPS_ENCRYPT_PROTOCOL                     | ASYM_ENCRYPT                            |
    Then container log should contain WARN No password defined for JGroups cluster. AUTH protocol is required when using JGroups ASYM_ENCRYPT cluster traffic encryption protocol.

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption issues a warning when using ASYM_ENCRYPT with JGROUPS_ENCRYPT_SECRET defined
    When container is started with env
       | variable                                     | value                                   |
       | JGROUPS_ENCRYPT_PROTOCOL                     | ASYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret              |
    Then container log should contain WARN The specified JGroups SYM_ENCRYPT JCEKS keystore definition will be ignored when using ASYM_ENCRYPT.

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption issues a warning when using ASYM_ENCRYPT with JGROUPS_ENCRYPT_NAME defined
    When container is started with env
       | variable                                     | value                                   |
       | JGROUPS_ENCRYPT_PROTOCOL                     | ASYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                   |
    Then container log should contain WARN The specified JGroups SYM_ENCRYPT JCEKS keystore definition will be ignored when using ASYM_ENCRYPT.

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption issues a warning when using ASYM_ENCRYPT with JGROUPS_ENCRYPT_PASSWORD defined
    When container is started with env
       | variable                                     | value                                   |
       | JGROUPS_ENCRYPT_PROTOCOL                     | ASYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                          |
    Then container log should contain WARN The specified JGroups SYM_ENCRYPT JCEKS keystore definition will be ignored when using ASYM_ENCRYPT.

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption issues a warning when using ASYM_ENCRYPT with JGROUPS_ENCRYPT_KEYSTORE_DIR defined
    When container is started with env
       | variable                                     | value                                   |
       | JGROUPS_ENCRYPT_PROTOCOL                     | ASYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume      |
    Then container log should contain WARN The specified JGroups SYM_ENCRYPT JCEKS keystore definition will be ignored when using ASYM_ENCRYPT.

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview @jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
  Scenario: Check jgroups encryption issues a warning when using ASYM_ENCRYPT with JGROUPS_ENCRYPT_KEYSTORE file defined
    When container is started with env
       | variable                                     | value                                   |
       | JGROUPS_ENCRYPT_PROTOCOL                     | ASYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                            |
    Then container log should contain WARN The specified JGroups SYM_ENCRYPT JCEKS keystore definition will be ignored when using ASYM_ENCRYPT.

  @jboss-eap-6/eap64-openshift @jboss-eap-7 @redhat-sso-7 @jboss-eap-7-tech-preview
  Scenario: No duplicate module jars
    When container is ready
    Then files at /opt/eap/modules/system/layers/openshift/org/jgroups/main should have count of 2

  # Disabling @redhat-sso-7 for now - needs to be adjusted for EAP 7
  @jboss-eap-6/eap64-openshift @jboss-decisionserver-6 @jboss-processserver-6 @jboss-datagrid-6/datagrid65-openshift
  Scenario: Ensure transaction node name is set and we use urandom
    When container is ready
    Then container log should contain JBAS015874:
    And available container log should not contain JBAS010153: Node identifier property is set to the default value. Please make sure it is unique.
    And available container log should contain -Djava.security.egd

  @jboss-eap-7 @jboss-eap-6/eap64-openshift @jboss-eap-7-tech-preview
  Scenario: jboss.modules.system.pkgs is set to defaults when JBOSS_MODULES_SYSTEM_PKGS_APPEND env var is not set
    When container is ready
    Then container log should contain VM Arguments:
     And available container log should contain -Djboss.modules.system.pkgs=org.jboss.logmanager,jdk.nashorn.api,com.sun.crypto.provider

  @jboss-eap-7 @jboss-eap-6/eap64-openshift @jboss-eap-7-tech-preview
  Scenario: jboss.modules.system.pkgs will contain default value and the value of JBOSS_MODULES_SYSTEM_PKGS_APPEND env var, when it is set
    When container is started with env
      | variable                             | value           |
      | JBOSS_MODULES_SYSTEM_PKGS_APPEND     | org.foo.bar     |
    Then container log should contain VM Arguments:
     And available container log should contain -Djboss.modules.system.pkgs=org.jboss.logmanager,jdk.nashorn.api,com.sun.crypto.provider,org.foo.bar

  @jboss-eap-7 @jboss-eap-6/eap64-openshift @redhat-sso-7 @jboss-datavirt-6 @jboss-eap-7-tech-preview
  Scenario: check ownership when started as alternative UID
    When container is started as uid 26458
    Then container log should contain Running
     And run id -u in container and check its output contains 26458
     And all files under /opt/eap are writeable by current user
     And all files under /deployments are writeable by current user

  @jboss-eap-7 @jboss-eap-6/eap64-openshift @redhat-sso-7 @jboss-datavirt-6 @jboss-datagrid-6 @jboss-datagrid-7 @jboss-processserver-6 @jboss-decisionserver-6 @jboss-eap-7-tech-preview
  Scenario: HTTP proxy as java properties (CLOUD-865) and disable web console (CLOUD-1040)
    When container is started with env
      | variable   | value                 |
      | HTTP_PROXY | http://localhost:1337 |
    Then container log should contain Admin console is not enabled
     And container log should contain VM Arguments:
     And available container log should contain http.proxyHost = localhost
     And available container log should contain http.proxyPort = 1337
