#!/bin/bash

# Install SNMP packages
sudo yum -y install net-snmp net-snmp-libs

# Backup/Move
sudo mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.bak

# Configure SNMP
cat > /etc/snmp/snmpd.conf <<- "EOF"
###############################################################################
#
# snmpd.conf:
#   An example configuration file for configuring the ucd-snmp snmpd agent.
#
###############################################################################
#
# This file is intended to only be as a starting point.  Many more
# configuration directives exist than are mentioned in this file.  For
# full details, see the snmpd.conf(5) manual page.
#
# All lines beginning with a '#' are comments and are intended for you
# to read.  All other lines are configuration commands for the agent.

###############################################################################
# Access Control
###############################################################################
agentAddress udp:52161

# First, map the community name "public" into a "security name"

#       sec.name  source          community
#com2sec notConfigUser  default       public

rocommunity UAzHp6PfMs

####
# Second, map the security name into a group name:

#       groupName      securityModel securityName
group   notConfigGroup v1           notConfigUser
group   notConfigGroup v2c           notConfigUser

####
# Third, create a view for us to let the group have rights to:

# Make at least  snmpwalk -v 1 localhost -c public system fast again.
#       name           incl/excl     subtree         mask(optional)
view    systemview    included   .1.3.6.1.2.1.1
view    systemview    included   .1.3.6.1.2.1.25.1.1

####
# Finally, grant the group read-only access to the systemview view.

#       group          context sec.model sec.level prefix read   write  notif
access  notConfigGroup ""      any       noauth    exact  systemview none none

###############################################################################
# System contact information
#

# It is also possible to set the sysContact and sysLocation system
# variables through the snmpd.conf file:

sysLocation    Azure HUB
sysContact     EQB admin sysadmin@eqbank.ca

EOF

# Enable SNMP service (start on boot)
sudo systemctl enable snmpd.service

# Restart SNMP service
sudo systemctl restart snmpd.service

# Allow access to SNMP service
echo "snmpd: ALL" >> /etc/hosts.allow