@openshift @webserver_tomcat7 @webserver_tomcat8
Feature: Openshift tomcat basic tests

  Scenario: Ensure that the default ROOT web app is NOT running
    When container is started with env
         | variable             | value             |
         | CATALINA_OPTS_APPEND | -Dfoo=test_for_me |
    Then check that page is not served
         | property        | value                                                                          |
         | port            | 8080                                                                           | 
         | expected_phrase | If you're seeing this, you've successfully installed Tomcat. Congratulations   |
    And container log should contain Command line argument: -javaagent:/opt/jolokia/jolokia.jar=config=/opt/jolokia/etc/jolokia.properties
    And container log should contain Command line argument: -Dfoo=test_for_me

  Scenario: Ensure that the manager webapp is secure
    When container is ready
      Then check that page is served
         | property             | value       |
         | port                 | 8080        |
         | expected_status_code | 403         |
         | path                 | /manager    |

  Scenario: Java 1.8 is installed and set as default one
    When container is ready
    Then run java -version in container and check its output for openjdk version "1.8.0
    Then run javac -version in container and check its output for javac 1.8.0

  Scenario: Check that the /deployments directory is symlinked properly
     When container is ready
     Then file /deployments should exist and be a directory
      And file /deployments/docs should not exist
      And file /deployments/host-manager should not exist
      And file /deployments/manager should exist and be a directory
      And file /opt/webserver/webapps should exist and be a symlink

  # CLOUD-193
  Scenario: Check for dynamic resource allocation
    When container is started with args
      | arg                    | value             |
      | mem_limit              | 1073741824        |
    Then container log should contain -Xms512m
    And container log should contain -Xmx512m
 
  Scenario: check ownership when started as alternative UID
    When container is started as uid 26458
    Then run id -u in container and check its output contains 26458
     And all files under /opt/webserver are writeable by current user
     And all files under /deployments are writeable by current user


  Scenario: CLOUD-865: check HTTP_PROXY is converted to java options
    When container is started with env
      | variable   | value                 |
      | HTTP_PROXY | http://localhost:1337 |
    Then container log should contain Command line argument: -Dhttp.proxyHost=localhost
     And available container log should contain Command line argument: -Dhttp.proxyPort=1337

  # CLOUD-193 (mem-limit) & CLOUD-459
  # default heap size == max heap size == 1/2 available memory
  Scenario: Check for dynamic resource allocation
    When container is started with args
      | arg                    | value             |
      | mem_limit              | 1073741824        |
    Then container log should contain Command line argument: -Xms512m
    Then container log should contain Command line argument: -Xmx512m

  # CLOUD-459 (override default heap size)
  Scenario: Check for adjusted default heap size
    When container is started with args
      | arg       | value                        |
      | mem_limit | 1073741824                   |
      | env_json  | {"INITIAL_HEAP_PERCENT": 0.5} |
    Then container log should contain Command line argument: -Xms256m
    Then container log should contain Command line argument: -Xmx512m

  Scenario: check hardened context
    When container is ready
    Then XML file /opt/webserver/conf/context.xml should contain value true on XPath //Context/@useHttpOnly
    Then XML file /opt/webserver/conf/context.xml should contain value false on XPath //Context/@privileged

  Scenario: CLOUD-865: check HTTP_PROXY is converted to java options
    When container is started with env
      | variable   | value                 |
      | HTTP_PROXY | http://localhost:1337 |
    Then container log should contain Command line argument: -Dhttp.proxyHost=localhost
     And available container log should contain Command line argument: -Dhttp.proxyPort=1337

  Scenario: CLOUD-1516: Application will not start with NO_PROXY settings
    When container is started with env
      | variable   | value                 |
      | NO_PROXY   | 10.*,127.*,*.xpaas    |
    Then container log should contain Command line argument: -Dhttp.nonProxyHosts=10.*|127.*|*.xpaas

    Scenario: CLOUD-1728: Application will not start with NO_PROXY settings
    When container is started with env
      | variable   | value                 |
      | no_proxy   | 10.*,127.*,*.xpaas    |
    Then container log should contain Command line argument: -Dhttp.nonProxyHosts=10.*|127.*|*.xpaas

  Scenario: check hardened Host
    When container is ready
    Then XML file /opt/webserver/conf/server.xml should contain value false on XPath //Server/Service/Engine/Host/@autoDeploy
    Then XML file /opt/webserver/conf/server.xml should contain value true on XPath //Server/Service/Engine/Host/@deployOnStartup
