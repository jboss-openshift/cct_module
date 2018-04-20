@jboss-eap-6/eap64-openshift @jboss-eap-7 @jboss-webserver-3/webserver30-tomcat7-openshift @jboss-webserver-3/webserver31-tomcat7-openshift @jboss-webserver-3/webserver30-tomcat8-openshift @jboss-webserver-3/webserver31-tomcat8-openshift
Feature: Openshift S2I tests
# NOTE: these builds does not actually run maven. This is important, because the proxy
# options supplied do not specify a valid HTTP proxy.

  # handles mirror/repository configuration; proxy configuration
  Scenario: deploys the spring-eap6-quickstart example, then checks if it's deployed.
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-eap6-quickstart
       | variable   | value                                            |
       | MAVEN_MIRROR_URL | http://127.0.0.1:8080/repository/internal/ |
       | HTTP_PROXY_HOST  | 127.0.0.1                                  |
       | HTTP_PROXY_PORT  | 8080                                       |
    And XML namespaces
     | prefix | url                                    |
     | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /home/jboss/.m2/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='http'][ns:host='127.0.0.1'][ns:port='8080']
    Then XML file /home/jboss/.m2/settings.xml should have 1 elements on XPath //ns:mirror[ns:id='mirror.default'][ns:url='http://127.0.0.1:8080/repository/internal/'][ns:mirrorOf='external:*']

  # proxy auth configuration (success case) + nonProxyHosts
  Scenario: deploys the spring-eap6-quickstart example, then checks if it's deployed.
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-eap6-quickstart
       | variable                 | value         |
       | HTTP_PROXY_HOST          | 127.0.0.1     |
       | HTTP_PROXY_PORT          | 8080          |
       | HTTP_PROXY_USERNAME      | myuser        |
       | HTTP_PROXY_PASSWORD      | mypass        |
       | HTTP_PROXY_NONPROXYHOSTS | *.example.com |
    And XML namespaces
     | prefix | url                                    |
     | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /home/jboss/.m2/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='http'][ns:host='127.0.0.1'][ns:port='8080'][ns:username='myuser'][ns:password='mypass'][ns:nonProxyHosts='*.example.com']

  # CLOUD-2020 - no_proxy configuration not properly translated to maven settings
  Scenario: Test if the NO_PROXY hosts are correctly configured on settings.xml file
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-eap6-quickstart
      | variable                 | value                              |
      | HTTP_PROXY_HOST          | 127.0.0.1                          |
      | HTTP_PROXY_PORT          | 8080                               |
      | HTTP_PROXY_USERNAME      | myuser                             |
      | HTTP_PROXY_PASSWORD      | mypass                             |
      | NO_PROXY                 | *.example.com,.example.net,abc.com |
    And XML namespaces
      | prefix | url                                    |
      | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /home/jboss/.m2/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='http'][ns:host='127.0.0.1'][ns:port='8080'][ns:username='myuser'][ns:password='mypass'][ns:nonProxyHosts='*.example.com|*.example.net|abc.com']

  # proxy auth configuration (fail case: no password supplied)
  Scenario: deploys the spring-eap6-quickstart example, then checks if it's deployed.
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-eap6-quickstart
       | variable   | value           |
       | HTTP_PROXY_HOST  | 127.0.0.1 |
       | HTTP_PROXY_PORT  | 8080      |
       | HTTP_PROXY_USERNAME | myuser |
    And XML namespaces
     | prefix | url                                    |
     | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /home/jboss/.m2/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='http'][ns:host='127.0.0.1'][ns:port='8080']

  # handles mirror/repository configuration; proxy configuration with custom settings.xml
  Scenario: deploys the spring-eap6-quickstart-custom example, then checks that settings.xml is customized
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-eap6-quickstart-custom-configuration
      | variable   | value                                            |
      | MAVEN_MIRROR_URL | http://127.0.0.1:8080/repository/internal/ |
      | HTTP_PROXY_HOST  | 127.0.0.1                                  |
      | HTTP_PROXY_PORT  | 8080                                       |
    And XML namespaces
      | prefix | url                                    |
      | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /home/jboss/.m2/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='http'][ns:host='127.0.0.1'][ns:port='8080']
    Then XML file /home/jboss/.m2/settings.xml should have 1 elements on XPath //ns:mirror[ns:id='mirror.default'][ns:url='http://127.0.0.1:8080/repository/internal/'][ns:mirrorOf='external:*']
    Then XML file /home/jboss/.m2/settings.xml should contain value CUSTOM on XPath //ns:description

  Scenario: Check if MAVEN_MIRROR_URL variant is working
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-eap6-quickstart
      | variable         | value                                      |
      | MAVEN_MIRROR_ID  | mirror_foo                                 |
      | MAVEN_MIRROR_URL | http://127.0.0.1:8080/repository/internal/ |
      | MAVEN_MIRROR_OF  | *                                          |
    And XML namespaces
      | prefix | url                                    |
      | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /home/jboss/.m2/settings.xml should have 1 elements on XPath //ns:mirror[ns:id='mirror_foo'][ns:url='http://127.0.0.1:8080/repository/internal/'][ns:mirrorOf='*']

  Scenario: Check if MAVEN_MIRRORS is working
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-eap6-quickstart
      | variable             | value                                      |
      | MAVEN_MIRRORS        | foo,bar,willfail                           |
      | foo_MAVEN_MIRROR_URL | http://127.0.0.1:8080/repository/internal/ |
      | bar_MAVEN_MIRROR_ID  | mirror_bar                                 |
      | bar_MAVEN_MIRROR_URL | http://127.0.0.1:9090/repository/other/    |
      | bar_MAVEN_MIRROR_OF  | *                                          |
    And XML namespaces
      | prefix | url                                    |
      | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /home/jboss/.m2/settings.xml should have 1 elements on XPath //ns:mirror[ns:id='mirror1'][ns:url='http://127.0.0.1:8080/repository/internal/'][ns:mirrorOf='external:*']
    And XML file /home/jboss/.m2/settings.xml should have 1 elements on XPath //ns:mirror[ns:id='mirror_bar'][ns:url='http://127.0.0.1:9090/repository/other/'][ns:mirrorOf='*']
    And s2i build log should contain WARN Variable "willfail_MAVEN_MIRROR_URL" not set. Skipping maven mirror setup for the prefix "willfail".

  Scenario: Check java perf dir owned by jboss
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-eap6-quickstart
      | variable             | value                                      |
    Then run sh -c 'pgrep -x java | xargs -I{} jstat -gc {} 1000 1' in container and check its output for S0C
    And run sh -c 'stat --printf="%U %G" /tmp/hsperfdata_jboss/' in container and check its output for jboss root
