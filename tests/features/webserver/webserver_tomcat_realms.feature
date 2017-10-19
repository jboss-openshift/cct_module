@jboss-webserver-3/webserver30-tomcat7-openshift @jboss-webserver-3/webserver31-tomcat7-openshift @jboss-webserver-3/webserver30-tomcat8-openshift @jboss-webserver-3/webserver31-tomcat8-openshift
Feature: Tomcat Openshift realms

  Scenario: check DataSourceRealm configured
    When container is started with env
       | variable                  | value       |
       | JWS_REALM_USERTABLE       | myusers     |
       | JWS_REALM_USERNAME_COL    | name        |
       | JWS_REALM_USERCRED_COL    | pass        |
       | JWS_REALM_USERROLE_TABLE  | roles       |
       | JWS_REALM_ROLENAME_COL    | role        |
    Then XML file /opt/webserver/conf/server.xml should have 1 elements on XPath /Server/Service/Engine/Realm/Realm[@className="org.apache.catalina.realm.DataSourceRealm"][@userTable="myusers"][@userNameCol="name"][@userCredCol="pass"][@userRoleTable="roles"][@roleNameCol="role"][@dataSourceName="jdbc/auth"][@localDataSource="true"]

  Scenario: check missing DataSourceRealm parameter is handled
    When container is started with env
       | variable                  | value       |
       | JWS_REALM_USERTABLE       | myusers     |
       | JWS_REALM_USERNAME_COL    | name        |
       | JWS_REALM_USERCRED_COL    | pass        |
       | JWS_REALM_USERROLE_TABLE  | roles       |
    Then container log should contain WARN Partial Realm configuration, additional realms WILL NOT be configured.

  Scenario: check user-specified DataSourceName is accepted
    When container is started with env
       | variable                  | value       |
       | JWS_REALM_USERTABLE       | myusers     |
       | JWS_REALM_USERNAME_COL    | name        |
       | JWS_REALM_USERCRED_COL    | pass        |
       | JWS_REALM_USERROLE_TABLE  | roles       |
       | JWS_REALM_ROLENAME_COL    | role        |
       | JWS_REALM_DATASOURCE_NAME | my-resource |
    Then XML file /opt/webserver/conf/server.xml should have 1 elements on XPath /Server/Service/Engine/Realm/Realm[@className="org.apache.catalina.realm.DataSourceRealm"][@userTable="myusers"][@userNameCol="name"][@userCredCol="pass"][@userRoleTable="roles"][@roleNameCol="role"][@dataSourceName="my-resource"][@localDataSource="true"]
