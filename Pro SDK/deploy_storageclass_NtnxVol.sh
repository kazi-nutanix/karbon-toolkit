#!/bin/bash
set -e
source $SERVER_CONFIG/data.cfg
if ([ ! -z "$1" ] && [ ! -z "$2" ]); then
    echo "Updating $1 cluster"
else
    echo "A cluster name and a storageclass name are needed"
   exit 1
fi
cat <<EOF | kubectl apply --context $1-context -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: $2
  selfLink: /apis/storage.k8s.io/v1/storageclasses/$2
parameters:
  csiNodePublishSecretName: ntnx-secret-00058f77-f6d6-41de-0000-00000000a8c7
  csiNodePublishSecretNamespace: kube-system
  csiProvisionerSecretName: ntnx-secret-00058f77-f6d6-41de-0000-00000000a8c7
  csiProvisionerSecretNamespace: kube-system
  dataServiceEndPoint: 10.1.175.64:3260
  storageType: NutanixVolumes
  flashMode: DISABLED
  fsType: ext4
  storageContainer: ctr01
provisioner: com.nutanix.csi
reclaimPolicy: Retain
volumeBindingMode: Immediate
EOF
