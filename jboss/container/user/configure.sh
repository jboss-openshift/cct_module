#!/bin/bash
set -e

# Create a user and group used to launch processes
# We use the ID 185 fot the group as well as for the user.
# This ID is registered static ID for the JBoss EAP product
# on RHEL which makes it safe to use.
groupadd -r jboss -g 185 && useradd -u 185 -r -g root -G jboss -m -d /home/jboss -s /sbin/nologin -c "JBoss user" jboss
chmod ug+rwX /home/jboss
chmod 664 /etc/passwd
##we create an empty known_hosts global if the user forgot to pass the known-hosts with the id_rsa
mkdir /etc/ssh/
>/etc/ssh/known_hosts
chmod 664 /etc/ssh/known_hosts