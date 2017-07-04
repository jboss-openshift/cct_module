#TODO: @slaskawi
# This test doesn't make any sense in JDG. The only reason JDG uses deployer is Custom Cache Store scenario.
# In the subsequent version this test should be updated or removed.

#@openshift @datagrid
#Feature: Openshift JDG s2i tests
#
#  Scenario: Check s2i build
#    Given s2i build https://github.com/jboss-developer/jboss-jdg-quickstarts from helloworld-jdg using jdg-6.5.x
#    Then container log should match regex .*Starting deployment of "jboss-helloworld-jdg.war"
#    Then container log should match regex .*Deployed "jboss-helloworld-jdg.war"
