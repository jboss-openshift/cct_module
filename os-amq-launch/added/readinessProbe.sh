#!/bin/sh

if [ true = "${DEBUG}" ] ; then
    # short circuit readiness check in dev mode
    exit 0
fi

OUTPUT=/tmp/readiness-output
ERROR=/tmp/readiness-error
LOG=/tmp/readiness-log

CONFIG_FILE=$AMQ_HOME/conf/activemq.xml

COUNT=30
SLEEP=1
DEBUG_SCRIPT=false

EVALUATE_SCRIPT=`cat <<EOF
import xml.etree.ElementTree
from urlparse import urlsplit
import socket
import sys

# calculate the open ports
listening_ports = []
inputs = ["/proc/net/tcp6", "/proc/net/tcp"]
for input in inputs:
  try:
    tcp_file = open(input, "r")
    tcp_lines = tcp_file.readlines()
    header = tcp_lines.pop(0)
    tcp_file.close()

    for tcp_line in tcp_lines:
      stripped = tcp_line.strip()
      contents = stripped.split()
      # Is the status listening?
      if contents[3] == '0A':
        netaddr = contents[1].split(":")
        port = int(netaddr[1], 16)
        listening_ports.append(port)

  except IOError:
   pass

#parse the config file to retrieve the transport connectors
xmldoc = xml.etree.ElementTree.parse("${CONFIG_FILE}")

ns = {"core" : "http://activemq.apache.org/schema/core"}
transportConnectors = xmldoc.findall("core:broker/core:transportConnectors/core:transportConnector", ns)

result=0

for transportConnector in transportConnectors:
  name = transportConnector.get("name")
  uri = transportConnector.get("uri")
  spliturl = urlsplit(uri)
  port = spliturl.port

  print "{} port {}".format(name, port)

  if port == None:
    print "    {} does not define a port, cannot check transport".format(name)
    continue

  try:
    listening_ports.index(port)
    print "    Transport is listening on port {}".format(port)
  except ValueError, e:
    print "    Nothing listening on port {}, transport not yet running".format(port)
    result=1
sys.exit(result)
EOF`

if [ $# -gt 0 ] ; then
    COUNT=$1
fi

if [ $# -gt 1 ] ; then
    SLEEP=$2
fi

if [ $# -gt 2 ] ; then
    DEBUG_SCRIPT=$3
fi

if [ true = "${DEBUG_SCRIPT}" ] ; then
    echo "Count: ${COUNT}, sleep: ${SLEEP}" > "${LOG}"
fi

while : ; do
    CONNECT_RESULT=1
    PROBE_MESSAGE="No configuration file located: ${CONFIG_FILE}"

    if [ -f "${CONFIG_FILE}" ] ; then
        python -c "$EVALUATE_SCRIPT" >"${OUTPUT}" 2>"${ERROR}"

        CONNECT_RESULT=$?
        if [ true = "${DEBUG_SCRIPT}" ] ; then
            (
                echo "$(date) Connect: ${CONNECT_RESULT}"
                echo "========================= OUTPUT =========================="
                cat "${OUTPUT}"
                echo "========================= ERROR =========================="
                cat "${ERROR}"
                echo "=========================================================="
            ) >> "${LOG}"
        fi

        PROBE_MESSAGE="No transport listening on ports $(grep "Nothing listening" "${OUTPUT}" | sed -e 's+^.*on port ++' -e 's+,.*$++')"
        rm -f  "${OUTPUT}" "${ERROR}"
    fi

    if [ "${CONNECT_RESULT}" -eq 0 ] ; then
        exit 0;
    fi

    COUNT=$(expr "$COUNT" - 1)
    if [ "$COUNT" -eq 0 ] ; then
        echo ${PROBE_MESSAGE}
        exit 1;
    fi
    sleep "${SLEEP}"
done
