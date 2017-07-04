@openshift
Feature: Openshift common tests

  @eap_6_4 @eap_7_0 @decisionserver @processserver @webserver_tomcat7 @webserver_tomcat8 @amq @datagrid
  Scenario: Check jolokia port is available
    When container is ready
    Then check that port 8778 is open
    Then inspect container
       | path                    | value       |
       | /Config/ExposedPorts    | 8778/tcp    |

  # CLOUD-1017: Option to enable script debugging
  @eap_6_4 @eap_7_0 @kieserver @decisionserver @processserver @webserver_tomcat7 @webserver_tomcat8 @amq @datagrid @datavirt @sso
  Scenario: Check that script debugging (set -x) can be enabled
    When container is started with env
       | variable     | value |
       | SCRIPT_DEBUG | true  |
    Then container log should contain + echo 'Script debugging is enabled, allowing bash commands and their arguments to be printed as they are executed'

  # CLOUD-427: we need to ensure jboss.node.name doesn't go beyond 23 chars
  @eap_6_4 @eap_7_0 @datagrid
  Scenario: Check that long node names are truncated to 23 characters
    When container is started with env
       | variable  | value                      |
       | NODE_NAME | abcdefghijklmnopqrstuvwxyz |
    Then container log should contain jboss.node.name = defghijklmnopqrstuvwxyz

  @eap_6_4 @eap_7_0 @datagrid
  Scenario: Check that node name is used
    When container is started with env
       | variable  | value                      |
       | NODE_NAME | abcdefghijk                |
    Then container log should contain jboss.node.name = abcdefghijk

  # https://issues.jboss.org/browse/CLOUD-912
  @eap_6_4 @eap_7_0 @decisionserver @processserver @webserver_tomcat7 @webserver_tomcat8 @amq @datagrid @datavirt
  Scenario: Check that java binaries are linked properly
    When container is ready
    Then run sh -c 'test -L /usr/bin/java && echo "yes" || echo "no"' in container and immediately check its output for yes
     And run sh -c 'test -L /usr/bin/keytool && echo "yes" || echo "no"' in container and immediately check its output for yes
     And run sh -c 'test -L /usr/bin/rmid && echo "yes" || echo "no"' in container and immediately check its output for yes
     And run sh -c 'test -L /usr/bin/javac && echo "yes" || echo "no"' in container and immediately check its output for yes
     And run sh -c 'test -L /usr/bin/jar && echo "yes" || echo "no"' in container and immediately check its output for yes
     And run sh -c 'test -L /usr/bin/rmic && echo "yes" || echo "no"' in container and immediately check its output for yes
     And run sh -c 'test -L /usr/bin/xjc && echo "yes" || echo "no"' in container and immediately check its output for yes
     And run sh -c 'test -L /usr/bin/wsimport && echo "yes" || echo "no"' in container and immediately check its output for yes

  @kieserver
  Scenario: CLOUD-892, Container should fail if the KIE_SERVER_USER is not created
    When container is started with env
       | variable 	 	| value                      |
       | KIE_SERVER_USER 	| openshift                  |
       | KIE_SERVER_PASSWORD 	| weakpwd                    |
    Then container log should contain Password must have at least 8 characters!
    And container log should contain Failed to create the user openshift
    And container log should contain Exiting...

  @kieserver @decisionserver @processserver
  Scenario: CLOUD-582, logs should not contain clustering warnings for kieserver
    When container is ready
    Then container log should not contain WARNING: Environment variable OPENSHIFT_KUBE_PING_NAMESPACE undefined
    And container log should not contain WARNING: No password defined for JGroups cluster. AUTH protocol will be disabled. Please define JGROUPS_CLUSTER_PASSWORD.
    