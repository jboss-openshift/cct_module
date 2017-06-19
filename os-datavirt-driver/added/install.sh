#!/bin/bash

set -e

# import the common functions for installing modules and configuring drivers
source /usr/local/s2i/install-common.sh

# should be the directory where this script is located
injected_dir=$1

# install the JDV JDBC client module
install_modules ${injected_dir}/modules

# configure the JDV JDBC driver in standalone.xml.  Driver is named "teiid"
configure_drivers ${injected_dir}/install.properties
