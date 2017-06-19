#!/bin/bash

source $JBOSS_HOME/bin/launch/launch-common.sh

# Arguments:
# $1 - code
# $2 - flag
# $3 - module
function configure_login_modules() {
    local login_module_code="${1}"
    local login_module_flag="${2}"
    local login_module_module="${3}"
    if [ "x${login_module_code}" != "x" ]; then
        if [ "x${login_module_flag}" = "x" ]; then
            login_module_flag="optional"
        fi
        local login_modules
        if [ "x${login_module_module}" != "x" ]; then
            login_modules="<login-module code=\"$login_module_code\" flag=\"$login_module_flag\" module=\"$login_module_module\"/>"
        else
            login_modules="<login-module code=\"$login_module_code\" flag=\"$login_module_flag\"/>"
        fi
        sed -i "s|<!-- ##OTHER_LOGIN_MODULES## -->|${login_modules}<!-- ##OTHER_LOGIN_MODULES## -->|" "$CONFIG_FILE"
    fi
}
