set_java_alternatives() {
  if [ "${USE_32_BIT_JVM^^}" = "TRUE" ]; then
    JavaHome32=`alternatives --display java | grep family | grep i386/ | awk '{print $1}' | sed 's|/jre/bin/java||'`
    echo "$JavaHome32"
  else
    echo "$JAVA_HOME"
  fi
}

