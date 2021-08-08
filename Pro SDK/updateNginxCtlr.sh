#!/bin/bash

#-------------------------------------------------------------------------------#
# Get worker node ips
#-------------------------------------------------------------------------------#
kubectl get nodes -o wide --context $1-context | grep node > nodes
while read line
do
   words=( $line )
   IP=$(echo ${words[5]})
   IPs=${IP}\,${IPs}
   # Commented because Cannot login to artifactory, will exit on the first iteration because artifactory returns an 503 error
   # echo "- Creating certificate folder in worker node $IP"
   # ssh -n -i $ARTIFACTS_FOLDER/cluster_$cluster_uuid -o "StrictHostKeyChecking no" "$WN_USER@$IP" "sudo mkdir -p -m 777 /etc/docker/certs.d             /$WN_FOLDER_CERT/"  < /dev/null
   # echo "Copying Certificates to worker node $IP"
   # `scp -i "$ARTIFACTS_FOLDER/cluster_$cluster_uuid" -o "StrictHostKeyChecking no" "$ARTIFACTORY_CERTIFICATE_PATH/$ARTIFACTORY_CERTIFICATE"              "$WN_USER@$IP:/etc/docker/certs.d/$WN_FOLDER_CERT/"`
   # echo "Setting up artifactory docker registry on worker node $IP"
   # ssh -n -i $ARTIFACTS_FOLDER/cluster_$cluster_uuid -o "StrictHostKeyChecking no" "$WN_USER@$IP" "sudo docker login $ARTIFACTORY_URL -u $A             RTIFACTORY_USER -p $ARTIFACTORY_PASSWORD"

done < nodes
NGINX_EXTERNAL_IPS=${IPs::-1}

#-------------------------------------------------------------------------------#
# Setup of nginx-ingress #
#-------------------------------------------------------------------------------#
echo $NGINX_EXTERNAL_IPS
helm install $NGINX_CHART $ARTIFACTS_FOLDER/nginx-ingress -n $NGINX_NS --set controller.service.type=NodePort --set controller.service.externalIPs={${NGINX_EXTERNAL_IPS}} --kube-context $1-context
