#!/usr/bin/env bats

source $BATS_TEST_DIRNAME/../../../added/launch/launch-common.sh

@test "find_env: Should use the default value when the variable is not set" {
  result=$(find_env foo default)
  [ "$result" = "default" ]
}

@test "find_env: Should return empty when the variable is not set and there is no default value" {
  result=$(find_env foo)
  [ "$result" = "" ]
}

@test "find_env: Should return the value of the env var env if it is set" {
  foo="test"
  result=$(find_env foo)
  [ "$result" = "test" ]
}

@test "find_env: Should ignore the default value and return the value of the env var env if it is set" {
  foo="test"
  result=$(find_env foo ignoreme)
  [ "$result" = "test" ]
}

@test "find_prefixed_env: Should rely on find_env the prefix is empty" {
  foo="test"
  result=$(find_prefixed_env "" foo)
  [ "$result" = "test" ]
}

@test "find_prefixed_env: Should add the prefix to the variable name" {
  TEST_foo="test_var"
  result=$(find_prefixed_env TEST foo)
  [ "$result" = "test_var" ]
}

@test "find_prefixed_env: Should capitalize the prefix" {
  TEST_foo="test_var"
  result=$(find_prefixed_env test foo)
  [ "$result" = "test_var" ]
}

@test "find_prefixed_env: Should replace - by _ in the prefix" {
  TEST_VAR_PREFIX_foo="test_var"
  result=$(find_prefixed_env TEST-VAR_PREFIX foo)
  [ "$result" = "test_var" ]
}

@test "find_prefixed_env: Should caplitalize and replace the prefix" {
  TEST_VAR_PREFIX_foo="test_var"
  result=$(find_prefixed_env test-VAR_PREFIX foo default)
  [ "$result" = "test_var" ]
}


@test "find_prefixed_env: Should return the default value when the variable is not set" {
  TEST_foo="test_var"
  result=$(find_prefixed_env test foo2 default)
  [ "$result" = "default" ]
}
