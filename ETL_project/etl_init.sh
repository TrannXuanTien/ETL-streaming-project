#!/bin/bash

echo "ETL Environment Initialization"
echo "=============================="
echo ""


echo "Step 1: Initializing databases on docker..."
chmod +x database-init.sh
./database-init.sh
until docker exec etl_project-mysqldb-1 mysql -u root -p1 -e "SELECT 1" >/dev/null 2>&1; do
  echo "  MySQL not ready yet, waiting..."
    sleep 5
done
echo "  MySQL is ready!"
echo ""
  
until docker exec etl_project-cassandradb-1 cqlsh -e "DESCRIBE KEYSPACES" >/dev/null 2>&1; do
  echo "  Cassandra not ready yet, waiting..."
  sleep 5
done
echo "  Cassandra is ready!"
echo ""

echo "Step 2: Creating Kafka topics..."
chmod +x create_kafka_topics.sh
./create_kafka_topics.sh
echo ""

echo "Step 3: Deploying Kafka connectors..."
chmod +x deploy-connectors.sh
./deploy-connectors.sh
echo ""

echo "✅ ETL Environment Ready!"
echo "========================"
echo "MySQL:         localhost:3307"
echo "Cassandra:     localhost:9042" 
echo "Kafka:         localhost:9092"
echo "Kafka Connect: localhost:8083"