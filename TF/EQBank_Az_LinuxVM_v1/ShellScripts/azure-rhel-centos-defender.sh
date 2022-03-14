#!/usr/bin/env bash

base64str=$1
tagValue=$2

[ -z $base64str ] && echo "No base64 provided" && exit 1

echo $base64str | base64 -d > /etc/py_script.py


yum install yum-utils -y
yum-config-manager --add-repo=https://packages.microsoft.com/config/centos/7/prod.repo
rpm --import http://packages.microsoft.com/keys/microsoft.asc
yum makecache
yum install mdatp -y


yum --enablerepo=packages-microsoft-com-prod install mdatp


mdatp health --field org_id


# Make sure python is installed
PYTHON=$(which python || which python3)

if [ -z $PYTHON ]; then
   script_exit "error: cound not locate python."
fi

$PYTHON /etc/py_script.py

sleep 60

echo "ORG_ID...." $(mdatp health --field org_id)
 

echo "HEALTHY STATUS...." $(mdatp health --field healthy)

echo $tagValue

mdatp edr tag set --name GROUP --value $tagValue