#!/bin/bash -x

HOSTS=`echo s100{1..6}`
CONSUL_SERVER_HOSTS=`echo s100{1..3}`
CONSUL_BOOTSTRAP_HOST="s1001"
CONSUL_CLIENT_HOSTS=`echo s100{4..6}`
CONSUL_DATACENTER=dc1

DNSMASQ_HOSTS=$HOSTS
REGISTRATOR_HOSTS=$HOSTS

KAFKA_ZK_NODES=`echo s100{1..3}`
KAFKA_BR_NODES=`echo s100{4..6}`

# Machine
#for host in $HOSTS ; do
#  docker-machine rm -f ${host}
#  docker-machine create ${host}
#done

# Consul Server
for host in ${CONSUL_SERVER_HOSTS}; do
  host_ip=$(docker-machine ip ${host})
  eval $(docker-machine env ${host})
  docker-compose kill consul
  docker-compose rm -f consul

  env CONSUL_DATACENTER=${CONSUL_DATACENTER} \
  CONSUL_HOST_IP=${host_ip} \
  CONSUL_BOOTSTRAP_SERVER=$(docker-machine ip ${CONSUL_BOOTSTRAP_HOST}) \
  CONSUL_SERVER_MODE="true" \
  docker-compose up -d consul
done

# Consul client
for host in ${CONSUL_CLIENT_HOSTS}; do
  host_ip=$(docker-machine ip ${host})
  eval $(docker-machine env ${host})
  docker-compose kill consul
  docker-compose rm -f consul

  env CONSUL_DATACENTER=${CONSUL_DATACENTER} \
  CONSUL_HOST_IP=${host_ip} \
  CONSUL_BOOTSTRAP_SERVER=$(docker-machine ip ${CONSUL_BOOTSTRAP_HOST}) \
  docker-compose up -d consul
done

# dnsmasq
for host in ${DNSMASQ_HOSTS}; do
  host_ip=$(docker-machine ip ${host})
  eval $(docker-machine env ${host})
  docker-compose kill dnsmasq
  docker-compose rm -f dnsmasq

  env DNSMASQ_HOST_IP=${host_ip} \
  docker-compose up --no-recreate -d dnsmasq
done


# Registrator
for host in ${REGISTRATOR_HOSTS}; do
  host_ip=$(docker-machine ip ${host})
  eval $(docker-machine env ${host})
  docker-compose kill registrator
  docker-compose rm -f registrator
  env REGISTRATOR_HOST_IP=${host_ip} \
  docker-compose up --no-recreate -d registrator
done

# Build Kafka image
pushd kafka
  KAFKA_SCALA_VERSION=2.10
  KAFKA_BINARY_VERSION=0.10.2.1
  env docker build .  \
   --build-arg KAFKA_SCALA_VERSION=${KAFKA_SCALA_VERSION}  \
   --build-arg KAFKA_BINARY_VERSION=${KAFKA_BINARY_VERSION} \
   -t hyrrot/kafka:${KAFKA_SCALA_VERSION}-${KAFKA_BINARY_VERSION}
  docker push hyrrot/kafka:${KAFKA_SCALA_VERSION}-${KAFKA_BINARY_VERSION}
popd

# Create Kafka Zookeeper
for line in ${KAFKA_ZK_NODES} ; do
    if [ ${line: -1} -eq $1 ]; then
        echo server.${line: -1}=0.0.0.0:2888:3888 ;
    else
        echo server.${line: -1}=${line}:2888:3888 ;
    fi
    zookeeper_endpoints="${line}:2181,$zookeeper_endpoints"
done >> config/zookeeper.properties


for host in ${KAFKA_ZK_NODES}; do
  host_ip=$(docker-machine ip ${host})
  eval $(docker-machine env ${host})

  zookeeper_endpoints=""
  for host2 in ${KAFKA_ZK_NODES} ; do
      if [ $host2 -eq $host ]; then
          echo server.$host2=0.0.0.0:2888:3888 ;
      else
          echo server.$host2=${host2}.node.consul:2888:3888 ;
      fi
      zookeeper_endpoints="${host2}:2181,$zookeeper_endpoints"
  done

  docker-compose kill kafka-zk
  docker-compose rm -f kafka-zk
  env ZK_ENDPOINTS=${zookeeper_endpoints: -1} \
  docker-compose up --no-recreate -d kafka-zk
done
