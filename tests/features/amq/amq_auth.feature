@jboss-amq-6
Feature: Openshift AMQ authentication tests

  Scenario: check certificate authentication
    When container is started with env
       | variable                  | value                                                                |
       | AMQ_USER                  | tombrady                                                             |
       | AMQ_PASSWORD              | password                                                             |
       | AMQ_DNAME                 | CN=localhost, OU=broker, O=Unknown, L=Unknown, ST=Unknown, C=Unknown |
    Then file /opt/amq/conf/activemq.xml should contain <jaasDualAuthenticationPlugin configuration="activemq" sslConfiguration="activemq"/>
     And file /opt/amq/conf/activemq.xml should not contain jaasAuthenticationPlugin
     And file /opt/amq/conf/users.properties should contain tombrady
     And file /opt/amq/conf/users-dname.properties should contain tombrady=CN=localhost, OU=broker, O=Unknown, L=Unknown, ST=Unknown, C=Unknown
     And file /opt/amq/conf/login.config should contain org.apache.activemq.jaas.TextFileCertificateLoginModule sufficient 
