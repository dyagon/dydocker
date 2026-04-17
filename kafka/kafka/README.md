# Kafka in Action, tasks and notes


## Basic Kafka


修改压缩主题：

```bash
docker exec -it dev-kafka_1 /bin/bash

# 查看主题配置
kafka-configs --bootstrap-server kafka:9092 --entity-type topics --entity-name offer-pim-masterdata-items-test --describe
kafka-configs --bootstrap-server kafka:9092 --entity-type topics --entity-name offer-pim-masterdata-items-test --alter --add-config cleanup.policy=compact

```

### Setup kafka in docker

https://github.com/confluentinc/cp-all-in-one

1 zookeeper, 3 kafka brokers @9092, @9093, @9094

```bash
cd docker
docker-compose up -d
```

```yaml
KAFKA_BROKER_ID: 1
KAFKA_ZOOKEEPER_CONNECT: "zookeeper:2181"
KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://broker1:29092,PLAINTEXT_HOST://localhost:9092
KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 3
KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 3
KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 3
KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS: 0
KAFKA_JMX_PORT: 9101
KAFKA_JMX_HOSTNAME: localhost
```

- `KAFKA_BROKER_ID`
- `KAFKA_ADVERTISED_LISTENERS`: define the hostname and port used by brokers to communicate with each other and with clients.
- `KAFKA_LISTENER_SECURITY_PROTOCOL_MAP`: define the security protocol used by each listener.
- `KAFKA_INTER_BROKER_LISTENER_NAME`: define the listener used for communication between brokers.
- `KAFKA_ZOOKEEPER_CONNECT`: define the ZooKeeper connection string.
- `KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR`: define the replication factor for the internal topics used by Kafka.
- `KAFKA_TRANSACTION_STATE_LOG_MIN_ISR`: define the minimum number of in-sync replicas for the transaction log topic.
- `KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR`: define the replication factor for the transaction log topic.
- `KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS`: define the delay before starting a rebalance after a consumer joins a group.
- `KAFKA_JMX_PORT`: define the port used for JMX connections.
- `KAFKA_JMX_HOSTNAME`: define the hostname used for JMX connections.


### Run Kafka Client

```bash
docker exec -it broker1 bash
```


### Create Topic


```bash
export TOPIC=kinaction_helloworld
bin/kafka-topics.sh --create --bootstrap-server localhost:9094 \
  --topic $TOPIC --partitions 3 --replication-factor 3


## delete topic
bin/kafka-topics.sh --delete --bootstrap-server localhost:9094 \
  --topic $TOPIC

## delete group
bin/kafka-consumer-groups.sh --delete --bootstrap-server localhost:9094 \
  --group
```

### Test Topic

```bash
bin/kafka-topics.sh --list --bootstrap-server localhost:9094
bin/kafka-topics.sh --describe --bootstrap-server localhost:9094 \
  --topic $TOPIC
```

```bash
# test produce
bin/kafka-console-producer.sh --broker-list localhost:9094 \
  --topic $TOPIC

# test consume
bin/kafka-console-consumer.sh --bootstrap-server localhost:9094 \
  --topic $TOPIC --from-beginning
```

### Java code to produce and consume

dependency add:

```xml
    <dependency>
        <groupId>ch.qos.logback</groupId>
        <artifactId>logback-classic</artifactId>
        <version>1.4.11</version>
    </dependency>


    <dependency>
        <groupId>org.apache.kafka</groupId>
        <artifactId>kafka-clients</artifactId>
        <version>3.5.1</version>
    </dependency>
```

don't show debug log: [logback.xml](./kafka-basic/src/main/resources/logback.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <appender name="KAFKA" class="ch.qos.logback.core.ConsoleAppender">
        <encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
            <pattern>
                %yellow(%d{yyyy-MM-dd HH:mm:ss}) %highlight([%p]) %magenta((%file:%line\)) - %msg%n
            </pattern>
        </encoder>
    </appender>

    <logger name="org.apache.kafka" level="INFO" additivity="false">
        <appender-ref ref="KAFKA" />
    </logger>

    <root level="INFO">
        <appender-ref ref="KAFKA" />
    </root>
</configuration>
```

## Kafka Connect

### from JDBC to Kafka

https://github.com/confluentinc/kafka-connect-jdbc

## Kafka Avro

## Kafka Producer



### create topics

```bash
kafka-topics --bootstrap-server localhost:9092 --create --topic test-topic --partitions 3 --replication-factor 3

kafka-topics --bootstrap-server localhost:9092 --create --topic kinaction_alerttrend --partitions 3 --replication-factor 3

kafka-topics --bootstrap-server localhost:9092 --create --topic kinaction_audit --partitions 3 --replication-factor 3
```

## Kafka Consumer

## Kafka Brokers

### Listing topics from Zookeeper

```bash
	bin/zookeeper-shell.sh localhost:2181
	ls /brokers/topics
```

## Find Controller in ZooKeeper

```bash
    bin/zookeeper-shell.sh localhost:2181
    get /controller
```

## Describe Topic

```bash
 kafka-topics --describe --bootstrap-server localhost:9094 --topic kinaction_alert

## Sample output
Topic: kinaction_alert  TopicId: 9N9hbEekSyGRoZRcSJgrTA PartitionCount: 3       ReplicationFactor: 3    Configs:
        Topic: kinaction_alert  Partition: 0    Leader: 1       Replicas: 1,2,3 Isr: 1,2,3
        Topic: kinaction_alert  Partition: 1    Leader: 2       Replicas: 2,3,1 Isr: 2,3,1
        Topic: kinaction_alert  Partition: 2    Leader: 3       Replicas: 3,1,2 Isr: 3,1,2
```

## Under-replicated-partitions flag

    bin/kafka-topics.sh --describe --bootstrap-server localhost:9094 --under-replicated-partitions

    #Sample output
    Topic: kinaction_replica_test	Partition: 0	Leader: 0	Replicas: 1,0,2	Isr: 0,2

```

```
