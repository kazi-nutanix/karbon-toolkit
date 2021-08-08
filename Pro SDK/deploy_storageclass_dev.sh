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
  nfsPath: /dev
  nfsServer: $NFS_SERVER
  storageType: NutanixFiles
provisioner: com.nutanix.csi
reclaimPolicy: Retain
volumeBindingMode: Immediate
EOF
