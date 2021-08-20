#!/bin/bash
set -e

source /etc/server_config/data.cfg

now=$(date)

echo "$now Removing plugins from $NFS_PATH"
rm -rf $NFS_PATH*

echo "$now Fetching plugins from artifactory"

SVC_ACCOUNT_PASSWORD=$(/usr/local/bin/acc-password --host usmlb1caweb1p.cs.myharris.net --app-id CHQ-IHO-EngApps --safe CHQ-easw_automation --object-name "Operating System-HRSDomainAuto-Service-180-cs.myharris.net-SVC-easwAP")

echo $SVC_ACCOUNT_PASSWORD

/usr/local/bin/jfrog rt dl --url https://easw.lnsvr0441.gcsd.harris.com:8443/artifactory/ --user SVC-easwAP --password $SVC_ACCOUNT_PASSWORD jenkins-plugins  $NFS_PATH
sudo exportfs -a
