@jboss-datavirt-6/datavirt63-openshift @jboss-datavirt-6/datavirt64-openshift
Feature: Openshift JDV s2i tests
  Scenario: Test if VDBs, RAs, and datasources are deployed
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from datavirt/dynamicvdb-datafederation/app with env
      | variable                             | value                                                            |
      | EAP_SECDOMAIN_NAME                   | eap-secdomain-name                                               |
      | DATASOURCES                          | ACCOUNTS                                                         |
      | ACCOUNTS_DATABASE                    | accounts                                                         |
      | ACCOUNTS_JNDI                        | java:/accounts-ds                                                |
      | ACCOUNTS_DRIVER                      | h2                                                               |
      | ACCOUNTS_JTA                         | true                                                             |
      | ACCOUNTS_NONXA                       | true                                                             |
      | ACCOUNTS_USERNAME                    | sa                                                               |
      | ACCOUNTS_PASSWORD                    | sa                                                               |
      | ACCOUNTS_URL                         | jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE        |
      | ACCOUNTS_SERVICE_HOST                | dummy                                                            |
      | ACCOUNTS_SERVICE_PORT                | 12345                                                            |
      | RESOURCE_ADAPTERS                    | MARKETDATA,EXCEL                                                 |
      | MARKETDATA_ID                        | fileQS                                                           |
      | MARKETDATA_MODULE_ID                 | org.jboss.teiid.resource-adapter.file                            |
      | MARKETDATA_MODULE_SLOT               | main                                                             |
      | MARKETDATA_CONNECTION_CLASS          | org.teiid.resource.adapter.file.FileManagedConnectionFactory     |
      | MARKETDATA_CONNECTION_JNDI           | java:/marketdata-file                                            |
      | MARKETDATA_PROPERTY_ParentDirectory  | /opt/eap/standalone/data/teiidfiles/data                         |
      | MARKETDATA_PROPERTY_AllowParentPaths | true                                                             |
      | EXCEL_ID                             | fileQSExcel                                                      |
      | EXCEL_MODULE_SLOT                    | main                                                             |
      | EXCEL_MODULE_ID                      | org.jboss.teiid.resource-adapter.file                            |
      | EXCEL_CONNECTION_CLASS               | org.teiid.resource.adapter.file.FileManagedConnectionFactory     |
      | EXCEL_CONNECTION_JNDI                | java:/excel-file                                                 |
      | EXCEL_PROPERTY_ParentDirectory       | /opt/eap/standalone/data/teiidfiles/excelFiles/                  |
      | EXCEL_PROPERTY_AllowParentPaths      | true                                                             |
    Then container log should contain JBAS015859: Deployed "portfolio-vdb.xml"
    And container log should contain JBAS015859: Deployed "hibernate-portfolio-vdb.xml"
    And container log should contain JBAS015874: JBoss Red Hat JBoss Data Virtualization
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/accounts-ds on XPath //*[local-name()='datasource']/@jndi-name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE on XPath //*[local-name()='datasource'][@jndi-name="java:/accounts-ds"]/*[local-name()='connection-url']
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value fileQS on XPath //*[local-name()='resource-adapter']/@id
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.teiid.resource.adapter.file.FileManagedConnectionFactory on XPath //*[local-name()='resource-adapter'][@id="fileQS"]/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/@class-name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value fileQSExcel on XPath //*[local-name()='resource-adapter']/@id
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value AllowParentPaths on XPath //*[local-name()='resource-adapter'][@id="fileQSExcel"]/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='config-property']/@name

  Scenario: Test if VDBs, RAs, and datasources are deployed using custom APP_DATADIR
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from datavirt/dynamicvdb-datafederation/app with env
      | variable                             | value                                                            |
      | EAP_SECDOMAIN_NAME                   | eap-secdomain-name                                               |
      | DATASOURCES                          | ACCOUNTS                                                         |
      | ACCOUNTS_DATABASE                    | accounts                                                         |
      | ACCOUNTS_JNDI                        | java:/accounts-ds                                                |
      | ACCOUNTS_DRIVER                      | h2                                                               |
      | ACCOUNTS_JTA                         | true                                                             |
      | ACCOUNTS_NONXA                       | true                                                             |
      | ACCOUNTS_USERNAME                    | sa                                                               |
      | ACCOUNTS_PASSWORD                    | sa                                                               |
      | ACCOUNTS_URL                         | jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE        |
      | ACCOUNTS_SERVICE_HOST                | dummy                                                            |
      | ACCOUNTS_SERVICE_PORT                | 12345                                                            |
      | RESOURCE_ADAPTERS                    | MARKETDATA,EXCEL                                                 |
      | MARKETDATA_ID                        | fileQS                                                           |
      | MARKETDATA_MODULE_ID                 | org.jboss.teiid.resource-adapter.file                            |
      | MARKETDATA_MODULE_SLOT               | main                                                             |
      | MARKETDATA_CONNECTION_CLASS          | org.teiid.resource.adapter.file.FileManagedConnectionFactory     |
      | MARKETDATA_CONNECTION_JNDI           | java:/marketdata-file                                            |
      | MARKETDATA_PROPERTY_ParentDirectory  | /opt/eap/standalone/data/teiidfiles/data                         |
      | MARKETDATA_PROPERTY_AllowParentPaths | true                                                             |
      | EXCEL_ID                             | fileQSExcel                                                      |
      | EXCEL_MODULE_SLOT                    | main                                                             |
      | EXCEL_MODULE_ID                      | org.jboss.teiid.resource-adapter.file                            |
      | EXCEL_CONNECTION_CLASS               | org.teiid.resource.adapter.file.FileManagedConnectionFactory     |
      | EXCEL_CONNECTION_JNDI                | java:/excel-file                                                 |
      | EXCEL_PROPERTY_ParentDirectory       | /opt/eap/standalone/data/teiidfiles/excelFiles/                  |
      | EXCEL_PROPERTY_AllowParentPaths      | true                                                             |
      | APP_DATADIR                          | custom_datadir                                                   |
    Then container log should contain JBAS015859: Deployed "portfolio-vdb.xml"
    And container log should contain JBAS015859: Deployed "hibernate-portfolio-vdb.xml"
    And container log should contain JBAS015874: JBoss Red Hat JBoss Data Virtualization
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value java:/accounts-ds on XPath //*[local-name()='datasource']/@jndi-name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE on XPath //*[local-name()='datasource'][@jndi-name="java:/accounts-ds"]/*[local-name()='connection-url']
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value fileQS on XPath //*[local-name()='resource-adapter']/@id
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value org.teiid.resource.adapter.file.FileManagedConnectionFactory on XPath //*[local-name()='resource-adapter'][@id="fileQS"]/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/@class-name
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value fileQSExcel on XPath //*[local-name()='resource-adapter']/@id
    And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value AllowParentPaths on XPath //*[local-name()='resource-adapter'][@id="fileQSExcel"]/*[local-name()='connection-definitions']/*[local-name()='connection-definition']/*[local-name()='config-property']/@name

  # CLOUD-1145 - base test
  Scenario: Check custom war file was successfully deployed via CUSTOM_INSTALL_DIRECTORIES
    Given s2i build https://github.com/jboss-openshift/openshift-examples.git from custom-install-directories
      | variable   | value                    |
      | CUSTOM_INSTALL_DIRECTORIES | custom   |
    Then file /opt/eap/standalone/deployments/node-info.war should exist

  # CLOUD-1145 - CSV test
  Scenario: Check all modules are successfully deployed using comma-separated CUSTOM_INSTALL_DIRECTORIES value
    Given s2i build https://github.com/jboss-openshift/openshift-examples.git from custom-install-directories
      | variable   | value                    |
      | CUSTOM_INSTALL_DIRECTORIES | foo,bar  |
    Then file /opt/eap/standalone/deployments/foo.jar should exist
    Then file /opt/eap/standalone/deployments/bar.jar should exist
