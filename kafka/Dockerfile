FROM anapsix/alpine-java:8u131b11_jdk

MAINTAINER hyrrot

ARG KAFKA_SCALA_VERSION=${KAFKA_SCALA_VERSION}
ARG KAFKA_BINARY_VERSION=${KAFKA_BINARY_VERSION}

ENV 

RUN \
  cd && \
  wget http://ftp.yz.yamagata-u.ac.jp/pub/network/apache/kafka/${KAFKA_BINARY_VERSION}/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_BINARY_VERSION}.tgz && \
  tar zxf kafka_${KAFKA_SCALA_VERSION}-${KAFKA_BINARY_VERSION}.tgz && \
  ln -s kafka_${KAFKA_SCALA_VERSION}-${KAFKA_BINARY_VERSION} kafka

CMD ["/root/kafka/bin/kafka-server-start.sh"]
