@openshift @webserver_tomcat7 @webserver_tomcat8
Feature: Openshift OpenJDK GC tests

  Scenario: Check default GC configuration
    When container is ready
    Then container log should match regex Command line argument: *-XX:\+UseParallelGC
      And container log should match regex Command line argument: *-XX:MinHeapFreeRatio=20
      And container log should match regex Command line argument: *-XX:MaxHeapFreeRatio=40
      And container log should match regex Command line argument: *-XX:GCTimeRatio=4
      And container log should match regex Command line argument: *-XX:AdaptiveSizePolicyWeight=90
      And container log should match regex Command line argument: *-XX:MaxMetaspaceSize=100m
      And container log should match regex Command line argument: *-XX:\+ExitOnOutOfMemoryError

  Scenario: Check GC_MIN_HEAP_FREE_RATIO GC configuration
    When container is started with env
       | variable                         | value  |
       | GC_MIN_HEAP_FREE_RATIO           | 30     |
    Then container log should match regex Command line argument: *-XX:\+UseParallelGC
      And container log should match regex Command line argument: *-XX:MinHeapFreeRatio=30
      And container log should match regex Command line argument: *-XX:MaxHeapFreeRatio=40
      And container log should match regex Command line argument: *-XX:GCTimeRatio=4
      And container log should match regex Command line argument: *-XX:AdaptiveSizePolicyWeight=90
      And container log should match regex Command line argument: *-XX:MaxMetaspaceSize=100m

  Scenario: Check GC_MAX_HEAP_FREE_RATIO GC configuration
    When container is started with env
       | variable                         | value  |
       | GC_MAX_HEAP_FREE_RATIO           | 50     |
    Then container log should match regex Command line argument: *-XX:\+UseParallelGC
      And container log should match regex Command line argument: *-XX:MinHeapFreeRatio=20
      And container log should match regex Command line argument: *-XX:MaxHeapFreeRatio=50
      And container log should match regex Command line argument: *-XX:GCTimeRatio=4
      And container log should match regex Command line argument: *-XX:AdaptiveSizePolicyWeight=90
      And container log should match regex Command line argument: *-XX:MaxMetaspaceSize=100m

  Scenario: Check GC_TIME_RATIO GC configuration
    When container is started with env
       | variable                         | value  |
       | GC_TIME_RATIO                    | 5      |
    Then container log should match regex Command line argument: *-XX:\+UseParallelGC
      And container log should match regex Command line argument: *-XX:MinHeapFreeRatio=20
      And container log should match regex Command line argument: *-XX:MaxHeapFreeRatio=40
      And container log should match regex Command line argument: *-XX:GCTimeRatio=5
      And container log should match regex Command line argument: *-XX:AdaptiveSizePolicyWeight=90
      And container log should match regex Command line argument: *-XX:MaxMetaspaceSize=100m

  Scenario: Check GC_ADAPTIVE_SIZE_POLICY_WEIGHT GC configuration
    When container is started with env
       | variable                         | value  |
       | GC_ADAPTIVE_SIZE_POLICY_WEIGHT   | 80     |
    Then container log should match regex Command line argument: *-XX:\+UseParallelGC
      And container log should match regex Command line argument: *-XX:MinHeapFreeRatio=20
      And container log should match regex Command line argument: *-XX:MaxHeapFreeRatio=40
      And container log should match regex Command line argument: *-XX:GCTimeRatio=4
      And container log should match regex Command line argument: *-XX:AdaptiveSizePolicyWeight=80
      And container log should match regex Command line argument: *-XX:MaxMetaspaceSize=100m

  Scenario: Check GC_MAX_METASPACE_SIZE GC configuration
    When container is started with env
       | variable                 | value  |
       | GC_MAX_METASPACE_SIZE    | 120    |
    Then container log should match regex Command line argument: *-XX:\+UseParallelGC
      And container log should match regex Command line argument: *-XX:MinHeapFreeRatio=20
      And container log should match regex Command line argument: *-XX:MaxHeapFreeRatio=40
      And container log should match regex Command line argument: *-XX:GCTimeRatio=4
      And container log should match regex Command line argument: *-XX:AdaptiveSizePolicyWeight=90
      And container log should match regex Command line argument: *-XX:MaxMetaspaceSize=120m

  Scenario: Check for adjusted heap sizes
    When container is started with args
      | arg       | value                                                    |
      | mem_limit | 1073741824                                               |
      | env_json  | {"JAVA_MAX_MEM_RATIO": 25, "JAVA_INITIAL_MEM_RATIO": 25} |
    Then container log should match regex Command line argument: *-Xms64m
      And container log should match regex Command line argument: *-Xmx256m

  # CLOUD-193 (mem-limit); CLOUD-459 (default heap size == max)
  Scenario: CLOUD-193 Check for dynamic resource allocation
    When container is started with args
      | arg                    | value             |
      | mem_limit              | 1073741824        |
    Then container log should match regex Command line argument: *-Xms512m
      And container log should match regex Command line argument: *-Xmx512m

  # CLOUD-459 (override default heap size)
  Scenario: CLOUD-459 Check for adjusted default heap size
    When container is started with args
      | arg       | value                        |
      | mem_limit | 1073741824                   |
      | env_json  | {"INITIAL_HEAP_PERCENT": 0.5} |
    Then container log should match regex Command line argument: *-Xms256m
      And container log should match regex Command line argument: *-Xmx512m
