# CLOUD-2025 - Format the *-openshift.xml configuration files
function postConfigure() {
    format_xml
}

function format_xml() {
    mv $CONFIG_FILE $CONFIG_FILE.bkp
    #format and write the new file
    xmllint --format $CONFIG_FILE.bkp > $CONFIG_FILE
}