docker run -itd -h kafdrop --name kafdrop --network host -p 9000:9000 \
    -e KAFKA_BROKERCONNECT="10.1.175.96:30001" \
    obsidiandynamics/kafdrop