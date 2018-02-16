#!/bin/sh

source $JBOSS_HOME/bin/launch/launch-common.sh
source $JBOSS_HOME/bin/launch/files.sh
source $JBOSS_HOME/bin/launch/logging.sh 

function prepareEnv() {
  unset TEIID_PASSWORD
  unset TEIID_USERNAME
  unset MODESHAPE_PASSWORD
  unset MODESHAPE_USERNAME
  unset DATAVIRT_TRANSPORT_KEY_ALIAS
  unset DATAVIRT_TRANSPORT_KEYSTORE
  unset DATAVIRT_TRANSPORT_KEYSTORE_PASSWORD
  unset DATAVIRT_TRANSPORT_KEYSTORE_TYPE
  unset DATAVIRT_TRANSPORT_KEYSTORE_DIR
  unset DATAVIRT_USERS
  unset DATAVIRT_USER_PASSWORDS
  unset DATAVIRT_USER_GROUPS
}

function configure() {
  configure_teiid
}

function add_roles(){
  sed -i "s|=user|=user,odata,rest|" "${JBOSS_HOME}/standalone/configuration/application-roles.properties"
}

function update_users(){
  removeuser=$(grep dashboardAdmin= $JBOSS_HOME/standalone/configuration/application-users.properties )
  sed -i "s|${removeuser}||" "${JBOSS_HOME}/standalone/configuration/application-users.properties"

  if [ -n "$TEIID_PASSWORD" ]; then
    teiiduser="teiidUser"
    if [ -n "$TEIID_USERNAME" ]; then
      teiiduser="$TEIID_USERNAME"
      removeuser=$(grep teiidUser= $JBOSS_HOME/standalone/configuration/application-users.properties )
      sed -i "s|${removeuser}||" "${JBOSS_HOME}/standalone/configuration/application-users.properties"
      removeuser=$(grep teiidUser= $JBOSS_HOME/standalone/configuration/application-roles.properties )
      sed -i "s|${removeuser}||" "${JBOSS_HOME}/standalone/configuration/application-roles.properties"
    fi
    $JBOSS_HOME/bin/add-user.sh -u "$teiiduser" -p "$TEIID_PASSWORD" -a -g user
  else
    log_warning "No password specified for TEIID_PASSWORD. Using insecure default"
  fi

  modeshapeuser="modeshapeUser"

  if [ -n "$MODESHAPE_PASSWORD" ]; then
    if [ -n "$MODESHAPE_USERNAME" ]; then
      modeshapeuser="$MODESHAPE_USERNAME"
      removeuser=$(grep modeshapeUser= $JBOSS_HOME/standalone/configuration/application-users.properties )
      sed -i "s|${removeuser}||" "${JBOSS_HOME}/standalone/configuration/application-users.properties"
      removeuser=$(grep modeshapeUser= $JBOSS_HOME/standalone/configuration/application-roles.properties )
      sed -i "s|${removeuser}||" "${JBOSS_HOME}/standalone/configuration/application-roles.properties"
    fi

    $JBOSS_HOME/bin/add-user.sh -u "$modeshapeuser" -p "$MODESHAPE_PASSWORD" -a -g admin,connect
    password=$(java -jar $JBOSS_HOME/jboss-modules.jar -mp $JBOSS_HOME/modules -dep org.picketbox -cp . org.picketbox.datasource.security.SecureIdentityLoginModule $MODESHAPE_PASSWORD | grep "Encoded password" | sed "s|Encoded password: ||")
    sed -i "s|##MODESHAPE_USERNAME##|${modeshapeuser}|" "${CONFIG_FILE}"
    sed -i "s|##MODESHAPE_PASSWORD##|${password}|" "${CONFIG_FILE}"
  else
    log_error "No password was provided for '${modeshapeuser}' in the MODESHAPE_PASSWORD environment variable. JBoss Red Hat JBoss Data Virtualization will not work properly."
  fi
  
}

function add_secure_transport(){
  local key_alias=${DATAVIRT_TRANSPORT_KEY_ALIAS}
  local keystore=${DATAVIRT_TRANSPORT_KEYSTORE-$HTTPS_KEYSTORE}
  local keystore_pwd=${DATAVIRT_TRANSPORT_KEYSTORE_PASSWORD-$HTTPS_PASSWORD}
  local keystore_type=${DATAVIRT_TRANSPORT_KEYSTORE_TYPE-$HTTPS_KEYSTORE_TYPE}
  local keystore_dir=${DATAVIRT_TRANSPORT_KEYSTORE_DIR-$HTTPS_KEYSTORE_DIR}
  local auth_mode=${DATAVIRT_TRANSPORT_AUTHENTICATION_MODE}

  if [ -n "$key_alias" ] && [ -n "$keystore_pwd" ] && [ -n "$keystore" ] && [ -n "$keystore_dir" ]; then
    if [ -z "$keystore_type" ]; then
      keystore_type="JKS"
    fi

    if [ -z "$auth_mode" ]; then
      auth_mode="1-way"
    fi
  fi

  if [ -n "$auth_mode" ]; then
    if [ "$auth_mode" != "anonymous" ]; then
      if [ -z "$key_alias" ] || [ -z "$keystore_pwd" ] || [ -z "$keystore" ] || [ -z "$keystore_dir" ]; then
        log_warning "Secure JDBC transport missing alias, keystore, key password, and/or keystore directory for authentication mode '$auth_mode'. Will not be enabled"
        return
      fi
    fi

    # JDBC
    transport="<transport name=\"secure-jdbc\" socket-binding=\"secure-teiid-jdbc\" protocol=\"teiid\"><authentication security-domain=\"teiid-security\"/><ssl mode=\"enabled\" authentication-mode=\"$auth_mode\" ssl-protocol=\"TLSv1.2\" keymanagement-algorithm=\"SunX509\">"

    if [ "$auth_mode" != "anonymous" ]; then 
      transport="$transport <keystore name=\"${keystore_dir}/${keystore}\" password=\"$DATAVIRT_TRANSPORT_KEYSTORE_PASSWORD\" type=\"$keystore_type\" key-alias=\"$key_alias\"/><truststore name=\"${keystore_dir}/${keystore}\" password=\"$keystore_pwd\"/>"
    fi

    transport="$transport </ssl></transport>"

    # ODBC
    transport="$transport <transport name=\"secure-odbc\" socket-binding=\"secure-teiid-odbc\" protocol=\"pg\"><authentication security-domain=\"teiid-security\"/><ssl mode=\"enabled\" authentication-mode=\"$auth_mode\" ssl-protocol=\"TLSv1.2\" keymanagement-algorithm=\"SunX509\">"

    if [ "$auth_mode" != "anonymous" ]; then
      transport="$transport <keystore name=\"${keystore_dir}/${keystore}\" password=\"$DATAVIRT_TRANSPORT_KEYSTORE_PASSWORD\" type=\"$keystore_type\" key-alias=\"$key_alias\"/><truststore name=\"${keystore_dir}/${keystore}\" password=\"$keystore_pwd\"/>"
    fi

    transport="$transport </ssl></transport>"

    sed -i "s|<!-- ##TEIID_SECURE_TRANSPORT## -->|${transport}|g" ${CONFIG_FILE}
  fi
}

function add_users(){
  if [ -n $DATAVIRT_USERS ]; then
    index=0
    for dv_user in $(echo $DATAVIRT_USERS | sed "s/,/ /g"); do
      dv_users[index]=${dv_user}
      ((index=index+1))
    done
  fi

  if [ -n $DATAVIRT_USER_PASSWORDS ]; then
    index=0
    for dv_password in $(echo $DATAVIRT_USER_PASSWORDS | sed "s/,/ /g"); do
      dv_passwords[index]=${dv_password}
      ((index=index+1))
    done
  fi

  if [ -n $DATAVIRT_USER_GROUPS ]; then
    index=0
    for dv_group in $(echo $DATAVIRT_USER_GROUPS | sed "s/,/ /g"); do
      dv_groups[index]=${dv_group}
      ((index=index+1))
    done
  fi


  index=0
  while [ -n "${dv_users[index]}" ]; do
   if [ -n "${dv_users[index]}" ] && [ -n "${dv_passwords[index]}" ] && [ -n "${dv_groups[index]}" ]; then
     echo "ADDTEIIDUSER $index ${dv_users[index]} ${dv_passwords[index]} ${dv_groups[index]}"
     $JBOSS_HOME/bin/add-user.sh -a --user ${dv_users[index]} --password ${dv_passwords[index]} --group ${dv_groups[index]}
   fi
   ((index=index+1))
  done
}

function configure_teiid(){

  hostname=`hostname`
  find ${JBOSS_HOME}/standalone/deployments/ -name "*-vdb.xml" -exec sed -i "s|localhost|${hostname}|g" {} \;

  add_users

  update_users

  add_roles

  add_secure_transport

}



