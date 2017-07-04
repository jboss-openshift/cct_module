# Openshift Datagrid launch script routines for configuring authentication

function prepareEnv() {
  unset USERNAME
  unset PASSWORD
  unset SECDOMAIN_NAME
  unset SECDOMAIN_USERS_PROPERTIES
  unset SECDOMAIN_ROLES_PROPERTIES
  unset SECDOMAIN_LOGIN_MODULE
  unset SECDOMAIN_REALM
  unset REST_SECURITY_DOMAIN
}

function configure() {
  configure_authentication
}

# Configures JDG user
#
# Arguments:
# $1 - username
# $2 - password
# $3 - user properties file (filename only)
# $4 - group properties file (filename only)
# $5 - realm
function configure_user() {
  local username=$1
  local password=$2
  local users_properties=$3
  local roles_properties=$4
  local realm=$5

  local roles=REST,admin

  if [ -n "$ADMIN_GROUP" ]; then
    roles="$ADMIN_GROUP"
  fi

  $JBOSS_HOME/bin/add-user.sh -s --user $username --password $password --group $roles --user-properties $users_properties --group-properties $roles_properties --realm $realm
  if [ "$?" -ne "0" ]; then
	echo "Failed to create the user $username"
	echo "Exiting..."
	exit
  fi
}

function configure_authentication() {
  if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
    echo "Using simple authentication"

    local realm=ApplicationRealm
    local users_properties=application-users.properties
    local roles_properties=application-roles.properties

    touch $JBOSS_HOME/standalone/configuration/$users_properties
    touch $JBOSS_HOME/standalone/configuration/$roles_properties

    configure_user $USERNAME $PASSWORD $users_properties $roles_properties $realm

    SECDOMAIN_NAME=jdg-openshift
    SECDOMAIN_USERS_PROPERTIES="$users_properties"
    SECDOMAIN_ROLES_PROPERTIES="$roles_properties"
    SECDOMAIN_LOGIN_MODULE=RealmUsersRoles
    SECDOMAIN_REALM=$realm

  else
    echo "Not using simple authentication"
  fi
}
