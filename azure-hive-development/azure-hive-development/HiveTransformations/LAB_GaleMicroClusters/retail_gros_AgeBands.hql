SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;

create database if not exists proj_galedb;


DROP TABLE IF EXISTS proj_galedb.gros_Age;
CREATE TABLE IF NOT EXISTS proj_galedb.gros_Age
(
    customergoldbrandid STRING,
    Age INT,
    `<20` INT,
    `<30` INT,
    `<40` INT,
    `<50` INT,
    `<60` INT,
    `<70` INT,
    `<80` INT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/features/gros_Age';

INSERT OVERWRITE TABLE proj_galedb.gros_Age

SELECT t1.customerGoldBrandID, 
        (year(CURRENT_DATE) - t2.yearofbirth) as Age,
        CASE WHEN (year(CURRENT_DATE) - t2.yearofbirth) < 20 THEN 1 ELSE 0 END AS `<20`,
        CASE WHEN (year(CURRENT_DATE) - t2.yearofbirth) BETWEEN 21 AND 30 THEN 1 ELSE 0 END AS `<30`,
        CASE WHEN (year(CURRENT_DATE) - t2.yearofbirth) BETWEEN 31 AND 40 THEN 1 ELSE 0 END AS `<40`,
        CASE WHEN (year(CURRENT_DATE) - t2.yearofbirth) BETWEEN 41 AND 50 THEN 1 ELSE 0 END AS `<50`,
        CASE WHEN (year(CURRENT_DATE) - t2.yearofbirth) BETWEEN 51 AND 60 THEN 1 ELSE 0 END AS `<60`,
        CASE WHEN (year(CURRENT_DATE) - t2.yearofbirth) BETWEEN 61 AND 70 THEN 1 ELSE 0 END AS `<70`,
        CASE WHEN (year(CURRENT_DATE) - t2.yearofbirth) BETWEEN 71 AND 80 THEN 1 ELSE 0 END AS `<80`
FROM proj_galedb.dimcustomers as t1
INNER JOIN proj_galedb.dimcustomerattributes as t2 ON t1.customerKey = t2.customerKey
where t1.sourcesystemcode in ('NEON','ENDX')