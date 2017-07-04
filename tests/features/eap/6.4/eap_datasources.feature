@openshift @eap_6_4
Feature: EAP 6.4 Openshift datasources

  Scenario: Test no warning for MongoDB
    When container is started with env
      | variable                      | value              |
      | DB_SERVICE_PREFIX_MAPPING     | eap-app-mongodb=DB |
      | DB_DATABASE                   | mydb               |
      | DB_USERNAME                   | root               |
      | DB_PASSWORD                   | password           |
      | EAP_APP_MONGODB_SERVICE_HOST  | 10.1.1.1           |
      | EAP_APP_MONGODB_SERVICE_PORT  | 27017              |
    Then container log should contain Running jboss-eap-6/eap64-openshift image
     And available container log should not contain There is a problem with the DB_SERVICE_PREFIX_MAPPING environment variable

