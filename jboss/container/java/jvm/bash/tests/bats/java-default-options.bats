export JBOSS_CONTAINER_JAVA_JVM_MODULE=${BATS_TEST_DIRNAME}/../../../bash/artifacts/opt/jboss/container/java/jvm/
load $BATS_TEST_DIRNAME/../../../bash/artifacts/opt/jboss/container/java/jvm/java-default-options

@test "Test default initial memory value" {
    expected="" # expect nothing
    run initial_memory
    echo "Result: ${output}"
    echo "Expected: ${expected}"
    [ "${expected}" = "${output}" ]
}

@test "Test default initial memory values with valid CONTAINER_MAX_MEMORY" {
    expected="-Xms64m"
    CONTAINER_MAX_MEMORY=536870912
    run initial_memory
    echo "Result: ${output}"
    echo "Expected: ${expected}"
    [ "${expected}" = "${output}" ]
}

@test "Test 6g initial memory values" {
    expected="-Xms768m"
    CONTAINER_MAX_MEMORY=6442450944
    JAVA_MAX_INITIAL_MEM=6144
    run initial_memory
    echo "Result: ${output}"
    echo "Expected: ${expected}"
    [ "${expected}" = "${output}" ]
}

@test "Test 6g initial memory values no CMM" {
    expected="" # nothing, no CMM available
    JAVA_MAX_INITIAL_MEM=6144
    run initial_memory
    echo "Result: ${output}"
    echo "Expected: ${expected}"
    [ "${expected}" = "${output}" ]
}

@test "Test default max memory values" {
    expected="" # expect nothing
    run max_memory
    echo "Result: ${output}"
    echo "Expected: ${expected}"
    [ "${expected}" = "${output}" ]
}

@test "Test default max memory values with valid CONTAINER_MAX_MEMORY" {
    expected="-Xmx256m"
    CONTAINER_MAX_MEMORY=536870912
    run max_memory
    echo "Result: ${output}"
    echo "Expected: ${expected}"
    [ "${expected}" = "${output}" ]
}

@test "Test default max memory values with CONTAINER_MAX_MEMORY=512mb" {
    expected="-Xmx256m"
    CONTAINER_MAX_MEMORY=536870912
    run max_memory
    echo "Result: ${output}"
    echo "Expected: ${expected}"
    [ "${expected}" = "${output}" ]
}

@test "Test 6g max memory values with CONTAINER_MAX_MEMORY set to 6g" {
    expected="-Xmx3072m"
    CONTAINER_MAX_MEMORY=6442450944
    run max_memory
    echo "Result: ${output}"
    echo "Expected: ${expected}"
    [ "${expected}" = "${output}" ]
}

@test "Test default 0.9 max 1.0 initial " {
    min_expected="" # should be empty
    max_expected=""
    JAVA_MAX_MEM_RATIO=90
    JAVA_INITIAL_MEM_RATIO=100
    run initial_memory
    min=${output}
    echo "Min Result: ${output}"
    echo "Min Expected: ${min_expected}"
    [ "${min_expected}" = "${min}" ]
    run max_memory
    max=${output}
    echo "Max Result: ${output}"
    echo "Max Expected: ${max_expected}"
}

@test "Test 6g 0.9 max 1.0 initial " {
    min_expected="-Xms5530m"
    max_expected="-Xmx5530m"
    CONTAINER_MAX_MEMORY=6442450944
    JAVA_MAX_MEM_RATIO=90
    JAVA_INITIAL_MEM_RATIO=100
    run initial_memory
    min=${output}
    echo "Min Result: ${output}"
    echo "Min Expected: ${min_expected}"
    [ "${min_expected}" = "${min}" ]
    run max_memory
    max=${output}
    echo "Max Result: ${output}"
    echo "Max Expected: ${max_expected}"
    [ "${max_expected}" = "${max}" ]
}

@test "Test default 4g 0.9 max 1.0 max only " {
    min_expected="" # should be unset, no CMM available
    max_expected="-Xmx3686m"
    JAVA_MAX_MEM_RATIO=90
    JAVA_INITIAL_MEM_RATIO=100
    run initial_memory
    min=${output}
    echo "Min Result: ${output}"
    echo "Min Expected: ${min_expected}"
    [ "${min_expected}" = "${min}" ]
    run max_memory
    max=${output}
    echo "Max Result: ${output}"
    echo "Max Expected: ${max_expected}"
}

@test "Test default 4g 1.0 max 1.0 max only " {
    min_expected="" # CMM not available, expect nothing
    max_expected="-Xmx4096m"
    JAVA_MAX_MEM_RATIO=100
    JAVA_INITIAL_MEM_RATIO=100
    run initial_memory
    min=${output}
    echo "Min Result: ${output}"
    echo "Min Expected: ${min_expected}"
    [ "${min_expected}" = "${min}" ]
    run max_memory
    max=${output}
    echo "Max Result: ${output}"
    echo "Max Expected: ${max_expected}"
}