
from confluent_kafka import Producer
import socket

conf = {
    'bootstrap.servers': 'localhost:9093',  # Kafka 服务器地址
    'client.id': socket.gethostname(),
    'security.protocol': 'SASL_PLAINTEXT',
    'sasl.mechanism': 'PLAIN',
    'sasl.username': 'admin',  # SASL用户名
    'sasl.password': 'admin-secret',  # SASL密码
}

producer = Producer(conf)

def delivery_report(err, msg):
    """ 处理发送消息回调 """
    if err is not None:
        print('Message delivery failed: {}'.format(err))
    else:
        print('Message delivered to {} [{}]'.format(msg.topic(), msg.partition()))

topic = 'masterprice_price_timeline_cn_v3_decathlon_data'
message = 'Hello, Kafka!'

# 发送消息
producer.produce(topic, key='key', value=message, callback=delivery_report)
producer.flush()
