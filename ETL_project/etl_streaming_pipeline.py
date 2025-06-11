import findspark
findspark.init()
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *
import time
import datetime
import uuid
import time_uuid
from pyspark.sql.functions import from_json, col, when, coalesce
from uuid import UUID
from uuid import *
import json

# Configuration
KAFKA_SERVERS = 'localhost:9092'
MYSQL_JOB_TOPIC = 'mysqldb.DE1.job'
CASSANDRA_HOST = 'localhost'
CASSANDRA_PORT = '9042'

MYSQL_HOST = 'localhost'
MYSQL_PORT = '3307'  
MYSQL_DB = 'DE1'
MYSQL_USER = 'root'
MYSQL_PASSWORD = '1'
MYSQL_URL = f'jdbc:mysql://{MYSQL_HOST}:{MYSQL_PORT}/{MYSQL_DB}'
MYSQL_DRIVER = "com.mysql.cj.jdbc.Driver"


# Create Spark session
spark = SparkSession.builder \
    .appName("ETL_project") \
    .config('spark.jars.packages', 
            'mysql:mysql-connector-java:8.0.33,' +
            'com.datastax.spark:spark-cassandra-connector_2.12:3.1.0,' +
            'org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.0') \
    .config('spark.cassandra.connection.host', CASSANDRA_HOST) \
    .config('spark.cassandra.connection.port', CASSANDRA_PORT) \
    .getOrCreate()

spark.sparkContext.setLogLevel("ERROR")


def get_mysql_job_data():    
    # Read from Kafka
    df = spark.read \
        .format("kafka") \
        .option("kafka.bootstrap.servers", KAFKA_SERVERS) \
        .option("subscribe", MYSQL_JOB_TOPIC) \
        .option("startingOffsets", "earliest") \
        .option("endingOffsets", "latest") \
        .load()
    
    # Parse JSON with inferred schema
    parsed_df = df.select(
        from_json(col("value").cast("string"), "id INT, company_id INT, campaign_id INT, group_id INT").alias("job_data")
    ).select("job_data.*")
    
    # Filter out nulls
    job_df = parsed_df.filter(col("id").isNotNull())
    
    return job_df

def read_cassandra(mysql_time):
    try:
        
        # Read directly from Cassandra table
        cassandra_df = spark.read \
            .format("org.apache.spark.sql.cassandra") \
            .option("table", "tracking") \
            .option("keyspace", "logs") \
            .load().where(col('ts')>= mysql_time)
        
        # Select and filter data
        processed_df = cassandra_df.select(
            'create_time', 'ts', 'job_id', 'custom_track', 'bid', 
            'campaign_id', 'group_id', 'publisher_id'
        ).filter(col('job_id').isNotNull())
        return processed_df
        
    except Exception as e:
        print(f"Error reading from Cassandra: {e}")
        return None

def process_UUID(df):
    # Check if input DataFrame is empty
    if df.count() == 0:
        print("Input DataFrame is empty")
        return df  # Return empty DataFrame with same schema instead of None
    
    # Collect create_time column only once
    spark_time_rows = df.select('create_time').collect()
    
    # Prepare data for new DataFrame
    rows = []
    for row in spark_time_rows:
        try:
            uuid_val = row[0]
            datetime_val = time_uuid.TimeUUID(bytes=UUID(uuid_val).bytes).get_datetime().strftime('%Y-%m-%d %H:%M:%S')
            rows.append((uuid_val, datetime_val))
        except Exception as e:
            print(f"Error processing UUID {row[0]}: {e}")
            # Handle error - skip or provide default value
            continue
    
    # If all rows failed, return empty DataFrame
    if not rows:
        print("No valid rows to process")
        return spark.createDataFrame([], df.schema)
    
    # Create intermediate DataFrame
    time_data = spark.createDataFrame(rows, ['create_time', 'ts'])
    
    # Join and select
    result = df.join(time_data, ['create_time'], 'inner').drop(df.ts)
    result = result.select('create_time', 'ts', 'job_id', 'custom_track', 
                          'bid', 'campaign_id', 'group_id', 'publisher_id')
    
    return result

# Processing functions 
def calculating_clicks(df):
    clicks_data = df.filter(df.custom_track == 'click')
    clicks_data = clicks_data.na.fill({'bid':0, 'job_id':0, 'publisher_id':0, 'group_id':0, 'campaign_id':0})
    clicks_data.createOrReplaceTempView('clicks')
    return spark.sql("""
        select job_id, date(ts) as date, hour(ts) as hour, 
               publisher_id, campaign_id, group_id,
               round(avg(bid),2) as bid_set, count(*) as clicks, sum(bid) as spend_hour 
        from clicks
        group by job_id, date(ts), hour(ts), publisher_id, campaign_id, group_id
    """)

def calculating_conversion(df):
    conversion_data = df.filter(df.custom_track == 'conversion')
    conversion_data = conversion_data.na.fill({'job_id':0, 'publisher_id':0, 'group_id':0, 'campaign_id':0})
    conversion_data.createOrReplaceTempView('conversion')
    return spark.sql("""
        select job_id, date(ts) as date, hour(ts) as hour, 
               publisher_id, campaign_id, group_id, count(*) as conversions  
        from conversion
        group by job_id, date(ts), hour(ts), publisher_id, campaign_id, group_id
    """)

def calculating_qualified(df):
    qualified_data = df.filter(df.custom_track == 'qualified')
    qualified_data = qualified_data.na.fill({'job_id':0, 'publisher_id':0, 'group_id':0, 'campaign_id':0})
    qualified_data.createOrReplaceTempView('qualified')
    return spark.sql("""
        select job_id, date(ts) as date, hour(ts) as hour, 
               publisher_id, campaign_id, group_id, count(*) as qualified  
        from qualified
        group by job_id, date(ts), hour(ts), publisher_id, campaign_id, group_id
    """)

def calculating_unqualified(df):
    unqualified_data = df.filter(df.custom_track == 'unqualified')
    unqualified_data = unqualified_data.na.fill({'job_id':0, 'publisher_id':0, 'group_id':0, 'campaign_id':0})
    unqualified_data.createOrReplaceTempView('unqualified')
    return spark.sql("""
        select job_id, date(ts) as date, hour(ts) as hour, 
               publisher_id, campaign_id, group_id, count(*) as unqualified  
        from unqualified
        group by job_id, date(ts), hour(ts), publisher_id, campaign_id, group_id
    """)

def process_final_data(clicks_output, conversion_output, qualified_output, unqualified_output):
    return clicks_output.join(conversion_output, ['job_id','date','hour','publisher_id','campaign_id','group_id'], 'full') \
        .join(qualified_output, ['job_id','date','hour','publisher_id','campaign_id','group_id'], 'full') \
        .join(unqualified_output, ['job_id','date','hour','publisher_id','campaign_id','group_id'], 'full')


def write_to_mysql(df):
    """Write results to MySQL sink"""
    df.write \
        .format("jdbc") \
        .option("url", MYSQL_URL) \
        .option("driver", MYSQL_DRIVER) \
        .option("dbtable", "events") \
        .option("user", MYSQL_USER) \
        .option("password", MYSQL_PASSWORD) \
        .mode("append") \
        .save()

def main_etl_batch(mysql_time):
    """Main ETL process"""  
    #Read tracking data directly from Cassandra
    tracking_df = read_cassandra(mysql_time)
    if tracking_df is None or tracking_df.count() == 0:
        print("No tracking data to process")
        return False
    
    #Process UUID
    tracking_df = process_UUID(tracking_df)
    
    #Read job data from MySQL Kafka topic
    job_df = get_mysql_job_data()
    if job_df is None:
        print("No job data available, skipping this batch")
        return False
    job_df = job_df.withColumnRenamed('id', 'job_id')
    
    #Process aggregations 
    print("Processing aggregations...")
    clicks_output = calculating_clicks(tracking_df)
    conversion_output = calculating_conversion(tracking_df)
    qualified_output = calculating_qualified(tracking_df)
    unqualified_output = calculating_unqualified(tracking_df)
    
    #Combine results
    cassandra_output = process_final_data(clicks_output, conversion_output, 
                                        qualified_output, unqualified_output)
    
    if cassandra_output.count() == 0:
        print("No aggregated results to process")
        return False
   
    
    #Join with job data 
    final_output = cassandra_output.join(job_df,  ['job_id','campaign_id','group_id'], 'left') 
    
    # Fill nulls
    final_output = final_output.na.fill({
        'clicks': 0, 'conversions': 0, 'qualified': 0, 'unqualified': 0,
        'bid_set': 0.0, 'spend_hour': 0.0
    })
    
    #Transform for output (your exact transformations)
    events_df = final_output.select('job_id','date','hour','publisher_id','company_id',
                                   'campaign_id','group_id','unqualified','qualified',
                                   'conversions','clicks','bid_set','spend_hour')
    
    events_df = events_df.withColumnRenamed('date','dates') \
    .withColumnRenamed('hour','hours') \
    .withColumnRenamed('qualified','qualified_application') \
    .withColumnRenamed('unqualified','disqualified_application') \
    .withColumnRenamed('conversions','conversion')
    
    events_df = events_df.withColumn('sources', lit('Cassandra')) \
    .withColumn('updated_at', current_timestamp())
    
    # Step 7: Write to Kafka
    write_to_mysql(events_df)
    return True

def get_latest_time_cassandra():
    processed_df = spark.read.format("org.apache.spark.sql.cassandra") \
        .option("table", "tracking") \
        .option("keyspace", "logs") \
        .load()
    processed_df = process_UUID(processed_df)
    cassandra_latest_time = processed_df.agg({'ts':'max'}).take(1)[0][0]
    return cassandra_latest_time
    
def get_mysql_latest_time():    
    sql = "(SELECT MAX(updated_at) as max_time FROM events) data"
    mysql_time_df = spark.read \
        .format('jdbc') \
        .options(url=MYSQL_URL, driver=MYSQL_DRIVER, dbtable=sql, 
                user=MYSQL_USER, password=MYSQL_PASSWORD) \
        .load()
    if mysql_time_df.collect()[0]['max_time'] is None:
        latest_mysql_time = '0001-01-01 00:00:00'
    else:
        latest_mysql_time = datetime.datetime.strftime(mysql_time_df.collect()[0]['max_time'], '%Y-%m-%d %H:%M:%S')
    return latest_mysql_time

def main():
    while True :
        mysql_time = get_mysql_latest_time()
        print('MySQL latest time is {}'.format(mysql_time))
        cassandra_time = get_latest_time_cassandra()
        print('Cassandra latest time is {}'.format(cassandra_time))
        if cassandra_time > mysql_time : 
            main_etl_batch(mysql_time)
            print('ETL completed')
        else :
            print("No new data found")
            time.sleep(10)

if __name__ == "__main__":
    main()