#!/bin/bash

function add_admin_user() {
  if [ -n "$SSO_ADMIN_USERNAME" ] && [ -n "$SSO_ADMIN_PASSWORD" ]; then
    /opt/eap/bin/add-user-keycloak.sh -r master -u $SSO_ADMIN_USERNAME -p $SSO_ADMIN_PASSWORD
  fi
}

