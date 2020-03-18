@openjdk
@redhat/openjdk-8-rhel7
@openj9
@ubi8/openjdk-8
@ubi8/openjdk-11
Feature: Prometheus agent tests

  Scenario: Verify API and defaults
    When container is started with args and env
      | arg_env                  | value |
      | env_AB_PROMETHEUS_ENABLE | false |
      | arg_command              | bash -c 'source $JBOSS_CONTAINER_PROMETHEUS_MODULE/prometheus-opts; get_prometheus_opts' |
    Then container log should not contain -javaagent:/usr/share/java/prometheus-jmx-exporter/jmx_prometheus_javaagent.jar=9799:/opt/jboss/container/prometheus/etc/jmx-exporter-config.yaml

  Scenario: Check Prometheus configuration
    When container is started with args and env
      | arg_env                  | value |
      | env_AB_PROMETHEUS_ENABLE | true  |
      | arg_command              | bash -c 'source $JBOSS_CONTAINER_PROMETHEUS_MODULE/prometheus-opts; get_prometheus_opts' |
    Then container log should contain -javaagent:/usr/share/java/prometheus-jmx-exporter/jmx_prometheus_javaagent.jar=9799:/opt/jboss/container/prometheus/etc/jmx-exporter-config.yaml

  Scenario: Check Prometheus custom configuration
    When container is started with args and env
      | arg_env                               | value                                  |
      | env_AB_PROMETHEUS_ENABLE              | true                                   |
      | env_AB_PROMETHEUS_JMX_EXPORTER_PORT   | 8080                                   |
      | env_AB_PROMETHEUS_JMX_EXPORTER_CONFIG | /path/to/some/jmx-exporter-config.yaml |
      | arg_command                           | bash -c 'source $JBOSS_CONTAINER_PROMETHEUS_MODULE/prometheus-opts; get_prometheus_opts' |
    Then container log should contain -javaagent:/usr/share/java/prometheus-jmx-exporter/jmx_prometheus_javaagent.jar=8080:/path/to/some/jmx-exporter-config.yaml
