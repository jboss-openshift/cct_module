#TODO: @slaskawi
# HTTPS tests don't make much sense in JDG. The only thing that is worth testing is HTTP with REST.
# However due to regression, we don't support encryption in REST interface (at least in JDG 7 and 7.1.Beta).
# We have two options from this point:
#  1) rewrite those tests for JDG 7.1 only
#  2) remove them completely

#@openshift @datagrid @wip
#Feature: Check correct variable expansion used
#
#  Scenario: Set HTTPS_NAME to null
#    When container is started with env
#      | variable               | value                        |
#      | JDG_HTTPS_NAME         | jdg-test-https-name          |
#      | JDG_HTTPS_PASSWORD     | jdg-test-https-password      |
#      | JDG_HTTPS_KEYSTORE_DIR | jdg-test-https-keystore-dir  |
#      | JDG_HTTPS_KEYSTORE     | jdg-test-https-keystore      |
#      | HTTPS_NAME             |                              |
#    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='connector'][@name='https']/*[local-name()='ssl'][@name='jdg-test-https-name']
#
#  Scenario: Set HTTPS_PASSWORD to null
#    Given XML namespaces
#      | prefix | url                      |
#      | ns     | urn:jboss:domain:web:1.5 |
#    When container is started with env
#      | variable               | value                        |
#      | JDG_HTTPS_NAME         | jdg-test-https-name          |
#      | JDG_HTTPS_PASSWORD     | jdg-test-https-password      |
#      | JDG_HTTPS_KEYSTORE_DIR | jdg-test-https-keystore-dir  |
#      | JDG_HTTPS_KEYSTORE     | jdg-test-https-keystore      |
#      | HTTPS_PASSWORD         |                              |
#    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='connector'][@name='https']/*[local-name()='ssl'][@password='jdg-test-https-password']
#
#  Scenario: Set HTTPS_KEYSTORE_DIR to null
#    When container is started with env
#      | variable               | value                        |
#      | JDG_HTTPS_NAME         | jdg-test-https-name          |
#      | JDG_HTTPS_PASSWORD     | jdg-test-https-password      |
#      | JDG_HTTPS_KEYSTORE_DIR | jdg-test-https-keystore-dir  |
#      | JDG_HTTPS_KEYSTORE     | jdg-test-https-keystore      |
#      | HTTPS_KEYSTORE_DIR     |                              |
#    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='connector'][@name='https']/*[local-name()='ssl'][@certificate-key-file='jdg-test-https-keystore-dir/jdg-test-https-keystore']
#
#  Scenario: Set HTTPS_KEYSTORE to null
#    When container is started with env
#      | variable               | value                        |
#      | JDG_HTTPS_NAME         | jdg-test-https-name          |
#      | JDG_HTTPS_PASSWORD     | jdg-test-https-password      |
#      | JDG_HTTPS_KEYSTORE_DIR | jdg-test-https-keystore-dir  |
#      | JDG_HTTPS_KEYSTORE     | jdg-test-https-keystore      |
#      | HTTPS_KEYSTORE         |                              |
#    Then XML file /opt/datagrid/standalone/configuration/clustered-openshift.xml should have 1 elements on XPath //*[local-name()='connector'][@name='https']/*[local-name()='ssl'][@certificate-key-file='jdg-test-https-keystore-dir/jdg-test-https-keystore']
