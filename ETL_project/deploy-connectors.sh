echo "🔗 DEPLOYING KAFKA CONNECTORS"
echo "============================="

# Wait for Kafka Connect to be ready
echo " Waiting for Kafka Connect to be ready..."
until curl -s http://localhost:8083/connectors; do
  echo "   Kafka Connect not ready yet..."
  sleep 5
done
echo "Kafka Connect is ready!"

echo ""
echo "Deploying SOURCE connectors..."

# Deploy MySQL source connector
echo "Deploying MySQL source connector..."
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @connectors/mysql-source.json


echo "All connectors deployed!"

echo ""
echo "Checking connector status..."
curl -s http://localhost:8083/connectors  