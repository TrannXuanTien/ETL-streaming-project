# Real-Time ETL Streaming Pipeline

A comprehensive real-time data processing system that implements Change Data Capture (CDC) from MySQL, processes streaming data from Cassandra, and performs real-time analytics using Apache Spark and Kafka.

## Architecture Overview

```
CSV Data → MySQL → Kafka (CDC) → Spark Streaming ← Cassandra (Tracking Data)
                                       ↓
                              MySQL (Aggregated Events)
```

The pipeline captures changes from MySQL job data, processes real-time tracking events from Cassandra, performs aggregations in Spark, and stores the results back to MySQL for analytics.

## Components

- **MySQL**: Stores job, campaign, company, and aggregated events data
- **Cassandra**: Stores high-volume tracking data (clicks, conversions, etc.)
- **Apache Kafka**: Handles change data capture from MySQL
- **Kafka Connect**: JDBC source connector for MySQL CDC
- **Apache Spark**: Real-time stream processing and aggregations
- **Docker**: Containerized deployment

## Prerequisites

- Docker and Docker Compose
- Python 3.7+
- Apache Spark with PySpark
- Required Python packages:
  ```bash
  pip install pyspark cassandra-driver sqlalchemy mysql-connector-python pandas numpy
  ```

## Data Requirements

Create a `./data/` directory with the following CSV files:
- `company.csv`
- `campaign.csv`
- `group.csv`
- `job.csv`
- `master_publisher.csv`
- `events.csv`
- `search.csv`
- `tracking.csv`

## Quick Start

### 1. Initialize the Environment

```bash
chmod +x etl_init.sh
./etl_init.sh
```

This script will:
- Start all Docker containers
- Initialize MySQL and Cassandra databases
- Import CSV data
- Create Kafka topics
- Deploy Kafka connectors

### 2. Start the Streaming Pipeline

```bash
python etl_streaming_pipeline.py
```

### 3. Generate Test Data (Optional)

```bash
python faking_data_script.py
```

### 4. Monitor Results

```bash
python monitoring_new_events.py
```

## Manual Setup (Alternative)

If you prefer to run components separately:

### 1. Start Databases
```bash
chmod +x database-init.sh
./database-init.sh
```

### 2. Create Kafka Topics
```bash
chmod +x create_kafka_topics.sh
./create_kafka_topics.sh
```

### 3. Deploy Connectors
```bash
chmod +x deploy-connectors.sh
./deploy-connectors.sh
```

## Service Endpoints

- **MySQL**: `localhost:3307`
  - User: `root`
  - Password: `1`
  - Database: `DE1`

- **Cassandra**: `localhost:9042`
  - Keyspace: `logs`

- **Kafka**: `localhost:9092`
  - Topics: `mysqldb.DE1.job`

- **Kafka Connect**: `localhost:8083`
  - REST API for connector management

## Data Flow

### 1. Source Data Ingestion
- CSV files are loaded into MySQL and Cassandra tables
- MySQL tables: `company`, `campaign`, `group`, `job`, `master_publisher`
- Cassandra table: `tracking` (stores click/conversion events)

### 2. Change Data Capture
- Kafka Connect JDBC connector monitors MySQL `job` table
- Changes are published to `mysqldb.DE1.job` Kafka topic
- Monitoring "updated_at" time in "events" table and time in "tracking" table for new data input
- Read only new data from "tracking" table then process and write to "events" 


### 3. Real-Time Processing
- Spark Streaming application processes:
  - Job changes from Kafka
  - Tracking events from Cassandra
- Performs aggregations by job, date, hour, publisher, campaign, and group
- Calculates metrics: clicks, conversions, qualified/unqualified applications, spend

### 4. Data Output
- Aggregated results are written to MySQL `events` table
- Supports incremental processing based on timestamps

## Key Features

### Real-Time Aggregations
The pipeline calculates:
- **Clicks**: Count and average bid by dimensions
- **Conversions**: Conversion events count
- **Qualified Applications**: Qualified leads count  
- **Unqualified Applications**: Disqualified leads count
- **Spend**: Total bid amount per hour

### Incremental Processing
- Tracks latest processed timestamps
- Only processes new data since last run
- Handles both batch and streaming scenarios

### UUID Time Processing
- Converts Cassandra TimeUUID to readable timestamps
- Enables time-based filtering and joins

### Fault Tolerance
- Handles empty datasets gracefully
- Implements error handling for UUID processing
- Supports connector restart and recovery

## Database Schema

### MySQL Tables
- `job`: Job postings with campaign/group associations
- `company`: Company master data
- `campaign`: Marketing campaigns
- `group`: Campaign groups
- `events`: Aggregated analytics results

### Cassandra Tables
- `tracking`: High-volume event tracking data

## Monitoring

- Use monitoring_new_events.py to check for number of events imported


## Troubleshooting

### Common Issues

1. **Data directory not found**
   - Ensure `./data/` contains all required CSV files
   - Check file permissions

2. **Kafka Connect fails to start**
   - Wait for Kafka to be fully ready
   - Check connector configuration in `connectors/mysql-source.json`

3. **MySQL connection issues**
   - Verify MySQL container is running
   - Check port 3307 is available

4. **Cassandra connection timeout**
   - Allow additional time for Cassandra initialization
   - Verify port 9042 is accessible

### Logs
- Docker logs: `docker-compose logs [service_name]`
- Kafka Connect logs: `docker logs etl_project-kafka-connect-1`
- MySQL logs: `docker logs etl_project-mysqldb-1`

## Configuration

### Environment Variables
Key configurations in `etl_streaming_pipeline.py`:
- `KAFKA_SERVERS`: Kafka bootstrap servers
- `MYSQL_HOST`: MySQL connection details
- `CASSANDRA_HOST`: Cassandra connection details

### Kafka Connect Configuration
Located in `connectors/mysql-source.json` 
### Docker Compose Settings
Modify `docker-compose.yml` for:
- Port mappings
- Volume mounts
- Environment variables
- Resource limits

## Performance Considerations

- **Spark Configuration**: Adjust executor memory and cores based on data volume
- **Kafka Partitions**: Increase for higher throughput
- **Cassandra Consistency**: Configure based on availability requirements
- **MySQL Indexing**: Add indexes on frequently joined columns




