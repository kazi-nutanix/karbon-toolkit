#!/bin/bash
set -e

if [ ! -z "$1" ]; then
    echo "Updating $1 cluster"
else
    echo "A cluster name is needed"
   exit 1
fi

source $SERVER_CONFIG/data.cfg
#-------------------------------------------------------------------------------#
# Copy Artifactory certificate to worker nodes #
#-------------------------------------------------------------------------------#
kubectl get nodes -o wide --context=$1-context | grep node > nodes

cluster=$1
echo "Checking ssh connection for nodes"
while read line
do
   words=( $line )
   IP=$(echo ${words[5]})
   IPs=${IP}\,${IPs}
   echo "- Checking if can connect via ssh with node $IP"
ssh -n -i ~/.ssh/$cluster -o "StrictHostKeyChecking no" "$WN_USER@$IP" "echo 2>&1" && echo "Can connect to $IP" || echo "Cannot connect to $IP"
done < nodes

while read line
do
   words=( $line )
   IP=$(echo ${words[5]})
   IPs=${IP}\,${IPs}

   echo "- Copying Certificates to worker node on /tmp $IP"
   `scp -r  -i "~/.ssh/$cluster" -o "StrictHostKeyChecking no" "$CERTIFICATES_FOLDER/" "$WN_USER@$IP:/tmp/"`
   echo "- Move certicates to docker folder - $IP"
   `ssh -n  -i ~/.ssh/$cluster -o "StrictHostKeyChecking no" "$WN_USER@$IP" "cp /tmp/certificates/* /etc/docker/certs.d/$WN_FOLDER_CERT/"`
   echo "- Changing to 777 permission of trusted certificates on $IP"
   `ssh -n -i ~/.ssh/$cluster -o "StrictHostKeyChecking no" "$WN_USER@$IP" sudo chmod 777 /etc/pki/ca-trust/source/anchors/`
   echo "Copying Certificates to worker node trusted certificates on $IP"
   `ssh -n  -i ~/.ssh/$cluster -o "StrictHostKeyChecking no" "$WN_USER@$IP" "cp /tmp/certificates/* /etc/pki/ca-trust/source/anchors/"`
   echo "- Changing to 755 permission of trusted certificates on $IP"
   `ssh -n -i ~/.ssh/$cluster -o "StrictHostKeyChecking no" "$WN_USER@$IP" sudo chmod 755 /etc/pki/ca-trust/source/anchors/`
   echo "- Updating CA trust on $IP"
   `ssh -n -i ~/.ssh/$cluster -o "StrictHostKeyChecking no" "$WN_USER@$IP" sudo update-ca-trust extract`
   echo "Setting up artifactory docker registry on worker node $IP"
   ssh -n -i ~/.ssh/$cluster -o "StrictHostKeyChecking no" "$WN_USER@$IP" "sudo docker login $ARTIFACTORY_URL -u $ARTIFACTORY_USER -p $ARTIFACTORY_PASSWORD"

done < nodes