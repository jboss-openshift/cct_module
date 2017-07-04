@openshift
Feature: Check correct variable expansion used
  @webserver_tomcat7 @webserver_tomcat8
  Scenario: Set TOMCAT_SHUTDOWN
    When container is started with env
      | variable           | value                            |
      | TOMCAT_SHUTDOWN    | tombrady12                       |
    Then XML file /opt/webserver/conf/server.xml should contain value tombrady12 on XPath //Server/@shutdown

  @webserver_tomcat7 @webserver_tomcat8
  Scenario: ErrorValve
    When container is started with env
      | variable           | value                            |
      | DEBUG              | true                             |
    Then XML file /opt/webserver/conf/server.xml should contain value true on XPath //Server/Service/Engine/Host/Valve[@className='org.apache.catalina.valves.ErrorReportValve']/@showReport
    Then XML file /opt/webserver/conf/server.xml should contain value true on XPath //Server/Service/Engine/Host/Valve[@className='org.apache.catalina.valves.ErrorReportValve']/@showServerInfo

  @webserver_tomcat7
  Scenario: Set JWS_ADMIN_USERNAME to null
    When container is started with env
      | variable           | value                            |
      | JWS_ADMIN_PASSWORD | p@ssw0rd                         |
      | JWS_ADMIN_USERNAME |                                  |
    Then XML file /opt/webserver/conf/tomcat-users.xml should have 1 elements on XPath //user[@username='jwsadmin']

  @webserver_tomcat8
  Scenario: Set JWS_ADMIN_USERNAME to null
    Given XML namespaces
      | prefix | url                          |
      | ns     | http://tomcat.apache.org/xml |
    When container is started with env
      | variable           | value                            |
      | JWS_ADMIN_PASSWORD | p@ssw0rd                         |
      | JWS_ADMIN_USERNAME |                                  |
    Then XML file /opt/webserver/conf/tomcat-users.xml should have 1 elements on XPath //ns:user[@username='jwsadmin']

  @webserver_tomcat7 @webserver_tomcat8
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

  @webserver_tomcat7 @webserver_tomcat8
  Scenario: Test setting ARTIFACT_DIR to null
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts.git from tomcat-websocket-chat using 1.1
       | variable     | value       |
       | ARTIFACT_DIR |             |
    Then container log should contain org.apache.catalina.startup.Catalina- Server startup in
    And available container log should contain Deployment of web application archive /deployments/websocket-chat.war has finished
