SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;

create database if not exists proj_galedb;


DROP TABLE IF EXISTS proj_galedb.mecc_NumClubs;
CREATE TABLE IF NOT EXISTS proj_galedb.mecc_NumClubs
(
    customergoldbrandid STRING,
    NumClubs INT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/features/mecc_NumClubs';

INSERT OVERWRITE TABLE proj_galedb.mecc_NumClubs

SELECT customerKey as customergoldbrandid,count(Distinct(venuedesc)) as numClubs
FROM basedb.xchannel_xbrand_visits
WHERE sec_venueareacode rlike 'MRTL.*'
Group By customerKey
--Limit 10