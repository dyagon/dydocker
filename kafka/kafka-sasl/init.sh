
kafka-topics --create \
  --bootstrap-server kafka:9092 \
  --replication-factor 1 \
  --partitions 1 \
  --topic masterprice_price_timeline_cn_v3_decathlon_data \
  --config cleanup.policy=compact



# kafka-topics --create \
#   --bootstrap-server kafka:9092 \
#   --replication-factor 1 \
#   --partitions 1 \
#   --topic pim_data_accio_item \
#   --config cleanup.policy=compact
