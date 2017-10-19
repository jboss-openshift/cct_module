#!/bin/bash

source $JWS_HOME/bin/launch/logging.sh

function configure() {
  configure_realms
}

# user-overrideable, defaults to jdbc/auth
JWS_REALM_DATASOURCE_NAME="${JWS_REALM_DATASOURCE_NAME:-jdbc/auth}"

function configure_realms() {
  realms="<!-- no additional realms configured -->"
  if [ -n "$JWS_REALM_USERTABLE" -a -n "$JWS_REALM_USERNAME_COL" -a -n "$JWS_REALM_USERCRED_COL" -a -n "$JWS_REALM_USERROLE_TABLE" -a -n "$JWS_REALM_ROLENAME_COL" ]; then
      realms="<Realm \
        className=\"org.apache.catalina.realm.DataSourceRealm\"\
        userTable=\"$JWS_REALM_USERTABLE\"\
        userNameCol=\"$JWS_REALM_USERNAME_COL\"\
        userCredCol=\"$JWS_REALM_USERCRED_COL\"\
        userRoleTable=\"$JWS_REALM_USERROLE_TABLE\"\
        roleNameCol=\"$JWS_REALM_ROLENAME_COL\"\
        dataSourceName=\"$JWS_REALM_DATASOURCE_NAME\"\
        localDataSource=\"true\"\
      />" # ^ must match a Resource definition. TODO: check that there is one.
  elif [ -n "$JWS_REALM_USERTABLE" -o -n "$JWS_REALM_USERNAME_COL" -o -n "$JWS_REALM_USERCRED_COL" -o -n "$JWS_REALM_USERROLE_TABLE" -o -n "$JWS_REALM_ROLENAME_COL" ]; then
      log_warning "Partial Realm configuration, additional realms WILL NOT be configured."
  fi
  sed -i "s|<!--### ADDITIONAL_REALMS ###-->|$realms|" $JWS_HOME/conf/server.xml
}
