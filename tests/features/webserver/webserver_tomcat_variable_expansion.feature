
Feature: Check correct variable expansion used
  @jboss-webserver-3/webserver30-tomcat7-openshift @jboss-webserver-3/webserver31-tomcat7-openshift @jboss-webserver-3/webserver30-tomcat8-openshift @jboss-webserver-3/webserver31-tomcat8-openshift
  Scenario: Set TOMCAT_SHUTDOWN
    When container is started with env
      | variable           | value                            |
      | TOMCAT_SHUTDOWN    | tombrady12                       |
    Then XML file /opt/webserver/conf/server.xml should contain value tombrady12 on XPath //Server/@shutdown

  @jboss-webserver-3/webserver30-tomcat7-openshift @jboss-webserver-3/webserver31-tomcat7-openshift @jboss-webserver-3/webserver30-tomcat8-openshift @jboss-webserver-3/webserver31-tomcat8-openshift
  Scenario: ErrorValve
    When container is started with env
      | variable           | value                            |
      | DEBUG              | true                             |
    Then XML file /opt/webserver/conf/server.xml should contain value true on XPath //Server/Service/Engine/Host/Valve[@className='org.apache.catalina.valves.ErrorReportValve']/@showReport
    Then XML file /opt/webserver/conf/server.xml should contain value true on XPath //Server/Service/Engine/Host/Valve[@className='org.apache.catalina.valves.ErrorReportValve']/@showServerInfo

  @jboss-webserver-3/webserver30-tomcat7-openshift @jboss-webserver-3/webserver31-tomcat7-openshift
  Scenario: Set JWS_ADMIN_USERNAME to null
    When container is started with env
      | variable           | value                            |
      | JWS_ADMIN_PASSWORD | p@ssw0rd                         |
      | JWS_ADMIN_USERNAME |                                  |
    Then XML file /opt/webserver/conf/tomcat-users.xml should have 1 elements on XPath //user[@username='jwsadmin']

  @jboss-webserver-3/webserver30-tomcat8-openshift @jboss-webserver-3/webserver31-tomcat8-openshift
  Scenario: Set JWS_ADMIN_USERNAME to null
    Given XML namespaces
      | prefix | url                          |
      | ns     | http://tomcat.apache.org/xml |
    When container is started with env
      | variable           | value                            |
      | JWS_ADMIN_PASSWORD | p@ssw0rd                         |
      | JWS_ADMIN_USERNAME |                                  |
    Then XML file /opt/webserver/conf/tomcat-users.xml should have 1 elements on XPath //ns:user[@username='jwsadmin']

  @jboss-webserver-3/webserver30-tomcat7-openshift @jboss-webserver-3/webserver31-tomcat7-openshift @jboss-webserver-3/webserver30-tomcat8-openshift @jboss-webserver-3/webserver31-tomcat8-openshift
  Scenario: Set JWS_REALM_DATASOURCE_NAME to null
    When container is started with env
      | variable                  | value                    |
      | JWS_REALM_USERTABLE       | jws-realm-usertable      |
      | JWS_REALM_USERNAME_COL    | jws-realm-username-col   |
      | JWS_REALM_USERCRED_COL    | jws-realm-usercred-col   |
      | JWS_REALM_USERROLE_TABLE  | jws-realm-userrole-table |
      | JWS_REALM_ROLENAME_COL    | jws-realm-rolename-col   |
      | JWS_REALM_DATASOURCE_NAME |                          |
    Then XML file /opt/webserver/conf/server.xml should have 1 elements on XPath /Server/Service/Engine/Realm/Realm[@userTable="jws-realm-usertable" and @userNameCol="jws-realm-username-col" and @userCredCol="jws-realm-usercred-col" and @userRoleTable="jws-realm-userrole-table" and @roleNameCol="jws-realm-rolename-col" and @dataSourceName="jdbc/auth"]

  @jboss-webserver-3/webserver30-tomcat7-openshift @jboss-webserver-3/webserver31-tomcat7-openshift @jboss-webserver-3/webserver30-tomcat8-openshift @jboss-webserver-3/webserver31-tomcat8-openshift
  Scenario: Test setting ARTIFACT_DIR to null
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts.git from tomcat-websocket-chat using 1.1
       | variable     | value       |
       | ARTIFACT_DIR |             |
    Then container log should contain org.apache.catalina.startup.Catalina- Server startup in
    And available container log should contain Deployment of web application archive /deployments/websocket-chat.war has finished

  @jboss-webserver-3/webserver30-tomcat7-openshift @jboss-webserver-3/webserver31-tomcat7-openshift @jboss-webserver-3/webserver30-tomcat8-openshift @jboss-webserver-3/webserver31-tomcat8-openshift
  Scenario: CLOUD-1814, always include RemoteIpValve
    When container is started with env
      | variable          | value                 |
      | ENABLE_ACCESS_LOG | false                 |
    Then file /opt/webserver/conf/server.xml should contain <Valve className="org.apache.catalina.valves.RemoteIpValve" remoteIpHeader="X-Forwarded-For" protocolHeader="X-Forwarded-Proto"/>

  @jboss-webserver-3/webserver30-tomcat7-openshift @jboss-webserver-3/webserver31-tomcat7-openshift @jboss-webserver-3/webserver30-tomcat8-openshift @jboss-webserver-3/webserver31-tomcat8-openshift
  Scenario: CLOUD-1784, make the Access Log Valve configurable
    When container is started with env
      | variable          | value                 |
      | ENABLE_ACCESS_LOG | true                  |
    Then file /opt/webserver/conf/server.xml should contain <Valve className="org.apache.catalina.valves.AccessLogValve" directory="/proc/self/fd"
    And file /opt/webserver/conf/server.xml should contain prefix="1" suffix="" rotatable="false" requestAttributesEnabled="true"
    And file /opt/webserver/conf/server.xml should contain pattern="%h %l %u %t %{X-Forwarded-Host}i &quot;%r&quot; %s %b" />
    And file /opt/webserver/conf/server.xml should contain <Valve className="org.apache.catalina.valves.RemoteIpValve" remoteIpHeader="X-Forwarded-For" protocolHeader="X-Forwarded-Proto"/>

  @jboss-webserver-3/webserver30-tomcat7-openshift @jboss-webserver-3/webserver31-tomcat7-openshift @jboss-webserver-3/webserver30-tomcat8-openshift @jboss-webserver-3/webserver31-tomcat8-openshift
  Scenario: APR is enabled for 64 bit 
    When container is started with env
      | variable          | value                 |
      | USE_32_BIT_JVM    | false                 |
    Then file /opt/webserver/conf/server.xml should contain <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />

  @jboss-webserver-3/webserver30-tomcat7-openshift @jboss-webserver-3/webserver31-tomcat7-openshift @jboss-webserver-3/webserver30-tomcat8-openshift @jboss-webserver-3/webserver31-tomcat8-openshift
  Scenario: APR is disabled for 32 bit
    When container is started with env
      | variable          | value                 |
      | USE_32_BIT_JVM    | true                  |
    Then file /opt/webserver/conf/server.xml should not contain org.apache.catalina.core.AprLifecycleListener


