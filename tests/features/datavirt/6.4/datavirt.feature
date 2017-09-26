@jboss-datavirt-6/datavirt64-openshift
Feature: OpenShift Datavirt tests

  Scenario: check for datavirt deployment
    When container is ready
    Then container log should contain JBAS015874: JBoss Red Hat JBoss Data Virtualization
     And available container log should contain JBAS015859: Deployed "teiid-olingo-odata4.war"
     And available container log should contain JBAS015859: Deployed "teiid-odata.war"
     And available container log should contain JBAS015859: Deployed "vdb-builder.war"
     And available container log should contain JBAS015859: Deployed "ds-builder.war"
     And available container log should contain JBAS015859: Deployed "ds-builder-help.war"
     And available container log should not contain JBAS015859: Deployed "ModeShape.vdb"
     And available container log should not contain JBAS015859: Deployed "modeshape-rest.war"
     And available container log should not contain JBAS015859: Deployed "teiid-dashboard-builder.war"
     And available container log should not contain JBAS015859: Deployed "integration-platform-console.war"
     And available container log should not contain modeshape-cmis.war

