echo "📋 CREATING KAFKA TOPICS"
echo "========================"

# Topic for MySQL job table changes
echo "Creating topic: mysqldb.DE1.job"
docker exec etl_project-kafka-1 kafka-topics --create \
  --topic mysqldb.DE1.job \
  --bootstrap-server kafka:29092 \
  --partitions 1 \
  --replication-factor 1 \
  --if-not-exists


# List all topics
echo ""
echo "✅ Topics created:"
docker exec etl_project-kafka-1 kafka-topics --list --bootstrap-server localhost:29092