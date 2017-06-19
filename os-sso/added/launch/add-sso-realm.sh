#!/bin/bash

function realm_import() {
  if [ -n "$SSO_REALM" ]; then
    sed -i "s|##REALM##|${SSO_REALM}|" "${IMPORT_REALM_FILE}"

    if [ -n "$SSO_SERVICE_USERNAME" ]; then

      if [ -n "$SSO_SERVICE_PASSWORD" ]; then
        $JBOSS_HOME/bin/add-user-keycloak.sh -r $SSO_REALM -u $SSO_SERVICE_USERNAME -p $SSO_SERVICE_PASSWORD --roles realm-management/realm-admin
      fi
    fi

    SSO_IMPORT_FILE="$IMPORT_REALM_FILE"
  fi
}

