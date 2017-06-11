wget http://ftp.yz.yamagata-u.ac.jp/pub/network/apache/kafka/0.10.2.1/kafka_2.12-0.10.2.1.tgz
tar zxf kafka_2.12-0.10.2.1.tgz
pushd kafka_2.12-0.10.2.1

# Setup Zookeeper
echo "tickTime=2000" >> config/zookeeper.properties
echo "initLimit=5" >> config/zookeeper.properties
echo "syncLimit=2" >> config/zookeeper.properties

zookeeper_endpoints=""

kafka_nodes=`cat /etc/hosts | grep "kafka-zk" | grep -v "127.0.0.1" | awk '{print $2}'`

for line in $kafka_nodes ; do
    if [ ${line: -1} -eq $1 ]; then
        echo server.${line: -1}=0.0.0.0:2888:3888 ;
    else
        echo server.${line: -1}=${line}:2888:3888 ;
    fi
    zookeeper_endpoints="${line}:2181,$zookeeper_endpoints"
done >> config/zookeeper.properties

mkdir -p /tmp/zookeeper
echo $1 > /tmp/zookeeper/myid
mkdir logs

bin/zookeeper-server-start.sh config/zookeeper.properties > logs/zookeeper.out 2> logs/zookeeper.err &
