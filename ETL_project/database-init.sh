# Check if data directory exists and has files
if [ ! -d "./data" ] || [ -z "$(ls -A ./data)" ]; then
    echo "ERROR: ./data directory is empty!"
    echo ""
    echo "Please copy your CSV files to ./data/ directory:"
    echo "   cp /path/to/your/csvs/* ./data/"
    echo ""
    echo "Required files:"
    echo "   - company.csv"
    echo "   - campaign.csv"
    echo "   - group.csv"
    echo "   - job.csv"
    echo "   - master_publisher.csv"
    echo "   - events.csv"
    echo "   - search.csv"
    echo "   - tracking.csv"
    exit 1
fi

echo "Data files found in ./data/"
ls -la ./data/

echo ""
echo "Starting containers with data volumes..."
docker-compose -f docker-compose.yml up -d

echo ""
echo " Waiting for databases to initialize..."
echo "   MySQL will automatically run scripts in mysql-init/"
echo "   This includes creating tables and importing your CSV data"
sleep 60

echo ""
echo "Checking MySQL initialization..."
docker exec etl_project-mysqldb-1 mysql -u root -p1 -e "
USE DE1;
SELECT 'company' as table_name, COUNT(*) as records FROM company
UNION ALL SELECT 'events', COUNT(*) FROM events
UNION ALL SELECT 'job', COUNT(*) FROM job
UNION ALL SELECT 'campaign', COUNT(*) FROM campaign;
"

echo ""
echo "Initializing Cassandra..."
echo "   Creating schema..."
docker exec -i etl_project-cassandradb-1 cqlsh < cassandra-init/01-cassandra-init.cql

echo "   Importing data..."
docker exec -i etl_project-cassandradb-1 cqlsh < cassandra-init/02-import-cassandra.cql

echo ""
echo "Verifying Cassandra data..."
docker exec etl_project-cassandradb-1 cqlsh -e "
USE logs;
SELECT COUNT(*) as tracking FROM tracking;
SELECT COUNT(*) as search FROM search;
"

echo ""
echo "DATABASE INITIALIZATION COMPLETE!"
echo "===================================="
echo ""
