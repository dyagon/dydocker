from confluent_kafka import Consumer, KafkaException
from confluent_kafka import KafkaError

conf = {
    'bootstrap.servers': 'localhost:9093',  # Kafka 服务器地址
    'group.id': 'test_group',
    'auto.offset.reset': 'earliest',
    'security.protocol': 'SASL_PLAINTEXT',
    'sasl.mechanism': 'PLAIN',
    'sasl.username': 'admin',  # SASL用户名
    'sasl.password': 'admin-secret',  # SASL密码
}

consumer = Consumer(conf)

topic = 'offer-pim-masterdata-items-test'
consumer.subscribe([topic])

try:
    while True:
        msg = consumer.poll(timeout=1.0)
        if msg is None:
            continue
        if msg.error():
            if msg.error().code() == KafkaError._PARTITION_EOF:
                # End of partition event
                print('%% %s [%d] reached end at offset %d\n' %
                      (msg.topic(), msg.partition(), msg.offset()))
            elif msg.error():
                raise KafkaException(msg.error())
        elif msg.value():
            print('Received message: {}'.format(msg.key().decode('utf-8')))
            print('Received message: {}'.format(msg.value().decode('utf-8')))
        else:
            print('Received message: {}'.format(msg.key().decode('utf-8')))
finally:
    # 关闭消费者
    consumer.close()
