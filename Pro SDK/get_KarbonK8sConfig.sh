#!/usr/bin/env bash
# this script is test and verfied against karbon 2.2.1 only
set -e

now=$(date)
KUBECONFIG_PATH="$HOME/.kube"
mkdir -p ${KUBECONFIG_PATH}
source $SERVER_CONFIG/data.cfg
SVC_ACCOUNT_PASSWORD=$PRISM_PASSWD

function join { local IFS="$1"; shift; echo "$*"; }

rm -f clusters 2> /dev/null

echo "$now Fetching clusters access information"

KARBON_API_ENDPOINT="https://$PRISM_IP:9440/karbon/v1-beta.1/k8s/clusters"
curl -ks --request GET --url ${KARBON_API_ENDPOINT} -H 'Content-Type: application/json' -u ${PRISM_USER}:${SVC_ACCOUNT_PASSWORD} | jq -r '.[].name' > clusters

karbon_files=()
while read line
do
      words=( $line )
      CLUSTER=$(echo ${words[0]})      
      #UUID=$(echo ${words[1]})
      echo "$now Getting certificate for $CLUSTER" 
      karbon_file="$KUBECONFIG_PATH/$CLUSTER.cfg"
      KARBON_API_ENDPOINT="https://$PRISM_IP:9440/karbon/v1/k8s/clusters/$CLUSTER/kubeconfig"    
      #eval "/usr/local/bin/karbonctl --ip=$PRISM_IP --port=$PRISM_PORT --user=$PRISM_USER --password=$SVC_ACCOUNT_PASSWORD kubecfg $UUID  > $karbon_file"
      curl -ks --request GET --url ${KARBON_API_ENDPOINT} -H 'Content-Type: application/json' -u ${PRISM_USER}:${SVC_ACCOUNT_PASSWORD} > temp_out.json
      cat temp_out.json | jq -r '.kube_config' > $karbon_file
      #| sed 's/\\n/\n/g' 
      #cp temp_out.json $karbon_file
      #cat $karbon_file 
      #echo "$now Getting ssh files for $CLUSTER"
      karbon_files+=($karbon_file)      
      #ssh_access_file="$PROJECT_PATH/$CLUSTER-ssh-access.json"
       
      KARBON_API_ENDPOINT="https://$PRISM_IP:9440/karbon/v1/k8s/clusters/$CLUSTER/ssh"
      curl -ks --request GET --url ${KARBON_API_ENDPOINT} -H 'Content-Type: application/json' -u ${PRISM_USER}:${SVC_ACCOUNT_PASSWORD} > temp_out.json   
#private_key=$(cat temp_out.json | jq .private_key | tr -d "\"" | sed 's/\\n/\n/g')
     # echo $private_key 
      private_key_file=~/.ssh/$CLUSTER
      if [ -f "$private_key_file" ]; then
       chmod 777 $private_key_file
      fi 
      
      #cat temp_out.json | jq .private_key | tr -d "\"" | sed 's/\\n/\n/g' > $private_key_file
      cat temp_out.json | jq -r '.private_key' > $private_key_file
      chmod 0400 $private_key_file
      user_cert_file=~/.ssh/$CLUSTER.pub
      cat temp_out.json | jq -r '.certificate' > $user_cert_file
      #cat temp_out.json | jq .certificate | tr -d "\"" | sed 's/\\n/\n/g' > $user_cert_file
    
  
done < clusters

result=$(join : ${karbon_files[@]})
KUBECONFIG=$result kubectl config view --merge --flatten > "${KUBECONFIG}"

now=$(date)

echo "$now sucessfully retrieved access information for clusters"
