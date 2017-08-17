SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;

create database if not exists proj_galedb;


DROP TABLE IF EXISTS proj_galedb.CustomerTenure;
CREATE TABLE IF NOT EXISTS proj_galedb.CustomerTenure
(
	customergoldbrandid STRING,
    brand STRING,
	DigitalTenure INT,
	RetailTenure INT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/features/customer_tenure';

INSERT OVERWRITE TABLE proj_galedb.CustomerTenure


SELECT dimcustomersmergedigital.customergoldbrandid,
	   dimcustomersmergedigital.sourcesystemcode,
	   dimcustomersmergedigital.DigitalTenure,
	   dimcustomersmergeretail.RetailTenure
FROM
	(
	SELECT dimcustomers.customerkey,
		   dimcustomers.customerid_source,
		   dimcustomers.customergoldbrandid,
		   dimcustomers.sourcesystemcode,
		   dimcustomerattributes.registrationdate,
	  	   datediff(current_timestamp,dimcustomerattributes.registrationdate) as DigitalTenure
	FROM proj_galedb.dimcustomers
		 inner join
		 proj_galedb.dimcustomerattributes
		 on dimcustomers.customerkey = dimcustomerattributes.customerkey
	where dimcustomers.sourcesystemcode in ('BEDE_GROS','BEDE_MECC','OPBT_MECC','OPBT_GROS')
	group by dimcustomers.customerkey,
			 dimcustomers.customerid_source,
			 dimcustomers.customergoldbrandid,
			 dimcustomers.sourcesystemcode,
			 dimcustomerattributes.registrationdate
	) as dimcustomersmergedigital
	left join
	(
	SELECT dimcustomers.customerkey,
		   dimcustomers.customerid_source,
		   dimcustomers.customergoldbrandid,
		   dimcustomers.sourcesystemcode,
		   dimcustomerattributes.registrationdate,
	  	   case when datediff(current_timestamp,dimcustomerattributes.registrationdate) is null then 0
	  			else datediff(current_timestamp,dimcustomerattributes.registrationdate) end as RetailTenure
	FROM proj_galedb.dimcustomers
		 inner join
		 proj_galedb.dimcustomerattributes
		 on dimcustomers.customerkey = dimcustomerattributes.customerkey
	where dimcustomers.sourcesystemcode in ('ENDX','NEON')
	group by dimcustomers.customerkey,
			 dimcustomers.customerid_source,
			 dimcustomers.customergoldbrandid,
			 dimcustomers.sourcesystemcode,
			 dimcustomerattributes.registrationdate
	) as dimcustomersmergeretail
	on dimcustomersmergedigital.customergoldbrandid = dimcustomersmergeretail.customergoldbrandid;

select * from proj_galedb.CustomerTenure LIMIT 100;