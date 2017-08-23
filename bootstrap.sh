#!/bin/bash

rm -f /tmp/*.pid

if [ ! -d /data/nn/current ]; then
	echo "=== FORMATING NAMENODE ==="
	service hadoop-hdfs-namenode init

    echo "=== STARTING NAMENODE ==="
    service hadoop-hdfs-namenode start
    echo "=== STARTING DATANODE ==="
    service hadoop-hdfs-datanode start

    hdfs dfs -mkdir /user
    hdfs dfs -chmod 755 /user
    hdfs dfs -mkdir /user/impala
    hdfs dfs -mkdir /user/hive
    hdfs dfs -mkdir /tmp
    hdfs dfs -chmod 777 /tmp
    #sudo -iu hdfs hdfs dfs -chown impala:impala /user/impala
    #sudo -iu hdfs hdfs dfs -chown impala:impala /user/hive
else
    echo "=== STARTING NAMENODE ==="
    service hadoop-hdfs-namenode start
    echo "=== STARTING DATANODE ==="
    service hadoop-hdfs-datanode start
fi

echo "=== VERIFICANDO EXISTENCIA DOS METADADOS ==="
SCHEMA=`$HIVE_HOME/bin/schematool -dbType mysql -info | grep "schemaTool completed"`

# Verifica se o schema já está inicializa, caso negativo o inicializa
if [[ ! $SCHEMA ]]; then
  echo "=== CRIANDO METADADOS ==="
  $HIVE_HOME/bin/schematool -dbType mysql -initSchema
else
  echo "=== METADADOS JA EXISTENTES ==="
fi

echo "=== STARTING HIVE ==="
service hive-server2 start

echo "=== STARTING IMPALA ==="
service impala-catalog start
service impala-state-store start
service impala-server start

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
