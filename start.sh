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

docker build -t hdfs:latest hdfs-container

docker-compose up -d zk
sleep 10
docker-compose up -d kafka-broker-1
sleep 10
docker-compose up -d kafka-broker-2
sleep 10
docker-compose up -d kafka-broker-3
sleep 10
docker-compose up -d kafka_connect
sleep 10
docker-compose up -d 
sleep 10

docker exec -it kafka_connect curl -X POST \
  -H "Content-Type: application/json" \
  --data '{ "name": "hdfs-sink", "config": { "connector.class": "io.confluent.connect.hdfs.HdfsSinkConnector", "tasks.max": 1, "topics": "clients_topic", "hdfs.url": "hdfs://hdfs-master:9000","flush.size": 3 } }' \
  http://localhost:8083/connectors

docker exec -it kafka_connect curl -X POST \
  -H "Content-Type: application/json" \
  --data '{ "name": "csv-file-source", "config": { "connector.class": "FileStreamSource", "tasks.max": 1, "topic": "clients_topic", "file": "/tmp/prueba.csv" } }' \
  http://localhost:8083/connectors

#docker exec -it kafka_connect curl -X DELETE http://localhost:8083/connectors/csv-file-source


