# bourne shell script snippet
# used by OpenShift JBoss Web Server launch script

source $JWS_HOME/bin/launch/logging.sh

function prepareEnv() {
  unset JWS_HTTPS_CERTIFICATE_DIR
  unset JWS_HTTPS_CERTIFICATE
  unset JWS_HTTPS_CERTIFICATE_KEY
  unset JWS_HTTPS_CERTIFICATE_PASSWORD
  unset JWS_SERVER_NAME
}

function configure() {
  configure_https
}

function configure_https() {
  https="<!-- No HTTPS configuration discovered -->"
  if [ -n "${JWS_HTTPS_CERTIFICATE_DIR}" -a -n "${JWS_HTTPS_CERTIFICATE}" -a -n "${JWS_HTTPS_CERTIFICATE_KEY}" ] ; then
      password=""
      if [ -n "${JWS_HTTPS_CERTIFICATE_PASSWORD}" ] ; then
          password=" SSLPassword=\"${JWS_HTTPS_CERTIFICATE_PASSWORD}\" "
      fi
      https="<Connector \
             protocol=\"org.apache.coyote.http11.Http11AprProtocol\" \
             port=\"8443\" maxThreads=\"200\" \
             scheme=\"https\" secure=\"true\" SSLEnabled=\"true\" \
             SSLCertificateFile=\"${JWS_HTTPS_CERTIFICATE_DIR}/${JWS_HTTPS_CERTIFICATE}\" \
             SSLCertificateKeyFile=\"${JWS_HTTPS_CERTIFICATE_DIR}/${JWS_HTTPS_CERTIFICATE_KEY}\" \
             ${password}  \
             SSLVerifyClient=\"optional\" SSLProtocol=\"TLSv1+TLSv1.1+TLSv1.2\""
    
      if [ -n "$JWS_SERVER_NAME" ]; then
        https="$https server=\"${JWS_SERVER_NAME}\""
      fi
 
      https="$https />"

  elif [ -n "${JWS_HTTPS_CERTIFICATE_DIR}" -o -n "${JWS_HTTPS_CERTIFICATE}" -o -n "${JWS_HTTPS_CERTIFICATE_KEY}" ] ; then
      log_warning "Partial HTTPS configuration, the https connector WILL NOT be configured."
  fi
  sed -i "s|### HTTPS_CONNECTOR ###|${https}|" $JWS_HOME/conf/server.xml
}
