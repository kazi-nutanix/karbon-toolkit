 kafka-console-consumer.sh --bootstrap-server 10.1.175.96:30001 --topic test --from-beginning

kafka-console-producer.sh --broker-list 10.1.175.96:30001,10.1.175.172:30002,10.1.175.32:30003 --topic test

kubectl run kafka-demo-client --restart='Never' --image docker.io/bitnami/kafka:2.8.0-debian-10-r61 --namespace kafka --command -- sleep infinity
    kubectl exec --tty -i kafka-demo-client --namespace kafka -- bash