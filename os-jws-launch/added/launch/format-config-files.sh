# CLOUD-2025 - Format the *-openshift.xml configuration files
function postConfigure() {
    format_xml
}

function format_xml() {
    mv $JWS_HOME/conf/server.xml $JWS_HOME/conf/server.xml.bkp
    #format and write the new file
    xmllint --format $JWS_HOME/conf/server.xml.bkp > $JWS_HOME/conf/server.xml

    mv $JWS_HOME/conf/context.xml $JWS_HOME/conf/context.xml.bkp
    #format and write the new file
    xmllint --format $JWS_HOME/conf/context.xml.bkp > $JWS_HOME/conf/context.xml
}