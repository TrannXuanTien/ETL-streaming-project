-- Create keyspace
CREATE KEYSPACE IF NOT EXISTS logs
WITH REPLICATION = {
    'class': 'SimpleStrategy',
    'replication_factor': 1
};

USE logs;

CREATE TABLE IF NOT EXISTS search (
    row_index int, 
    job_id bigint PRIMARY KEY,
    benefits text,
    bid bigint,
    campaign_budget double,
    campaign_id bigint, 
    city_name text, 
    company_logo text, 
    company_name text,
    description text, 
    feed_id text, 
    lat double, 
    lon double, 
    major_category text,
    minor_category text, 
    pay_currentcy double,
    pay_from double,
    pay_option double,
    pay_to double,
    pay_type double,
    postal_code bigint,
    requirements text,
    state text,
    status bigint,
    title text,
    work_schedule text
) WITH cdc = true;

--Tracking table (6766 records)
CREATE TABLE IF NOT EXISTS tracking (
    create_time timeuuid PRIMARY KEY, 
    bid int, 
    bn text, 
    campaign_id int, 
    cd int, 
    custom_track text, 
    de text,
    dl text,
    dt text,
    ed text,
    ev int,
    group_id int,
    id int,
    job_id int,
    md text,
    publisher_id int,
    rl text,
    sr text,
    ts text,
    tz int,
    ua text,
    uid text,
    utm_campaign text,
    utm_content text,
    utm_medium text,
    utm_source text,
    utm_term text,
    v text,
    vp text
) WITH cdc = true;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_tracking_job_id ON tracking (job_id);
CREATE INDEX IF NOT EXISTS idx_tracking_custom_track ON tracking (custom_track);
CREATE INDEX IF NOT EXISTS idx_tracking_campaign_id ON tracking (campaign_id);
CREATE INDEX IF NOT EXISTS idx_tracking_group_id ON tracking (group_id);
CREATE INDEX IF NOT EXISTS idx_tracking_publisher_id ON tracking (publisher_id);

CREATE INDEX IF NOT EXISTS idx_search_campaign_id ON search (campaign_id);
