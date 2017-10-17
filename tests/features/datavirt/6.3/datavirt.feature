@jboss-datavirt-6/datavirt63-openshift
Feature: OpenShift Datavirt tests

  Scenario: check for ModeShape datasource
    Given XML namespaces
      | prefix | url                           |
      | ns     | urn:jboss:domain:datasources:1.2 |
    When container is ready
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/datasources/ModeShapeDS on XPath //ns:datasource/@jndi-name    

  Scenario: check for datavirt deployment
    When container is ready
    Then container log should contain JBAS015874: JBoss Red Hat JBoss Data Virtualization
     And available container log should contain JBAS015859: Deployed "teiid-olingo-odata4.war"
     And available container log should contain JBAS015859: Deployed "teiid-odata.war"
     And available container log should contain JBAS015859: Deployed "ModeShape.vdb"
     And available container log should contain JBAS015859: Deployed "modeshape-rest.war"
     And available container log should not contain JBAS015859: Deployed "teiid-dashboard-builder.war"
     And available container log should not contain JBAS015859: Deployed "integration-platform-console.war"
     And available container log should not contain modeshape-cmis.war

  # CLOUD-612
  Scenario: test probes
    When container is started with env
        | variable                     | value               |
        | MODESHAPE_USERNAME           | msuser              |
        | MODESHAPE_PASSWORD           | SD$$#^gfd3gg        |
    Then container log should contain JBAS015874: JBoss Red Hat JBoss Data Virtualization
    Then run /opt/eap/bin/readinessProbe.sh in container once
    Then run /opt/eap/bin/livenessProbe.sh in container once

  Scenario: check that password provided for modeshapeUser is accepted by picketbox
    When container is started with env
        | variable                     | value              |
        | MODESHAPE_PASSWORD           | SD$$#^gfd3gg       |
    Then container log should contain JBAS015874: JBoss Red Hat JBoss Data Virtualization
      And file /opt/eap/standalone/configuration/application-users.properties should contain teiidUser
      And file /opt/eap/standalone/configuration/application-users.properties should contain modeshapeUser
      And file /opt/eap/standalone/configuration/application-roles.properties should contain teiidUser=user,odata
      And file /opt/eap/standalone/configuration/application-roles.properties should contain modeshapeUser=admin,connect

  Scenario: check that a warning is present when no password was provided for modeshapeUser
    When container is ready
    Then container log should contain ERROR No password was provided for 'modeshapeUser' in the MODESHAPE_PASSWORD environment variable. JBoss Red Hat JBoss Data Virtualization will not work properly.

  Scenario: check that users and roles are updated
    When container is started with env
        | variable                     | value               |
        | MODESHAPE_USERNAME           | msuser              |
        | MODESHAPE_PASSWORD           | SD$$#^gfd3gg        |
        | TEIID_USERNAME               | tiuser              |
        | TEIID_PASSWORD               | TestP@ss1           |
        | DATAVIRT_USERS               | user1,user2         |
        | DATAVIRT_USER_PASSWORDS      | TestP@ss1,TestP@ss1 |
        | DATAVIRT_USER_GROUPS         | group1,group2       |
    Then container log should contain JBAS015874: JBoss Red Hat JBoss Data Virtualization
      And file /opt/eap/standalone/configuration/application-users.properties should contain tiuser
      And file /opt/eap/standalone/configuration/application-users.properties should contain msuser
      And file /opt/eap/standalone/configuration/application-users.properties should contain user1
      And file /opt/eap/standalone/configuration/application-users.properties should contain user2
      And file /opt/eap/standalone/configuration/application-users.properties should not contain teiidUser
      And file /opt/eap/standalone/configuration/application-roles.properties should contain tiuser=user,odata
      And file /opt/eap/standalone/configuration/application-roles.properties should contain msuser=admin,connect
      And file /opt/eap/standalone/configuration/application-roles.properties should contain user1=group1
      And file /opt/eap/standalone/configuration/application-roles.properties should contain user2=group2
      And file /opt/eap/standalone/configuration/application-roles.properties should not contain teiidUser

