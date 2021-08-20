
kubectl get nodes -o wide --context $1-context | grep node > nodes
while read line
do
   words=( $line )
   IP=$(echo ${words[5]})
   IPs=${IP}\,${IPs}
done < nodes
NGINX_EXTERNAL_IPS=${IPs%?}
echo ${NGINX_EXTERNAL_IPS}