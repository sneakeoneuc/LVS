#!/bin/bash

RELEASE=$(cat /etc/os-release | grep 'NAME')
ID=$(cat /etc/os-release | grep 'ID')

Ubuntu='ubuntu'
Centos='centos'
RHEL='rhel'
OsVersion='NULL'
InstallLimit='NULL'

if [[ "${RELEASE,,}" == *"$Ubuntu"* ]]; then

  apt-get update -y
  apt-get install -y yum

  if grep -q "installonly_limit" /etc/yum/yum.conf; then 
    sed -ir "s/^[#]*\s*installonly_limit=.*/installonly_limit=2/" /etc/yum/yum.conf
  else
    # PUT installonly_limit on the second line
    sed -i "2 i\installonly_limit=2" /etc/yum/yum.conf
  fi  
  
  OsVersion="version="$Ubuntu
  InstallLimit=$(cat /etc/yum/yum.conf | grep 'installonly_limit')
elif [[ "${RELEASE,,}" == *"$Centos"* ]]; then
  sed -ir "s/^[#]*\s*installonly_limit=.*/installonly_limit=2/" /etc/yum.conf
  OsVersion="version="$Centos
  InstallLimit=$(cat /etc/yum.conf | grep 'installonly_limit')
elif [[ "${ID,,}" == *"$RHEL"* ]]; then

  if grep -q "installonly_limit" /etc/yum.conf; then 
    sed -ir "s/^[#]*\s*installonly_limit=.*/installonly_limit=2/" /etc/yum.conf
  else
    # PUT installonly_limit on the second line
    sed -i "2 i\installonly_limit=2" /etc/yum.conf
  fi  
 

  OsVersion="version="$RHEL
  InstallLimit=$(cat /etc/yum.conf | grep 'installonly_limit')
else
  OsVersion='NULL'
fi

echo $OsVersion
echo $InstallLimit