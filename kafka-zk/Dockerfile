FROM anapsix/alpine-java:8u131b11_jdk

RUN \
  cp ./boostrap.sh /root &&
  chmod +x /root/bootstrap.sh &&
  cd &&
  wget http://ftp.yz.yamagata-u.ac.jp/pub/network/apache/kafka/0.10.2.1/kafka_2.12-0.10.2.1.tgz &&
  tar zxf kafka_2.12-0.10.2.1.tgz &&
  ln -s kafka_2.12-0.10.2.1 kafka

CMD ["/root/bootstrap.sh"]
