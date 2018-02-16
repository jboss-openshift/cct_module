#!/bin/sh
# Openshift EAP launch script

source $JBOSS_HOME/bin/launch/logging.sh

if [ "${SCRIPT_DEBUG}" = "true" ] ; then
    set -x
    log_info "Script debugging is enabled, allowing bash commands and their arguments to be printed as they are executed"
fi

CONFIG_FILE=$JBOSS_HOME/standalone/configuration/standalone-openshift.xml
LOGGING_FILE=$JBOSS_HOME/standalone/configuration/logging.properties

#For backward compatibility
ADMIN_USERNAME=${ADMIN_USERNAME:-${EAP_ADMIN_USERNAME:-$DEFAULT_ADMIN_USERNAME}}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-$EAP_ADMIN_PASSWORD}
NODE_NAME=${NODE_NAME:-$EAP_NODE_NAME}
HTTPS_NAME=${HTTPS_NAME:-$EAP_HTTPS_NAME}
HTTPS_PASSWORD=${HTTPS_PASSWORD:-$EAP_HTTPS_PASSWORD}
HTTPS_KEYSTORE_DIR=${HTTPS_KEYSTORE_DIR:-$EAP_HTTPS_KEYSTORE_DIR}
HTTPS_KEYSTORE=${HTTPS_KEYSTORE:-$EAP_HTTPS_KEYSTORE}
SECDOMAIN_USERS_PROPERTIES=${SECDOMAIN_USERS_PROPERTIES:-${EAP_SECDOMAIN_USERS_PROPERTIES:-users.properties}}
SECDOMAIN_ROLES_PROPERTIES=${SECDOMAIN_ROLES_PROPERTIES:-${EAP_SECDOMAIN_ROLES_PROPERTIES:-roles.properties}}
SECDOMAIN_NAME=${SECDOMAIN_NAME:-$EAP_SECDOMAIN_NAME}
SECDOMAIN_PASSWORD_STACKING=${SECDOMAIN_PASSWORD_STACKING:-$EAP_SECDOMAIN_PASSWORD_STACKING}

IMPORT_REALM_FILE=$JBOSS_HOME/standalone/configuration/import-realm.json

. $JBOSS_HOME/bin/launch/passwd.sh
configure_passwd

. $JBOSS_HOME/bin/launch/datasource.sh
NON_XA_DATASOURCE="true"
DB_JNDI="java:jboss/datasources/KeycloakDS"
DB_POOL="KeycloakDS"
inject_datasources

. $JBOSS_HOME/bin/launch/admin.sh
configure_administration

. $JBOSS_HOME/bin/launch/ha.sh
check_view_pods_permission
configure_ha

. $JBOSS_HOME/bin/launch/jgroups.sh
configure_jgroups_encryption

. $JBOSS_HOME/bin/launch/https.sh
configure_https

. $JBOSS_HOME/bin/launch/json_logging.sh
configure_json_logging

. $JBOSS_HOME/bin/launch/security-domains.sh
configure_security_domains

. $JBOSS_HOME/bin/launch/jboss_modules_system_pkgs.sh
configure_jboss_modules_system_pkgs

. $JBOSS_HOME/bin/launch/add-sso-admin-user.sh
add_admin_user

. $JBOSS_HOME/bin/launch/add-sso-realm.sh
realm_import

. $JBOSS_HOME/bin/launch/add-keycloak-server.sh
add_truststore
add_cache_container

source /opt/run-java/proxy-options
JAVA_PROXY_ARGS="$(proxy_options)"

log_info "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION"

# TERM signal handler
function clean_shutdown() {
  log_error "*** JBossAS wrapper process ($$) received TERM signal ***"
  $JBOSS_HOME/bin/jboss-cli.sh -c ":shutdown(timeout=60)"
  wait $!
}

trap "clean_shutdown" TERM

if [ -n "$SSO_IMPORT_FILE" ] && [ -f $SSO_IMPORT_FILE ]; then
  $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -bmanagement 127.0.0.1 $JBOSS_HA_ARGS ${JBOSS_MESSAGING_ARGS} -Dkeycloak.migration.action=import -Dkeycloak.migration.provider=singleFile -Dkeycloak.migration.file=${SSO_IMPORT_FILE} -Dkeycloak.migration.strategy=IGNORE_EXISTING ${JAVA_PROXY_ARGS} &
else
  $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -bmanagement 127.0.0.1 $JBOSS_HA_ARGS ${JBOSS_MESSAGING_ARGS} ${JAVA_PROXY_ARGS} &
fi
wait $!
