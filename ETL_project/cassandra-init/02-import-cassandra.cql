USE logs;

-- Import search data (1329 records)
COPY search(row_index,job_id,benefits,bid,campaign_budget,
       campaign_id, city_name, company_logo, company_name,
       description, feed_id, lat, lon, major_category,
       minor_category, pay_currentcy,pay_from,pay_option,pay_to,
       pay_type,postal_code,requirements,state,status,title,
       work_schedule)
FROM '/var/lib/cassandra-files/search.csv' WITH
DELIMITER = ',' AND HEADER = TRUE AND CHUNKSIZE=50 AND NUMPROCESSES=4;

-- Import tracking data (6766 records)  
COPY tracking (create_time, bid, bn, campaign_id, cd, custom_track, de,dl,dt,ed,ev,group_id,id,job_id,md,publisher_id,rl,sr,ts,tz,ua,uid,utm_campaign,utm_content,utm_medium,utm_source,utm_term,v,vp) 
FROM '/var/lib/cassandra-files/tracking.csv' WITH
DELIMITER = ',' AND HEADER = TRUE;

-- Verify import
SELECT COUNT(*) as search_records FROM search;
SELECT COUNT(*) as tracking_records FROM tracking;

-- Show sample data
SELECT * FROM tracking LIMIT 5;
SELECT * FROM search LIMIT 5;
