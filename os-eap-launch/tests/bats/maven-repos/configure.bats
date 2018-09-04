#!/usr/bin/env bats

load common

@test "configure_maven_repo: Should use the default parameters." {
  run configure_maven_repo $SETTINGS "http://my_url:8080" "my_id"

  assert_profile_xml "my_id-profile" "profile_default.xml"
  assert_active_profile "my_id-profile"
  assert_server_xml "my_id" "server.xml"
}

@test "configure_maven_repo: Should show a warning when is unable to discover the repo_url." {
  run configure_maven_repo $SETTINGS "" "my_id"

  [[ $output = *'WARN Variable "MAVEN_REPO_URL" not set. Skipping maven repo setup for the prefix "MAVEN".'* ]]
}

@test "configure_maven_repo: Should discover the repo_url and use the MAVEN_REPO_HOST env var. No prefix, defaults to MAVEN" {
  MAVEN_REPO_SERVICE="my_service"
  MAVEN_REPO_HOST="my_url"

  run configure_maven_repo $SETTINGS "" "my_id"

  assert_profile_xml "my_id-profile" "profile_default_discovery.xml"
  assert_active_profile "my_id-profile"
  assert_server_xml "my_id" "server.xml"
}

@test "configure_maven_repo: Should discover the repo_url and use the X_SERVICE_HOST. No prefix, defaults to MAVEN" {
  MAVEN_REPO_SERVICE="my_service"
  MY_SERVICE_SERVICE_HOST="my_url"

  run configure_maven_repo $SETTINGS "" "my_id"

  assert_profile_xml "my_id-profile" "profile_default_discovery.xml"
  assert_active_profile "my_id-profile"
  assert_server_xml "my_id" "server.xml"
}

@test "configure_maven_repo: Should discover the repo_url. Set all parameters. No prefix, defaults to MAVEN" {
  MAVEN_REPO_SERVICE="my_service"
  MAVEN_REPO_HOST="my_url"
  MAVEN_REPO_PROTOCOL="https"
  MAVEN_REPO_PORT="9090"
  MAVEN_REPO_PATH="/custom_path"

  run configure_maven_repo $SETTINGS "" "my_id"

  assert_profile_xml "my_id-profile" "profile_custom_discovery.xml"
  assert_active_profile "my_id-profile"
  assert_server_xml "my_id" "server.xml"
}

@test "configure_maven_repo: Should discover the repo_url. Discover SERVICE_PORT. No prefix, defaults to MAVEN" {
  MAVEN_REPO_SERVICE="my_service"
  MAVEN_REPO_HOST="my_url"
  MAVEN_REPO_PROTOCOL="https"
  MY_SERVICE_SERVICE_PORT="9090"
  MAVEN_REPO_PATH="/custom_path"

  run configure_maven_repo $SETTINGS "" "my_id"

  assert_profile_xml "my_id-profile" "profile_custom_discovery.xml"
  assert_active_profile "my_id-profile"
  assert_server_xml "my_id" "server.xml"
}

@test "configure_maven_repo: Should discover the repo_url. Set all parameters. Use prefix" {
  TEST_1_MAVEN_REPO_SERVICE="my_service"
  TEST_1_MAVEN_REPO_HOST="my_url"
  TEST_1_MAVEN_REPO_PROTOCOL="https"
  TEST_1_MAVEN_REPO_PORT="9090"
  TEST_1_MAVEN_REPO_PATH="/custom_path"

  run configure_maven_repo $SETTINGS "" "my_id" "test-1"

  assert_profile_xml "my_id-profile" "profile_custom_discovery.xml"
  assert_active_profile "my_id-profile"
  assert_server_xml "my_id" "server.xml"
}

@test "configure_maven_repos: Should display a warning for single repo" {
  MAVEN_REPO_ID="my_id"

  run configure_maven_repos

  [[ $output = *'WARN Variable "MAVEN_REPO_URL" not set. Skipping maven repo setup for the prefix "MAVEN".'* ]]
}

@test "configure_maven_repos: Should configure a single repo with MAVEN_REPO_ID." {
  MAVEN_REPO_URL="http://my_url:8080"
  MAVEN_REPO_ID="my_id"

  run configure_maven_repos

  assert_profile_xml "my_id-profile" "profile_default.xml"
  assert_active_profile "my_id-profile"
  assert_server_xml "my_id" "server.xml"
}

@test "configure_maven_repos: Should configure a single repo with generated REPO_ID." {
  MAVEN_REPO_URL="http://my_url:8080"

  run configure_maven_repos

  has_generated_profile
  has_generated_active_profile
  has_generated_server
}

@test "configure_maven_repos: Should configure Multiple repos and not the Single repo." {
  MAVEN_REPOS=repo1
  REPO1_MAVEN_REPO_ID=id_repo1
  REPO1_MAVEN_REPO_URL=http://repo1:8383/

  run configure_maven_repos

  [[ $output = *'WARN Variable "MAVEN_REPO_URL" not set. Skipping maven repo setup for the prefix "MAVEN".'* ]]
  assert_profile_xml "id_repo1-profile" "profile_repo1.xml"
  assert_active_profile "id_repo1-profile"
  assert_server_xml "id_repo1" "server_repo1.xml"
}

@test "configure_maven_repos: Should configure Generated Single and Multiple repos." {
  MAVEN_REPO_URL="http://my_url:8080"
  MAVEN_REPOS=repo1,repo-2
  REPO1_MAVEN_REPO_ID=id_repo1
  REPO1_MAVEN_REPO_URL=http://repo1:8383/
  REPO_2_MAVEN_REPO_ID=id-repo-2
  REPO_2_MAVEN_REPO_URL=http://repo-2:5050/

  run configure_maven_repos

  # Generated Single repo
  has_generated_profile
  has_generated_active_profile
  has_generated_server
  # Multiple repo repo1
  assert_profile_xml "id_repo1-profile" "profile_repo1.xml"
  assert_active_profile "id_repo1-profile"
  assert_server_xml "id_repo1" "server_repo1.xml"
  # Multiple repo repo-2
  assert_profile_xml "id-repo-2-profile" "profile_repo2.xml"
  assert_active_profile "id-repo-2-profile"
  assert_server_xml "id-repo-2" "server_repo2.xml"
}
