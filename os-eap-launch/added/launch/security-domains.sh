
function prepareEnv() {
  unset SECDOMAIN_NAME
  unset SECDOMAIN_USERS_PROPERTIES
  unset SECDOMAIN_ROLES_PROPERTIES
  unset SECDOMAIN_LOGIN_MODULE
  unset SECDOMAIN_PASSWORD_STACKING
}

function configure() {
  configure_security_domains
}

function configureEnv() {
  configure
}

configure_security_domains() {
  local usersProperties="\${jboss.server.config.dir}/${SECDOMAIN_USERS_PROPERTIES}"
  local rolesProperties="\${jboss.server.config.dir}/${SECDOMAIN_ROLES_PROPERTIES}"

  # CLOUD-431: Check if provided files are absolute paths
  test "${SECDOMAIN_USERS_PROPERTIES:0:1}" = "/" && usersProperties="${SECDOMAIN_USERS_PROPERTIES}"
  test "${SECDOMAIN_ROLES_PROPERTIES:0:1}" = "/" && rolesProperties="${SECDOMAIN_ROLES_PROPERTIES}"

  local domains="<!-- no additional security domains configured -->"

  if [ -n "$SECDOMAIN_NAME" ]; then
      local login_module=${SECDOMAIN_LOGIN_MODULE:-UsersRoles}
      local realm=""
      local stack=""

      if [ $login_module == "RealmUsersRoles" ]; then
          realm="<module-option name=\"realm\" value=\"ApplicationRealm\"/>"
      fi

      if [ -n "$SECDOMAIN_PASSWORD_STACKING" ]; then
          stack="<module-option name=\"password-stacking\" value=\"useFirstPass\"/>"
      fi
      domains="\
        <security-domain name=\"$SECDOMAIN_NAME\" cache-type=\"default\">\
            <authentication>\
                <login-module code=\"$login_module\" flag=\"required\">\
                    <module-option name=\"usersProperties\" value=\"${usersProperties}\"/>\
                    <module-option name=\"rolesProperties\" value=\"${rolesProperties}\"/>\
                    $realm\
                    $stack\
                </login-module>\
            </authentication>\
        </security-domain>"
  fi

  sed -i "s|<!-- ##ADDITIONAL_SECURITY_DOMAINS## -->|${domains}<!-- ##ADDITIONAL_SECURITY_DOMAINS## -->|" "$CONFIG_FILE"
}
