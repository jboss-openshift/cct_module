#!/bin/sh

source $JBOSS_HOME/bin/launch/logging.sh

function prepareEnv() {
  unset SSO_DISABLE_SSL_CERTIFICATE_VALIDATION
  unset SECURE_DEPLOYMENTS
  unset SECURE_SAML_DEPLOYMENTS
  unset SSO_URL
  unset SSO_SERVICE_URL
  unset SSO_REALM
  unset SSO_PUBLIC_KEY
  unset SSO_TRUSTSTORE
  unset SSO_TRUSTSTORE_DIR
  unset SSO_TRUSTSTORE_PASSWORD
  unset SSO_SAML_CERTIFICATE_NAME
  unset SSO_SAML_KEYSTORE
  unset SSO_SAML_KEYSTORE_DIR
  unset SSO_SAML_KEYSTORE_PASSWORD
  unset SSO_USERNAME
  unset SSO_PASSWORD
  unset APPLICATION_ROUTES
  unset APPLICATION_NAME
  unset SSO_SECRET
  unset SSO_ENABLE_CORS
  unset SSO_BEARER_ONLY
  unset SSO_SAML_LOGOUT_PAGE
  unset HOSTNAME_HTTP
  unset HOSTNAME_HTTPS
  unset SSO_TRUSTSTORE_CERTIFICATE_ALIAS
  unset SSO_SAML_VALIDATE_SIGNATURE
}

function configure() {
  configure_keycloak
}

KEYCLOAK_REALM_SUBSYSTEM_FILE=$JBOSS_HOME/bin/launch/keycloak-realm-subsystem
KEYCLOAK_SAML_REALM_SUBSYSTEM_FILE=$JBOSS_HOME/bin/launch/keycloak-saml-realm-subsystem
KEYCLOAK_DEPLOYMENT_SUBSYSTEM_FILE=$JBOSS_HOME/bin/launch/keycloak-deployment-subsystem
KEYCLOAK_SAML_DEPLOYMENT_SUBSYSTEM_FILE=$JBOSS_HOME/bin/launch/keycloak-saml-deployment-subsystem
KEYCLOAK_SAML_SP_SUBSYSTEM_FILE=$JBOSS_HOME/bin/launch/keycloak-saml-sp-subsystem
KEYCLOAK_SECURITY_DOMAIN_FILE=$JBOSS_HOME/bin/launch/keycloak-security-domain
OPENIDCONNECT="KEYCLOAK"
SAML="KEYCLOAK-SAML"
SECURE_DEPLOYMENTS=$JBOSS_HOME/standalone/configuration/secure-deployments
SECURE_SAML_DEPLOYMENTS=$JBOSS_HOME/standalone/configuration/secure-saml-deployments

function configure_keycloak() {
  if [ -f $SECURE_DEPLOYMENTS ] || [ -f $SECURE_SAML_DEPLOYMENTS ]; then
    if [ -f $SECURE_DEPLOYMENTS ]; then
      keycloak_subsystem=`cat "${SECURE_DEPLOYMENTS}" | sed ':a;N;$!ba;s/\n//g'`
      keycloak_subsystem="<subsystem xmlns=\"urn:jboss:domain:keycloak:1.1\">${keycloak_subsystem}</subsystem>"

      sed -i "s|<!-- ##KEYCLOAK_SUBSYSTEM## -->|${keycloak_subsystem}|" "${CONFIG_FILE}"
    fi

    if [ -f $SECURE_SAML_DEPLOYMENTS ]; then
      keycloak_subsystem=`cat "${SECURE_SAML_DEPLOYMENTS}" | sed ':a;N;$!ba;s/\n//g'`
      keycloak_subsystem="<subsystem xmlns=\"urn:jboss:domain:keycloak-saml:1.1\">${keycloak_subsystem}</subsystem>"

      sed -i "s|<!-- ##KEYCLOAK_SAML_SUBSYSTEM## -->|${keycloak_subsystem}|" "${CONFIG_FILE}"
    fi

    enable_keycloak_deployments
    configure_extension
    configure_security_domain

  elif [ -n "$SSO_URL" ]; then
    enable_keycloak_deployments
    configure_extension
    configure_security_domain

    sso_service="$SSO_URL"
    if [ -n "$SSO_SERVICE_URL" ]; then
      sso_service="$SSO_SERVICE_URL"
    fi

    if [ ! -n "${SSO_REALM}" ]; then
      log_warning "Missing SSO_REALM. Defaulting to ${SSO_REALM:=master} realm"
    fi

    set_curl
    get_token

    configure_subsystem $OPENIDCONNECT ${KEYCLOAK_REALM_SUBSYSTEM_FILE} "##KEYCLOAK_SUBSYSTEM##" "openid-connect" ${KEYCLOAK_DEPLOYMENT_SUBSYSTEM_FILE}

    keycloak_saml_sp=$(cat "${KEYCLOAK_SAML_SP_SUBSYSTEM_FILE}" | sed ':a;N;$!ba;s|\n|\\n|g')
    configure_subsystem $SAML ${KEYCLOAK_SAML_REALM_SUBSYSTEM_FILE} "##KEYCLOAK_SAML_SUBSYSTEM##" "saml" ${KEYCLOAK_SAML_DEPLOYMENT_SUBSYSTEM_FILE}

    sed -i "s|##KEYCLOAK_REALM##|${SSO_REALM}|g" "${CONFIG_FILE}"

    if [ -n "$SSO_PUBLIC_KEY" ]; then
      sed -i "s|<!-- ##KEYCLOAK_PUBLIC_KEY## -->|<realm-public-key>${SSO_PUBLIC_KEY}</realm-public-key>|g" "${CONFIG_FILE}"
    fi

    if [ -n "$SSO_TRUSTSTORE" ] && [ -n "$SSO_TRUSTSTORE_DIR" ]; then
      sed -i "s|<!-- ##KEYCLOAK_TRUSTSTORE## -->|<truststore>${SSO_TRUSTSTORE_DIR}/${SSO_TRUSTSTORE}</truststore><truststore-password>${SSO_TRUSTSTORE_PASSWORD}</truststore-password>|g" "${CONFIG_FILE}"
      sed -i "s|##KEYCLOAK_DISABLE_TRUST_MANAGER##|false|g" "${CONFIG_FILE}"
    else
      sed -i "s|##KEYCLOAK_DISABLE_TRUST_MANAGER##|true|g" "${CONFIG_FILE}"
    fi

    sed -i "s|##KEYCLOAK_URL##|${SSO_URL}|g" "${CONFIG_FILE}"

    if [ -n "$SSO_SAML_CERTIFICATE_NAME" ]; then
      sed -i "s|##SSO_SAML_CERTIFICATE_NAME##|${SSO_SAML_CERTIFICATE_NAME}|g" "${CONFIG_FILE}"
    fi

    if [ -n "$SSO_SAML_KEYSTORE_PASSWORD" ]; then
      sed -i "s|##SSO_SAML_KEYSTORE_PASSWORD##|${SSO_SAML_KEYSTORE_PASSWORD}|g" "${CONFIG_FILE}"
    fi

    if [ -n "$SSO_SAML_KEYSTORE" ] && [ -n "$SSO_SAML_KEYSTORE_DIR" ]; then
      sed -i "s|##SSO_SAML_KEYSTORE##|${SSO_SAML_KEYSTORE_DIR}/${SSO_SAML_KEYSTORE}|g" "${CONFIG_FILE}"
    fi
  else
    log_warning "Missing SSO_URL. Unable to properly configure SSO-enabled applications"
  fi

}

function set_curl() {
  CURL="curl -s"
  if [ -n "$SSO_DISABLE_SSL_CERTIFICATE_VALIDATION" ] && [[ $SSO_DISABLE_SSL_CERTIFICATE_VALIDATION == "true" ]]; then
    CURL="curl --insecure -s"
  elif [ -n "$SSO_TRUSTSTORE" ] && [ -n "$SSO_TRUSTSTORE_DIR" ] && [ -n "$SSO_TRUSTSTORE_CERTIFICATE_ALIAS" ]; then
    TMP_SSO_TRUSTED_CERT_FILE=`mktemp`
    keytool -exportcert -alias "$SSO_TRUSTSTORE_CERTIFICATE_ALIAS" -rfc -keystore ${SSO_TRUSTSTORE_DIR}/${SSO_TRUSTSTORE} -storepass ${SSO_TRUSTSTORE_PASSWORD} -file "$TMP_SSO_TRUSTED_CERT_FILE"
    CURL="curl -s --cacert $TMP_SSO_TRUSTED_CERT_FILE"
    unset TMP_SSO_TRUSTED_CERT_FILE
  fi
}

function enable_keycloak_deployments() {
  if [ -n "$SSO_OPENIDCONNECT_DEPLOYMENTS" ]; then
    AUTO_DEPLOY_EXPLODED="true"
    explode_keycloak_deployments $SSO_OPENIDCONNECT_DEPLOYMENTS $OPENIDCONNECT
  fi

  if [ -n "$SSO_SAML_DEPLOYMENTS" ]; then
    AUTO_DEPLOY_EXPLODED="true"
    explode_keycloak_deployments $SSO_SAML_DEPLOYMENTS $SAML
  fi
}

function explode_keycloak_deployments() {
  local sso_deployments="${1}"
  local auth_method="${2}"

  for sso_deployment in $(echo $sso_deployments | sed "s/,/ /g"); do
    if [ ! -d "${JBOSS_HOME}/standalone/deployments/${sso_deployment}" ]; then
      mkdir ${JBOSS_HOME}/standalone/deployments/tmp
      unzip -o ${JBOSS_HOME}/standalone/deployments/${sso_deployment} -d ${JBOSS_HOME}/standalone/deployments/tmp
      rm -f ${JBOSS_HOME}/standalone/deployments/${sso_deployment}
      mv ${JBOSS_HOME}/standalone/deployments/tmp ${JBOSS_HOME}/standalone/deployments/${sso_deployment}
    fi

    if [ -f "${JBOSS_HOME}/standalone/deployments/${sso_deployment}/WEB-INF/web.xml" ]; then
      requested_auth_method=`cat ${JBOSS_HOME}/standalone/deployments/${sso_deployment}/WEB-INF/web.xml | xmllint --nowarning --xpath "string(//*[local-name()='auth-method'])" - | sed ':a;N;$!ba;s/\n//g' | tr -d '[:space:]'`
      sed -i "s|${requested_auth_method}|${auth_method}|" "${JBOSS_HOME}/standalone/deployments/${sso_deployment}/WEB-INF/web.xml"
    fi
  done
}

function get_token() {

  token=""
  if [ -n "$SSO_USERNAME" ] && [ -n "$SSO_PASSWORD" ]; then
    token=`$CURL --data "username=${SSO_USERNAME}&password=${SSO_PASSWORD}&grant_type=password&client_id=admin-cli" ${sso_service}/realms/${SSO_REALM}/protocol/openid-connect/token`
    if [ $? -ne 0 ] || [[ $token != *"access_token"* ]]; then
      log_warning "Unable to connect to SSO/Keycloak at $sso_service for user $SSO_USERNAME and realm $SSO_REALM. SSO Clients *not* created"
      if [ -z "$token" ]; then
        log_warning "Reason: Check the URL, no response from the URL above, check if it is valid or if the DNS is resolvable."
      else
        log_warning "Reason: `echo $token | grep -Po '((?<=\<p\>|\<body\>).*?(?=\</p\>|\</body\>)|(?<="error_description":")[^"]*)' | sed -e 's/<[^>]*>//g'`"
      fi
      token=
    else
      token=`echo $token | grep -Po '(?<="access_token":")[^"]*'`
      log_info "Obtained auth token from $sso_service for realm $SSO_REALM"
    fi
  else
    log_warning "Missing SSO_USERNAME and/or SSO_PASSWORD. Unable to generate SSO Clients"
  fi

}

function configure_extension() {
  sed -i 's|<!-- ##KEYCLOAK_EXTENSION## -->|<extension module="org.keycloak.keycloak-adapter-subsystem"/><extension module="org.keycloak.keycloak-saml-adapter-subsystem"/>|' "${CONFIG_FILE}"
}

function configure_security_domain() {
  keycloak_security_domain=$(cat "${KEYCLOAK_SECURITY_DOMAIN_FILE}" | sed ':a;N;$!ba;s|\n|\\n|g')
  sed -i "s|<!-- ##KEYCLOAK_SECURITY_DOMAIN## -->|${keycloak_security_domain%$'\n'}|" "${CONFIG_FILE}"
}

function configure_subsystem() {
  auth_method=$1
  subsystem_file=$2
  subsystem_marker=$3
  protocol=$4
  deployment_file=$5

  keycloak_subsystem=$(cat "${subsystem_file}" | sed ':a;N;$!ba;s|\n|\\n|g')

  keycloak_deployment_subsystem=$(cat "${deployment_file}" | sed ':a;N;$!ba;s|\n|\\n|g')

  pushd $JBOSS_HOME/standalone/deployments
  files=*.war

  get_application_routes

  subsystem=
  deployments=
  redirect_path=

  for f in $files
  do
    module_name=
    if [[ $f != "*.war" ]];then
      web_xml=`read_web_dot_xml $f WEB-INF/web.xml`
      if [ -n "$web_xml" ]; then
        requested_auth_method=`echo $web_xml | xmllint --nowarning --xpath "string(//*[local-name()='auth-method'])" - | sed ':a;N;$!ba;s/\n//g' | tr -d '[:space:]'`

        if [[ $requested_auth_method == "${auth_method}" ]]
        then

          if [ -z "$subsystem" ]; then
            subsystem="${keycloak_subsystem}"
          fi

          if [[ $web_xml == *"<auth-method>${SAML}</auth-method>"* ]]
          then
            SPs="${SPs}${keycloak_saml_sp}"

            keycloak_deployment_subsystem=`echo "${keycloak_deployment_subsystem}" | sed "s|##KEYCLOAK_SAML_SP##|${SPs}|"`
          fi

          deployment=`echo "${keycloak_deployment_subsystem}" | sed "s|##KEYCLOAK_DEPLOYMENT##|${f}|"`

          if [[ $web_xml == *"<module-name>"* ]]; then
            module_name=`echo $web_xml | xmllint --nowarning --xpath "//*[local-name()='module-name']/text()" -`
          fi

          local jboss_web_xml=$(read_web_dot_xml $f WEB-INF/jboss-web.xml)
          if [ -n "$jboss_web_xml" ]; then
            if [[ $jboss_web_xml == *"<context-root>"* ]]; then
              context_root=`echo $jboss_web_xml | xmllint --nowarning --xpath "string(//*[local-name()='context-root'])" - | sed ':a;N;$!ba;s/\n//g' | tr -d '[:space:]'`
            fi
            if [ -n "$context_root" ]; then
              if [[ $context_root == /* ]]; then
                context_root="${context_root:1}"
              fi
            fi
          fi

          if [ $f == "ROOT.war" ]; then
            redirect_path=""
            if [ -z "$module_name" ]; then
              module_name="root"
            fi
          else
            if [ -n "$module_name" ]; then
              if [ -n "$context_root" ]; then
                redirect_path="${context_root}/${module_name}"
              else
                redirect_path=$module_name
              fi
            else
              if [ -n "$context_root" ]; then
                redirect_path=$context_root
                module_name=`echo $f | sed -e "s/.war//g"`
              else
                redirect_path=`echo $f | sed -e "s/.war//g"`
                module_name=$redirect_path
              fi
            fi
          fi

          if [ -n "$SSO_CLIENT" ]; then
            keycloak_client=${SSO_CLIENT}
          elif [ -n "$APPLICATION_NAME" ]; then
            keycloak_client=${APPLICATION_NAME}-${module_name}
          else
            keycloak_client=${module_name}
          fi

          if [ -n "$token" ]; then
            configure_client $module_name $protocol $APPLICATION_ROUTES
          fi

          if [ -n "$APPLICATION_NAME" ]; then
            deployment=`echo "${deployment}" | sed "s|##KEYCLOAK_ENTITY_ID##|${APPLICATION_NAME}-${module_name}|"`
          else
            deployment=`echo "${deployment}" | sed "s|##KEYCLOAK_ENTITY_ID##|${module_name}|"`
          fi

          deployments="${deployments} ${deployment}"

          deployments=`echo "${deployments}" | sed "s|##KEYCLOAK_CLIENT##|${keycloak_client}|" `
          deployments=`echo "${deployments}" | sed "s|##KEYCLOAK_SECRET##|${SSO_SECRET}|" `

          if [ -n "$SSO_ENABLE_CORS" ]; then
            deployments=`echo "${deployments}" | sed "s|##KEYCLOAK_ENABLE_CORS##|${SSO_ENABLE_CORS}|" `
          else
            deployments=`echo "${deployments}" | sed "s|##KEYCLOAK_ENABLE_CORS##|false|" `
          fi

          if [ -n "$SSO_BEARER_ONLY" ]; then
            deployments=`echo "${deployments}" | sed "s|##KEYCLOAK_BEARER_ONLY##|${SSO_BEARER_ONLY}|" `
          else
            deployments=`echo "${deployments}" | sed "s|##KEYCLOAK_BEARER_ONLY##|false|" `
          fi

          if [ -n "$SSO_SAML_LOGOUT_PAGE" ]; then
            deployments=`echo "${deployments}" | sed "s|##SSO_SAML_LOGOUT_PAGE##|${SSO_SAML_LOGOUT_PAGE}|" `
          else
            deployments=`echo "${deployments}" | sed "s|##SSO_SAML_LOGOUT_PAGE##|/|" `
          fi

          log_info "Configured keycloak subsystem for $protocol module $module_name from $f"
        fi
      fi
    fi
  done

  popd

  subsystem=`echo "${subsystem}" | sed "s|##KEYCLOAK_DEPLOYMENT_SUBSYSTEM##|${deployments}|" `

  if [ -n "$token" ]; then
    # SSO Server 7.0
    realm_certificate=`$CURL -H "Accept: application/json" -H "Authorization: Bearer ${token}" ${sso_service}/admin/realms/${SSO_REALM} | grep -Po '(?<="certificate":")[^"]*'`
    if [ -z "$realm_certificate" ]; then
      #SSO Server 7.1
      realm_certificate=`$CURL -H "Accept: application/json" -H "Authorization: Bearer ${token}" ${sso_service}/admin/realms/${SSO_REALM}/keys | grep -Po '(?<="certificate":")[^"]*'`
    fi
  fi

  if [ -n "$realm_certificate" ]; then
    keys="<Keys><Key signing=\"true\" ><CertificatePem>${realm_certificate}</CertificatePem></Key></Keys>"
    subsystem=`echo "${subsystem}" | sed "s|<!-- ##KEYCLOAK_REALM_CERTIFICATE## -->|${keys}|g"`

    validate_signature=true
    if [ -n "$SSO_SAML_VALIDATE_SIGNATURE" ]; then
      validate_signature="$SSO_SAML_VALIDATE_SIGNATURE"
    fi

    subsystem=`echo "${subsystem}" | sed "s|##KEYCLOAK_VALIDATE_SIGNATURE##|${validate_signature}|g"`
  else
    subsystem=`echo "${subsystem}" | sed "s|##KEYCLOAK_VALIDATE_SIGNATURE##|false|g"`
  fi

  if [ -n "$subsystem" ]; then
    sed -i "s|<!-- ${subsystem_marker} -->|${subsystem%$'\n'}|" "${CONFIG_FILE}"
  fi
}

function configure_client() {
  module_name=$1
  protocol=$2
  application_routes=$3

  IFS_save=$IFS
  IFS=";"
  redirects=""
  endpoint=""
  for route in ${application_routes}; do
    if [ -n "$redirect_path" ]; then
      redirects="$redirects,\"${route}/${redirect_path}/*\""
      endpoint="${route}/${redirect_path}/"
    else
      redirects="$redirects,\"${route}/*\""
      endpoint="${route}/"
    fi
  done
  redirects="${redirects:1}"
  IFS=$IFS_save

  if [[ $protocol == "saml" ]]
  then
    client_config="{\"adminUrl\":\"${endpoint}saml\""
    if [ -n "$SSO_SAML_KEYSTORE" ] && [ -n "$SSO_SAML_KEYSTORE_DIR" ] && [ -n "$SSO_SAML_CERTIFICATE_NAME" ] && [ -n "$SSO_SAML_KEYSTORE_PASSWORD" ]; then
      $JAVA_HOME/jre/bin/keytool -export -keystore ${SSO_SAML_KEYSTORE_DIR}/${SSO_SAML_KEYSTORE} -alias $SSO_SAML_CERTIFICATE_NAME -storepass $SSO_SAML_KEYSTORE_PASSWORD -file $JBOSS_HOME/standalone/configuration/keycloak.cer
      base64 $JBOSS_HOME/standalone/configuration/keycloak.cer > $JBOSS_HOME/standalone/configuration/keycloak.pem
      pem=`cat $JBOSS_HOME/standalone/configuration/keycloak.pem | sed ':a;N;$!ba;s/\n//g'`

      server_signature=
      if [ -n "$SSO_SAML_VALIDATE_SIGNATURE" ]; then
        server_signature=",\"saml.server.signature\":\"${SSO_SAML_VALIDATE_SIGNATURE}\""
      fi
      client_config="${client_config},\"attributes\":{\"saml.signing.certificate\":\"${pem}\"${server_signature}}"
    fi
  else
    service_addr=`hostname -i`
    client_config="{\"redirectUris\":[${redirects}]"

    if [ -n "$HOSTNAME_HTTP" ]; then
      client_config="${client_config},\"adminUrl\":\"http://\${application.session.host}:8080/${redirect_path}\""
    else
      client_config="${client_config},\"adminUrl\":\"https://\${application.session.host}:8443/${redirect_path}\""
    fi
  fi

  if [ -n "$SSO_BEARER_ONLY" ] && [ "$SSO_BEARER_ONLY" == "true" ]; then
    client_config="${client_config},\"bearerOnly\":\"true\""
  fi

  client_config="${client_config},\"clientId\":\"${keycloak_client}\""
  client_config="${client_config},\"protocol\":\"${protocol}\""
  client_config="${client_config},\"baseUrl\":\"${endpoint}\""
  client_config="${client_config},\"rootUrl\":\"\""
  client_config="${client_config},\"publicClient\":\"false\",\"secret\":\"${SSO_SECRET}\""
  client_config="${client_config}}"

  result=`$CURL -H "Content-Type: application/json" -H "Authorization: Bearer ${token}" -X POST -d "${client_config}" ${sso_service}/admin/realms/${SSO_REALM}/clients`

  if [ -n "$result" ]; then
    log_warning "ERROR: Unable to register $protocol client for module $module_name in realm $SSO_REALM on $redirects: $result"
  else
    log_info "Registered $protocol client for module $module_name in realm $SSO_REALM on $redirects"
  fi
}

function read_web_dot_xml {
  local jarfile="${1}"
  local filename="${2}"
  local result=

  if [ -d "$jarfile" ]; then
    if [[ -n "$AUTO_DEPLOY_EXPLODED" && "$AUTO_DEPLOY_EXPLODED" == "true" ]] || [[ -n "$JAVA_OPTS_APPEND" && $JAVA_OPTS_APPEND == *"Xdebug"* ]]; then
      if [ -e "${jarfile}/${filename}" ]; then
        result=`cat ${jarfile}/${filename}`
      fi
    fi
  else
    file_exists=`unzip -l "$jarfile" "$filename"`
    if [[ $file_exists == *"$filename"* ]]; then
      result=`unzip -p "$jarfile" "$filename" | xmllint --format --recover --nowarning - | sed ':a;N;$!ba;s/\n//g'`
    fi
  fi
  echo "$result"
}

function get_application_routes {

  if [ -n "$HOSTNAME_HTTP" ]; then
    route="http://${HOSTNAME_HTTP}"
  fi

  if [ -n "$HOSTNAME_HTTPS" ]; then
    secureroute="https://${HOSTNAME_HTTPS}"
  fi

  if [ -n "$route" ] && [ -n "$secureroute" ]; then
    APPLICATION_ROUTES="${route};${secureroute}"
  elif [ -n "$route" ]; then
    APPLICATION_ROUTES="${route}"
  elif [ -n "$secureroute" ]; then
    APPLICATION_ROUTES="${secureroute}"
  fi

}
