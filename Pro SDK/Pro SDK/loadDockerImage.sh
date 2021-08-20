#!/bin/bash
set -e
source $SERVER_CONFIG/data.cfg


docker_image_path=$IMAGE_PATH
docker_image_name="utils.tgz"

#-------------------------------------------------------------------------------#
# Copy docker images to worker nodes #
#-------------------------------------------------------------------------------#
kubectl get nodes -o wide --context=$1-context | grep node > nodes
while read line
do
   words=( $line )
   IP=$(echo ${words[5]})
   echo "Copying $docker_image_name to  $IP"
   scp  ~/.ssh/$1  -o "StrictHostKeyChecking no" "$docker_image_path/$docker_image_name" "$WN_USER@$IP:/tmp"
   echo "Pushing $docker_image_name on  $IP"
   ssh -n -i ~/.ssh/$1 -o "StrictHostKeyChecking no" "$WN_USER@$IP" "sudo docker load -i /tmp/$docker_image_name"

done < nodes
