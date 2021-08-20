#!/bin/bash
set -e
source $SERVER_CONFIG/data.cfg

if [ ! -z "$1" ]; then
    echo "Connecting $1 cluster"
else
    echo "A cluster name is needed"
   exit 1
fi

#-------------------------------------------------------------------------------#
# Iterage over each nodes and #
#-------------------------------------------------------------------------------#
kubectl get nodes -o wide --context=$1-context | grep node > nodes


echo "Checking ssh connection for nodes"
while read line
do
   words=( $line )
   IP=$(echo ${words[5]})
   ssh -n -i ~/.ssh/$1 -o "StrictHostKeyChecking no" "$WN_USER@$IP" "echo 2>&1" && echo "Can connect to $IP" || echo "Can't connect to $IP"
done < nodes

