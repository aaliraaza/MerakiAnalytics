SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;

create database if not exists proj_galedb;


DROP TABLE IF EXISTS proj_galedb.mecc_Tenure;
CREATE TABLE IF NOT EXISTS proj_galedb.mecc_Tenure
(
    customergoldbrandid STRING,
    RetailTenure INT,
    TenureBand STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/features/mecc_Tenure';

INSERT OVERWRITE TABLE proj_galedb.mecc_Tenure


SELECT t1.customergoldbrandid,
	    case when floor(datediff(current_timestamp,min(t2.registrationdate))/365) is null then 0
	  		else floor(datediff(current_timestamp,min(t2.registrationdate))/365) end as RetailTenure,
        case when floor(datediff(current_timestamp,min(t2.registrationdate))/365) is null then '< 1 Year'
             when floor(datediff(current_timestamp,min(t2.registrationdate))/365) < 1 then '< 1 Year'
             when floor(datediff(current_timestamp,min(t2.registrationdate))/365) = 1  then '1 Year'
             when floor(datediff(current_timestamp,min(t2.registrationdate))/365) = 2  then '2 Years'
             when floor(datediff(current_timestamp,min(t2.registrationdate))/365) = 3  then '3 Years'
             when floor(datediff(current_timestamp,min(t2.registrationdate))/365) = 4  then '4 Years'
             when floor(datediff(current_timestamp,min(t2.registrationdate))/365) = 5  then '5 Years'
             when floor(datediff(current_timestamp,min(t2.registrationdate))/365) = 6  then '6 Years'
             when floor(datediff(current_timestamp,min(t2.registrationdate))/365) BETWEEN 7 AND 9  then '7 to 9 Years'
             when floor(datediff(current_timestamp,min(t2.registrationdate))/365) > 9  then '9+ Years'
	  		else '< 1 Year' end as TenureBand
FROM proj_galedb.dimcustomers as t1
INNER JOIN proj_galedb.dimcustomerattributes as t2 ON t1.customerKey = t2.customerKey
where t1.sourcesystemcode = 'MMEM'
group by t1.customergoldbrandid
--limit 10;