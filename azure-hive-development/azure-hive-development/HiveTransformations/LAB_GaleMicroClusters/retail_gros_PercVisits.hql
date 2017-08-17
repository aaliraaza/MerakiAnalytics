SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;

create database if not exists proj_galedb;

DROP TABLE IF EXISTS proj_galedb.gros_PercVisits;
CREATE TABLE IF NOT EXISTS proj_galedb.gros_PercVisits
(
    customergoldbrandid STRING,
    percMorn DOUBLE,
    percAfternoon DOUBLE,
    percEvening DOUBLE,
    percNight DOUBLE
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/features/gros_PercVisits';

INSERT OVERWRITE TABLE proj_galedb.gros_PercVisits

SELECT customergoldbrandid,sum(percMorn) as percMorn, sum(percAfternoon) as percAfternoon, sum(percEvening) as percEvening, sum(percNight) as percNight
FROM (
Select t1.customerKey as customergoldbrandid, 
        CASE WHEN sessgroupname rlike '1 -.*' THEN (CAST(t2.visits as DOUBLE)/CAST(t1.visitsAll as DOUBLE)) *100.0 ELSE 0 END as percMorn,
        CASE WHEN sessgroupname rlike '2 -.*' THEN (CAST(t2.visits as DOUBLE)/CAST(t1.visitsAll as DOUBLE)) *100.0 ELSE 0 END as percAfternoon,
        CASE WHEN sessgroupname rlike '3 -.*' THEN (CAST(t2.visits as DOUBLE)/CAST(t1.visitsAll as DOUBLE)) *100.0 ELSE 0 END as percEvening,
        CASE WHEN sessgroupname rlike '4 -.*' THEN (CAST(t2.visits as DOUBLE)/CAST(t1.visitsAll as DOUBLE)) *100.0 ELSE 0 END as percNight            
FROM (
    SELECT customerKey,count(*) as visitsAll
    FROM basedb.xchannel_xbrand_visits
    WHERE sec_venueareacode rlike 'GRTL.*'
    Group By customerKey) as t1
LEFT JOIN (
    SELECT customerKey,sessgroupname,count(*) as visits
    FROM basedb.xchannel_xbrand_visits
    WHERE sec_venueareacode rlike 'GRTL.*'
    Group By customerKey,sessgroupname) as t2 ON t1.customerKey = t2.customerKey 
    ) as t3
Group By customergoldbrandid