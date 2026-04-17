
from confluent_kafka import Producer

conf = {
    'bootstrap.servers': 'localhost:19093',
    'auto.offset.reset': 'earliest',
    'enable.auto.commit': 'false',
    
    ## SSL
    'security.protocol': 'SSL',
    'ssl.ca.location': 'certs/root/ca.crt',
    'ssl.certificate.location': 'certs/client/client.crt',
    'ssl.key.location': 'certs/client/client.key',
    'ssl.key.password': 'confluent',
}

producer = Producer(conf)

def delivery_report(err, msg):
    """ 处理发送消息回调 """
    if err is not None:
        print('Message delivery failed: {}'.format(err))
    else:
        print('Message delivered to {} [{}]'.format(msg.topic(), msg.partition()))

topic = 'test-consume'
message = 'Hello, Kafka!'


for i in range(10):
    # 发送消息
    producer.produce(topic, key='key', value=message, callback=delivery_report)
    producer.flush()
