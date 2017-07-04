@openshift @webserver_tomcat7 @webserver_tomcat8
Feature: Openshift tomcat s2i tests
  # TODO: further testing: /opt/webservers/logs/localhost_access_log.2015-06-05.txt (replace date) should exist after a visit
  Scenario: custom configuration deployment
    Given s2i build https://github.com/jboss-openshift/openshift-examples from tomcat-custom-configuration
    Then XML file /opt/webserver/conf/context-openshift.xml should have 1 elements on XPath /Context/Valve[@className='org.apache.catalina.valves.AccessLogValve']

  Scenario: Binary application deployment
    Given s2i build https://github.com/jboss-openshift/openshift-examples from tomcat-helloworld
       | variable          | value                                                                                  |
       | MAVEN_ARGS        | -e -P jboss-eap-repository-insecure,-securecentral,insecurecentral -DskipTests package |
       | MAVEN_ARGS_APPEND | -Dfoo=bar                                                                              |
       | MAVEN_CLEAR_REPO  | true                                                                                   |
    Then container log should contain Deploying web application archive /deployments/hello.war
    Then container log should contain Deployment of web application archive /deployments/hello.war has finished in
    Then s2i build log should contain -Djava.net.preferIPv4Stack=true
    Then s2i build log should contain -Dfoo=bar
    Then s2i build log should contain -XX:+UseParallelGC -XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=40 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:MaxMetaspaceSize=100m
    Then run sh -c 'test -d /home/jboss/.m2/repository/org && echo oops || echo all good' in container and check its output for all good

  # CLOUD-579
  Scenario: Test that maven is executed in batch mode
    Given s2i build https://github.com/jboss-openshift/openshift-examples from tomcat-helloworld
    Then s2i build log should contain --batch-mode
    And s2i build log should not contain \r

  #CLOUD-512
  Scenario: build dynamically configuration deployment
    Given s2i build https://github.com/jboss-openshift/openshift-examples from tomcat-dynamic-configuration
    Then XML file /opt/webserver/conf/context-openshift.xml should have 1 elements on XPath /Context/Valve[@className='org.apache.catalina.valves.AccessLogValve']
