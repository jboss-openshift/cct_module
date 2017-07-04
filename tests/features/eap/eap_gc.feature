@openshift @eap_6_4 @eap_7_0 @decisionserver @processserver @datagrid @datavirt
Feature: Openshift OpenJDK GC tests

  Scenario: Check default GC configuration
    When container is ready
    Then container log should match regex ^ *JAVA_OPTS: *.* -XX:\+UseParallelGC\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MinHeapFreeRatio=20\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MaxHeapFreeRatio=40\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:GCTimeRatio=4\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:AdaptiveSizePolicyWeight=90\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MaxMetaspaceSize=256m\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:\+ExitOnOutOfMemoryError\s

  Scenario: Check GC_MIN_HEAP_FREE_RATIO GC configuration
    When container is started with env
       | variable                         | value  |
       | GC_MIN_HEAP_FREE_RATIO           | 30     |
    Then container log should match regex ^ *JAVA_OPTS: *.* -XX:\+UseParallelGC\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MinHeapFreeRatio=30\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MaxHeapFreeRatio=40\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:GCTimeRatio=4\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:AdaptiveSizePolicyWeight=90\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MaxMetaspaceSize=256m\s

  Scenario: Check GC_MAX_HEAP_FREE_RATIO GC configuration
    When container is started with env
       | variable                         | value  |
       | GC_MAX_HEAP_FREE_RATIO           | 50     |
    Then container log should match regex ^ *JAVA_OPTS: *.* -XX:\+UseParallelGC\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MinHeapFreeRatio=20\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MaxHeapFreeRatio=50\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:GCTimeRatio=4\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:AdaptiveSizePolicyWeight=90\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MaxMetaspaceSize=256m\s

  Scenario: Check GC_TIME_RATIO GC configuration
    When container is started with env
       | variable                         | value  |
       | GC_TIME_RATIO                    | 5      |
    Then container log should match regex ^ *JAVA_OPTS: *.* -XX:\+UseParallelGC\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MinHeapFreeRatio=20\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MaxHeapFreeRatio=40\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:GCTimeRatio=5\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:AdaptiveSizePolicyWeight=90\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MaxMetaspaceSize=256m\s

  Scenario: Check GC_ADAPTIVE_SIZE_POLICY_WEIGHT GC configuration
    When container is started with env
       | variable                         | value  |
       | GC_ADAPTIVE_SIZE_POLICY_WEIGHT   | 80     |
    Then container log should match regex ^ *JAVA_OPTS: *.* -XX:\+UseParallelGC\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MinHeapFreeRatio=20\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MaxHeapFreeRatio=40\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:GCTimeRatio=4\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:AdaptiveSizePolicyWeight=80\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MaxMetaspaceSize=256m\s

  Scenario: Check GC_MAX_METASPACE_SIZE GC configuration
    When container is started with env
       | variable                 | value  |
       | GC_MAX_METASPACE_SIZE    | 120    |
    Then container log should match regex ^ *JAVA_OPTS: *.* -XX:\+UseParallelGC\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MinHeapFreeRatio=20\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MaxHeapFreeRatio=40\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:GCTimeRatio=4\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:AdaptiveSizePolicyWeight=90\s
      And container log should match regex ^ *JAVA_OPTS: *.* -XX:MaxMetaspaceSize=120m\s

  Scenario: Check for adjusted heap sizes
    When container is started with args
      | arg       | value                                                    |
      | mem_limit | 1073741824                                               |
      | env_json  | {"JAVA_MAX_MEM_RATIO": 25, "JAVA_INITIAL_MEM_RATIO": 25} |
    Then container log should match regex ^ *JAVA_OPTS: *.* -Xms64m\s
      And container log should match regex ^ *JAVA_OPTS: *.* -Xmx256m\s

  # CLOUD-193 (mem-limit); CLOUD-459 (default heap size == max)
  Scenario: CLOUD-193 Check for dynamic resource allocation
    When container is started with args
      | arg                    | value             |
      | mem_limit              | 1073741824        |
    Then container log should match regex ^ *JAVA_OPTS: *.* -Xms512m\s
      And container log should match regex ^ *JAVA_OPTS: *.* -Xmx512m\s

  # CLOUD-459 (override default heap size)
  Scenario: CLOUD-459 Check for adjusted default heap size
    When container is started with args
      | arg       | value                        |
      | mem_limit | 1073741824                   |
      | env_json  | {"INITIAL_HEAP_PERCENT": 0.5} |
    Then container log should match regex ^ *JAVA_OPTS: *.* -Xms256m\s
      And container log should match regex ^ *JAVA_OPTS: *.* -Xmx512m\s
