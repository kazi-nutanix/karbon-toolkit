#!/bin/bash
source /etc/server_config/data.cfg

evaluate_command (){
#   RESULT=$($1)
   RESULT=$($1 > /dev/null 2>&1)
   if [ "$?" == 0 ]; then
      echo "$2 ....successful"
#      echo Result $RESULT
   else
      echo "## $2 couldn't be deployed correctly. This is the output of the command > $1 < ##"
#      echo $RESULT
      exit 1
   fi
#   sleep 1
}

#ARTIFACTS_FOLDER="${ARTIFACTS_FOLDER}/artifacts"

echo "#----------------------------------------#"
echo "Process to setup NFS Server for Blueprints"
echo "#----------------------------------------#"

#-------------------------------------------------------------------------------#
# Unzip package with all the artifacts #
#-------------------------------------------------------------------------------#
#evaluate_command "cp -rf $ARTIFACTS_FOLDER/jfrog /usr/local/bin" "- Copying jfrog to /usr/local/bin"
#evaluate_command "sudo yum localinstall $ARTIFACTS_FOLDER/nfs-utils-1.3.0-0.65.el7.x86_64.rpm -y" "- Installing nfs-utils"

#-------------------------------------------------------------------------------#
# Configure NFS server #
#-------------------------------------------------------------------------------#
#evaluate_command "sudo mkdir -p $MOUNTPOINT" "- Creation of mountpoint"
evaluate_command "mkdir -p $MOUNTPOINT/secrets" "- Creation of secrets directory in $MOUNTPOINT"
#evaluate_command "chmod -R 777 $MOUNTPOINT" "- Assing permissions to $MOUNTPOINT"
evaluate_command "`echo \"false\" > $MOUNTPOINT/secrets/slave-to-master-security-kill-switch`" "- Set to false Access Control for jenkins within mountpoint"
#evaluate_command "chmod 777 /etc/exports" "- Change permissions to exports file"
echo "$MOUNTPOINT  *(ro,sync,no_root_squash,no_all_squash)" | tee -a /etc/exports > /dev/null 2>&1

evaluate_command "`uniq /etc/exports > temp`" "- Make sure exports has unique entries"
evaluate_command "`cat temp > /etc/exports`" "- Adding unique lines to exports files"
#evaluate_command "chmod 644 /etc/exports" "- Change permissions to Read to exports file"
evaluate_command "rm -fr temp" "- Deleting temporary files"

evaluate_command "sudo systemctl restart nfs" "- Restarting NFS server"


#-------------------------------------------------------------------------------#
# Setup cronjob to refresh NFS drive with plugins #
#-------------------------------------------------------------------------------#
evaluate_command "mkdir -p $NFS_CONFIG" "- Creating folder for NFS script to refresh plugins"
evaluate_command "`echo \"export JFROG_CLI_OFFER_CONFIG=false\" >> ~/.bashrc`" "- Updating JFROG_CONFIG_CLI to false"
source ~/.bashrc
evaluate_command "`echo '#!/bin/bash' > $NFS_CONFIG/refresh_nfs.sh`" "- Creating script for cronjob to refresh NFS"
evaluate_command "`echo -e \"/usr/local/bin/jfrog rt dl --url $ARTIFACTORY_URL/artifactory/ --user $ARTIFACTORY_USER --password $ARTIFACTORY_PASSWORD $ARTIFACTORY_REPO  $MOUNTPOINT/\nsudo exportfs -a\" >> $NFS_CONFIG/refresh_nfs.sh`" "- Appending commands to refresh NFS to script"
evaluate_command "chmod 755 $NFS_CONFIG/refresh_nfs.sh" "- Assign permissionts to nfs script"
evaluate_command "`echo \"*/2 * * * * $NFS_CONFIG/refresh_nfs.sh\" >> $NFS_CONFIG/crontemp`" "- Creating cronjob to refresh NFS every 2 minutes"
evaluate_command "crontab $NFS_CONFIG/crontemp" "- Setting up cronjob to refresh plugins every 2 minutes "
evaluate_command "rm -fr $NFS_CONFIG/crontemp" "- Deleting temp files for cronjob"

echo "#-------------------------------------#"
echo "NFS Server is ready!"
echo "#-------------------------------------#"
