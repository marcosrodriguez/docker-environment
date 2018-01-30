#!/usr/bin/env bash

show_instructions() {
    cat <<-EOF
    Start development environment, and all dependencies

    PARAMS:
    HOST_IP                   Host of the docker environment. If on linux, this will be localhost.
EOF
    exit 1
}

if [[ -z "$1"  ]]
then
    show_instructions
fi

export HOST_IP=$1

docker-compose down

docker build -t connect:latest connect-container
docker build -t hdfs:latest hdfs-container
docker-compose up -d zookeeper
sleep 10
docker-compose up -d
sleep 60


docker exec -it connect curl -X POST \
  -H "Content-Type: application/json" \
  --data '{ "name": "hdfs-sink-connector", "config": { "connector.class": "io.confluent.connect.hdfs.HdfsSinkConnector", "tasks.max": 1, "topics": "clients_topic", "hdfs.url": "hdfs://hdfs-master:9000", "hadoop.conf.dir": "/opt/hadoop/conf" ,"hadoop.home": "/opt/hadoop","flush.size": 1 } }' \
  http://localhost:8083/connectors


