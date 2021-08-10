#!/usr/bin/env bash
# this script is test and verfied against karbon 2.2.1 only
set -e
if [ ! -z "$1" ]; then
    echo "Using namespace $1"
else
    echo "A namespace name is needed"
    exit 1
fi
source $SERVER_CONFIG/data.cfg
now=$(date)
userName=$CNTR_RGSTR_USER
secretName=git-docker
token=$CNTR_RGSTR_PASSWD
echo "Generating secret configuration $now"
base64Token=$(echo -n "$userName:$token" | base64)
base64DkrCfgToken=$(echo -n  '{"auths":{"ghcr.io":{"auth":'\"$base64Token\"'}}}' | base64 -w 0)
cat << EOF > deployments/git-pkg-secret.yaml
kind: Secret
type: kubernetes.io/dockerconfigjson
apiVersion: v1
metadata:
  name: $secretName
data:
  .dockerconfigjson: $base64DkrCfgToken
EOF
echo "Creating secret $secretName in the cluster at $now"
kubectl create -f deployments/git-pkg-secret.yaml -n $1