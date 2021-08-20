#!/usr/bin/env bash
# this script is test and verfied against karbon 2.2.1 only
set -e
if [ -z "$1" ]; then
    echo "A secret name is required. Try Again"
    exit 1
fi
if [ ! -z "$2" ]; then
    echo "Using namespace $2"
else
    echo "A namespace name is required. Try Again"
    exit 1
fi
source $SERVER_CONFIG/data.cfg
now=$(date)
userName=$CNTR_RGSTR_USER
secretName=$1
token=$CNTR_RGSTR_PASSWD
echo "Generating secret configuration $now"
base64Token=$(echo -n "$userName:$token" | base64)
dkrCfgString=$(echo -n '{"auths":{'\"$CNTR_RGSTR_SERVER_PORT\"':{"auth":'\"$base64Token\"'}}}')
base64DkrCfgToken=$(echo "$dkrCfgString" | base64 -w 0)
cat << EOF > deployments/$secretName-secret.yaml
kind: Secret
type: kubernetes.io/dockerconfigjson
apiVersion: v1
metadata:
  name: $secretName
data:
  .dockerconfigjson: $base64DkrCfgToken
EOF
echo "Creating secret $secretName in the cluster on $now"
kubectl create -f deployments/$secretName-secret.yaml -n $2