SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;

create database if not exists proj_galedb;


DROP TABLE IF EXISTS proj_galedb.gros_percVisitsByArea;
CREATE TABLE IF NOT EXISTS proj_galedb.gros_percVisitsByArea
(
	customergoldbrandid STRING,
    London Double,
    Midlands Double,
    North Double,
    Scotland Double,
    SE Double
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/features/gros_percVisitsByArea';

INSERT OVERWRITE TABLE proj_galedb.gros_percVisitsByArea

SELECT customergoldbrandid,
       sum(London) as London,
       sum(Midlands) as Midlands,
       sum(North) as North,
       sum(Scotland) as Scotland,
       sum(SE) as SE
FROM (
Select customerKey as customergoldbrandid,
    CASE WHEN venueAreaDesc = 'London' THEN areaPerc ELSE 0 END AS London,
    CASE WHEN venueAreaDesc = 'Midlands & West' THEN areaPerc ELSE 0 END AS Midlands,
    CASE WHEN venueAreaDesc = 'North' THEN areaPerc
         WHEN venueAreaDesc = 'North - (CLOSED)' THEN areaPerc
         ELSE 0 END AS North,
    CASE WHEN venueAreaDesc = 'Scotland & North East' THEN areaPerc ELSE 0 END AS Scotland,
    CASE WHEN venueAreaDesc = 'South & East' THEN areaPerc ELSE 0 END AS SE

From (
Select t1.customerKey,
       t2.venueAreaDesc,
       CAST(t2.visits as DOUBLE)/CAST(t1.visitsAll as DOUBLE) *100.0 as areaPerc
FROM (
    SELECT customerKey,count(*) as visitsAll
    FROM basedb.xchannel_xbrand_visits
    WHERE sec_venueareacode rlike 'GRTL.*'
    Group By customerKey) as t1
LEFT JOIN (
    SELECT customerKey,venueAreaDesc,count(*) as visits
    FROM basedb.xchannel_xbrand_visits
    WHERE sec_venueareacode rlike 'GRTL.*'
    Group By customerKey,venueAreaDesc) as t2 ON t1.customerKey = t2.customerKey) as t3 ) as t4
GROUP BY customergoldbrandid
