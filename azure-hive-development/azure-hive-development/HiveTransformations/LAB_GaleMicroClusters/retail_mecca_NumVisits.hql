SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;

create database if not exists proj_galedb;


DROP TABLE IF EXISTS proj_galedb.mecc_NumVisits;
CREATE TABLE IF NOT EXISTS proj_galedb.mecc_NumVisits
(
    customergoldbrandid STRING,
    NumVisits INT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/features/mecc_NumVisits';

INSERT OVERWRITE TABLE proj_galedb.mecc_NumVisits

SELECT customerKey,count(*) as NumVisits
FROM basedb.xchannel_xbrand_visits
WHERE sec_venueareacode rlike 'MRTL.*'
Group By customerKey