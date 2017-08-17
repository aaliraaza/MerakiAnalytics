SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;

create database if not exists proj_galedb;


DROP TABLE IF EXISTS proj_galedb.mecc_Age;
CREATE TABLE IF NOT EXISTS proj_galedb.mecc_Age
(
    customergoldbrandid STRING,
    Age INT,
    Age STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/features/mecc_Age';

INSERT OVERWRITE TABLE proj_galedb.mecc_Age

SELECT t1.customerGoldBrandID, 
        (year(CURRENT_DATE) - t2.yearofbirth) as Age,
         CASE 
            WHEN (year(CURRENT_DATE) - t2.yearofbirth) < 40 THEN '< 40'
            WHEN (year(CURRENT_DATE) - t2.yearofbirth) BETWEEN 40 AND 59 THEN '40 - 59'
            WHEN (year(CURRENT_DATE) - t2.yearofbirth) BETWEEN 60 AND 69 THEN '60 - 69'
            WHEN (year(CURRENT_DATE) - t2.yearofbirth) BETWEEN 70 AND 79 THEN '70 - 79'
            WHEN (year(CURRENT_DATE) - t2.yearofbirth) > 79 THEN '80 +'
            ELSE 'Unk'
        END as AgeBand
FROM proj_galedb.dimcustomers as t1
INNER JOIN proj_galedb.dimcustomerattributes as t2 ON t1.customerKey = t2.customerKey
where t1.sourcesystemcode = 'MMEM'
--limit 19;