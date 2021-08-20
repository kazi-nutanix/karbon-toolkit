#!/bin/bash

set -e

if [ ! -z "$1" ]; then
    echo "Updating $1 cluster"
else
    echo "A cluster name is needed"
   exit 1
fi


echo "- Setting up env variables"
source "$SERVER_CONFIG/data.cfg"
SVC_ACCOUNT_PASSWORD=$PRISM_PASSWD

if [ -f $KUBECONFIG ]; then
   echo "- Testing connection with cluster"
   kubectl cluster-info --context $1-context
else
   echo "## Kubeconfig.cfg file, that include the info to connect to Karbon cluster, doesn't exists ##"
fi

kubectl get nodes -o wide --context $1-context | grep node > nodes
while read line
do
   words=( $line )
   IP=$(echo ${words[5]})
   IPs=${IP}\,${IPs}
done < nodes
NGINX_EXTERNAL_IPS=${IPs%?}

#-------------------------------------------------------------------------------#
# Setup of nginx-ingress #
#-------------------------------------------------------------------------------#
#kubectl delete ns $NGINX_NS --context $1-context
kubectl create ns $NGINX_NS --context $1-context
# secret creation turned off for public repo otherwiseh uncomment it and replace appropriate variabels in the data.cfg
#kubectl create secret docker-registry regcred --docker-server="$DOCKER_ARTIFACTORY_URL" --docker-username="$ARTIFACTORY_USER" --docker-password="$ARTIFACTORY_PASSWORD" --docker-email=mail@example.com -n $NGINX_NS --context $1-context 
#helm install $NGINX_CHART $ARTIFACTS_FOLDER/nginx-ingress -n $NGINX_NS --set controller.service.type=NodePort --set controller.service.externalIPs={${NGINX_EXTERNAL_IPS}} --kube-context $1-context
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
#install latest or specefied version
echo "nginx versin $NGINX_VERSION"
if [ -f $NGINX_VERSION ]; then
 helm install $NGINX_CHART nginx-stable/nginx-ingress -n $NGINX_NS --set controller.service.type=NodePort --set controller.service.externalIPs={${NGINX_EXTERNAL_IPS}} --kube-context $1-context
else
  helm install $NGINX_CHART nginx-stable/nginx-ingress --version $NGINX_VERSION -n $NGINX_NS --set controller.service.type=NodePort --set controller.service.externalIPs={${NGINX_EXTERNAL_IPS}} --kube-context $1-context 
fi
echo "#-------------------------------------#"
echo "      Installation is done!"
echo "#-------------------------------------#"
