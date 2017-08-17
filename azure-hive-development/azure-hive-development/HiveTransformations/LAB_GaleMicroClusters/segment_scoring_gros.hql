--analyze table proj_galedb.gros_Age compute statistics;
--analyze table proj_galedb.gros_Age compute statistics for columns;

--analyze table proj_galedb.gros_percVisits compute statistics;
--analyze table proj_galedb.gros_percVisits compute statistics for columns;

--analyze table proj_galedb.gros_clubEntropy compute statistics;
--analyze table proj_galedb.gros_clubEntropy compute statistics for columns;

--analyze table proj_galedb.gros_Tenure compute statistics;
--analyze table proj_galedb.gros_Tenure compute statistics for columns;

--SET hive.exec.dynamic.partition.mode=nonstrict;
--SET hive.exec.dynamic.partition=true;

create database if not exists proj_galedb;


DROP TABLE IF EXISTS proj_galedb.gros_SegmentationScores;
CREATE TABLE IF NOT EXISTS proj_galedb.gros_SegmentationScores
(
    customergoldbrandid STRING,
    Microsegment STRING
)
CLUSTERED BY (customergoldbrandid) INTO 1 BUCKETS
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' lines terminated by '\n'
STORED AS TEXTFILE
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/scoring/gros_SegmentationScores';

INSERT OVERWRITE TABLE proj_galedb.gros_SegmentationScores
SELECT customergoldbrandid,
       min(struct(Distance, microsegment)).col2 as Microsegment
FROM(
SELECT a.customergoldbrandid, b.microsegment,
sqrt(power(a.age - b.age, 2) 
+ power(a.`<20` - b.`<20`, 2) 
+ power(a.`<30` - b.`<30`, 2)
+ power(a.`<40` - b.`<40`, 2)
+ power(a.`<50` - b.`<50`, 2)
+ power(a.`<60` - b.`<60`, 2)
+ power(a.`<70` - b.`<70`, 2)
+ power(a.`<80` - b.`<80`, 2)
+ power(a.morning - b.morning, 2)
+ power(a.day - b.day, 2)
+ power(a.evening - b.evening, 2)
+ power(a.night - b.night, 2)
+ power(a.clubentropy - b.clubentropy, 2)
+ power(a.tenure - b.tenure, 2)
) as Distance
FROM (
SELECT t1.customergoldbrandid,
       t1.age,
       t1.`<20`,
       t1.`<30`,
       t1.`<40`,
       t1.`<50`,
       t1.`<60`,
       t1.`<70`,
       t1.`<80`,
       t2.percmorn as morning,
       t2.percafternoon as day,
       t2.percEvening as evening,
       t2.percNight as night,
       t3.clubentropy,
       t4.retailtenure as tenure
FROM proj_galedb.gros_Age as t1
LEFT JOIN proj_galedb.gros_percVisits as t2 ON t1.customergoldbrandid = t2.customergoldbrandid
LEFT JOIN proj_galedb.gros_clubEntropy as t3 ON t1.customergoldbrandid = t3.customergoldbrandid
LEFT JOIN proj_galedb.gros_Tenure as t4 ON t1.customergoldbrandid = t4.customergoldbrandid
LEFT JOIN proj_galedb.gros_NumVisits as t5 ON t1.customergoldbrandid = t5.customergoldbrandid
) as a
LEFT JOIN proj_galedb.retail_gros_tCentroids as b on a.customergoldbrandid = a.customergoldbrandid) as c
GROUP BY customergoldbrandid
