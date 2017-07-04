@openshift
Feature: tests for all openshift images

  # not the openjdk image
  @base @base_jdk @eap_6_4 @eap_7_0 @webserver_httpd @webserver_tomcat7 @webserver_tomcat8 @amq @datavirt @brms @bpms @kieserver @decisionserver @processserver @datagrid
  Scenario: Check that labels are correctly set
    Given image is built
    Then the image should contain label com.redhat.component containing value jboss
    Then the image should contain label com.redhat.component containing value openshift

  @base @base_jdk @eap_6_4 @eap_7_0 @webserver_httpd @webserver_tomcat7 @webserver_tomcat8 @amq @datavirt @brms @bpms @kieserver @decisionserver @processserver @datagrid @openjdk
  Scenario: Check that labels are correctly set
    Given image is built
    Then the image should contain label release
    And the image should contain label version
    And the image should contain label name
    And the image should contain label architecture with value x86_64
    And the image should contain label io.openshift.s2i.scripts-url with value image:///usr/local/s2i

  # not currently openjdk which exits too quickly
  @base @base_jdk @eap_6_4 @eap_7_0 @webserver_httpd @webserver_tomcat7 @webserver_tomcat8 @amq @datavirt @brms @bpms @kieserver @decisionserver @processserver @datagrid
  Scenario: check started as alternative UID
    # chosen by fair dice roll. guaranteed to be random.
    When container is started as uid 27558
    Then container log should contain Running
     And run id -u in container and check its output contains 27558
     And all files under /home/jboss are writeable by current user
     And run whoami in container and immediately check its output for jboss

  # not currently openjdk which exits too quickly
  @base @base_jdk @eap_6_4 @eap_7_0 @webserver_httpd @webserver_tomcat7 @webserver_tomcat8 @amq @datavirt @brms @bpms @kieserver @decisionserver @processserver @datagrid
  Scenario: check started as another alternative UID
    When container is started as uid 26458
    Then container log should contain Running
     And run id -u in container and check its output contains 26458
     And run whoami in container and immediately check its output for jboss

