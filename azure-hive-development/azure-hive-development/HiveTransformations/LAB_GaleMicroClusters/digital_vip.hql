SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;

create database if not exists proj_galedb;


DROP TABLE IF EXISTS proj_galedb.DigitalVIP;
CREATE TABLE IF NOT EXISTS proj_galedb.DigitalVIP
(
	masterCode STRING,
    brand STRING,
	gradeDigitalVIP STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/features/digital_vip';

INSERT OVERWRITE TABLE proj_galedb.DigitalVIP



SELECT masterCode,
	   brand,
	   gradeVIPMeccOnl as gradeDigitalVIP
FROM rawdb.MdmMecca
WHERE isVIPMeccOnl = 1
	
UNION ALL

SELECT  masterCode,
		mdmmodifieddate
	    brand,
		gradeVIPGrosOnl
FROM rawdb.MdmGrosvenor
WHERE isVIPGrosOnl = 1
GROUP BY masterCode,
		 mdmmodifieddate
	     brand,
		 gradeVIPGrosOnl;


select * from proj_galedb.DigitalVIP LIMIT 100;