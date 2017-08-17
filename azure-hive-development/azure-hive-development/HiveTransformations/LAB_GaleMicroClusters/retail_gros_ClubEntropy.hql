SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;

create database if not exists proj_galedb;


DROP TABLE IF EXISTS proj_galedb.gros_ClubEntropy;
CREATE TABLE IF NOT EXISTS proj_galedb.gros_ClubEntropy
(
	customergoldbrandid STRING,
    clubEntropy DOUBLE
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/features/gros_ClubEntropy';

INSERT OVERWRITE TABLE proj_galedb.gros_ClubEntropy
Select customerKey as customergoldbrandid, sum(clubEnt) as clubEntropy
FROM (
Select t1.customerKey,
       t2.venuedesc,
       -1.0*(CAST(t2.visits as DOUBLE)/CAST(t1.visitsAll as DOUBLE) *100.0) * LN((CAST(t2.visits as DOUBLE)/CAST(t1.visitsAll as DOUBLE) *100.0)) as clubEnt         
FROM (
    SELECT customerKey,count(*) as visitsAll
    FROM basedb.xchannel_xbrand_visits
    WHERE sec_venueareacode rlike 'GRTL.*'
    Group By customerKey) as t1
LEFT JOIN (
    SELECT customerKey,venuedesc,count(*) as visits
    FROM basedb.xchannel_xbrand_visits
    WHERE sec_venueareacode rlike 'GRTL.*'
    Group By customerKey,venuedesc) as t2 ON t1.customerKey = t2.customerKey) as t3
Group By customerKey