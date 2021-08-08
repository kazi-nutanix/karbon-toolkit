#!/usr/bin/env bash
# this script is test and verfied against karbon 2.2.1 only
set -e

now=$(date)
userName=kazi-nutanix
secretName=git-docker
token=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
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
kubectl create -f deployments/git-pkg-secret.yaml