#!/usr/bin/env bats
load common

@test "add_maven_repo: Should use the parameters provided and defaults for the rest" {
  run add_maven_repo $SETTINGS my_id http://my_url:8080
  assert_profile_xml "my_id-profile" "profile_default.xml"
  assert_active_profile "my_id-profile"
}

@test "add_maven_repo: Should use the parameters provided and defaults for the rest using prefix" {
  run add_maven_repo $SETTINGS my_id http://my_url:8080 "TEST_1"
  assert_profile_xml "my_id-profile" "profile_default.xml"
  assert_active_profile "my_id-profile"
}

@test "add_maven_repo: Should use all the parameters provided. No prefix" {
  REPO_LAYOUT="other_layout"
  REPO_RELEASES_ENABLED="false"
  REPO_RELEASES_UPDATE_POLICY="never"
  REPO_SNAPSHOTS_ENABLED="other_false"
  REPO_SNAPSHOTS_UPDATE_POLICY="other_never"

  run add_maven_repo $SETTINGS my_id http://my_url:8080
  assert_profile_xml "my_id-profile" "profile_all_vars.xml"
  assert_active_profile "my_id-profile"
}

@test "add_maven_repo: Should use all the parameters provided. Empty prefix" {
  REPO_LAYOUT="other_layout"
  REPO_RELEASES_ENABLED="false"
  REPO_RELEASES_UPDATE_POLICY="never"
  REPO_SNAPSHOTS_ENABLED="other_false"
  REPO_SNAPSHOTS_UPDATE_POLICY="other_never"

  run add_maven_repo $SETTINGS my_id http://my_url:8080
  assert_profile_xml "my_id-profile" "profile_all_vars.xml"
  assert_active_profile "my_id-profile"
}

@test "add_maven_repo: Should use all the parameters provided. Use prefix" {
  TEST_1_REPO_LAYOUT="other_layout"
  TEST_1_REPO_RELEASES_ENABLED="false"
  TEST_1_REPO_RELEASES_UPDATE_POLICY="never"
  TEST_1_REPO_SNAPSHOTS_ENABLED="other_false"
  TEST_1_REPO_SNAPSHOTS_UPDATE_POLICY="other_never"

  run add_maven_repo $SETTINGS my_id http://my_url:8080 "TEST_1"
  assert_profile_xml "my_id-profile" "profile_all_vars.xml"
  assert_active_profile "my_id-profile"
}
